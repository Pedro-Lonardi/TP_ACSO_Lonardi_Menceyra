/**
 * File: thread-pool.cc
 * --------------------
 * Presents the implementation of the ThreadPool class.
 */

#include "thread-pool.h"
using namespace std;

ThreadPool::ThreadPool(size_t numThreads) : wts(numThreads), done(false), pendingTasks(0) {
    for (size_t i = 0; i < numThreads; ++i) {
        wts[i].ts = thread([this, i] { worker(i); });
    }

    dt = thread([this] { dispatcher(); });
}


void ThreadPool::schedule(const function<void(void)>& thunk) {
    if (!isAlive.load()) throw runtime_error("Cannot schedule on destroyed ThreadPool");
    if (!thunk) throw invalid_argument("Thunk cannot be null");
    {
        lock_guard<mutex> lock(taskQueueMutex);
        taskQueue.push(thunk);
        {
            lock_guard<mutex> guard(waitMutex);
            pendingTasks++;
        }
    }
    taskAvailable.notify_all(); // ver si dejar notify_all o hacerlo uno por uno (en clase recomendaron all)
}

void ThreadPool::dispatcher() {
    while (true) {
        function<void(void)> task;

        {
            unique_lock<mutex> lock(taskQueueMutex);
            taskAvailable.wait(lock, [this]() { return !taskQueue.empty() || done; });
            if (done && taskQueue.empty()) return;
            task = taskQueue.front();
            taskQueue.pop();
        }

        while (true) {
            for (auto& wt : wts) {
                if (wt.available) {
                    wt.available = false;
                    wt.thunk = task;
                    wt.ready.signal();
                    goto siguiente_iteracion;
                }
            }
            this_thread::yield();
        }
    siguiente_iteracion:;
    }
}

void ThreadPool::worker(int id) {
    worker_t& wt = wts[id];

    while (true) {
        wt.ready.wait();
        if (done) break;

        if (wt.thunk) {
            wt.thunk();
            wt.thunk = nullptr;
        }

        wt.available = true;
        {
            lock_guard<mutex> lock(waitMutex);
            pendingTasks--;
            if (pendingTasks == 0) { waitCv.notify_all(); }
        }
    }
}

void ThreadPool::wait() {
    unique_lock<mutex> lock(waitMutex);
    waitCv.wait(lock, [this]() { return pendingTasks == 0; });
    
}

ThreadPool::~ThreadPool() {
    wait();
    isAlive = false;
    {
        lock_guard<mutex> lock(taskQueueMutex);
        done = true;
    }

    taskAvailable.notify_all();
    if (dt.joinable()) dt.join();
    for (auto& wt : wts) {
        wt.ready.signal();
        if (wt.ts.joinable()) wt.ts.join();
    }
}
