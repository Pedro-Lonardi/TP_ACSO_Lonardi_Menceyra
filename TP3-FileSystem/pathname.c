
#include "pathname.h"
#include "directory.h"
#include "inode.h"
#include "diskimg.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>

/**
 * TODO
 */
int pathname_lookup(struct unixfilesystem *fs, const char *pathname) {
    //Implement code here
    if (pathname[0] != '/') {
        return -1;
    }

    char pathcopy[1024];
    strncpy(pathcopy, pathname, sizeof(pathcopy));
    pathcopy[sizeof(pathcopy) - 1] = '\0';

    int curr_inumber = ROOT_INUMBER;

    char *token = strtok(pathcopy + 1, "/");

    while (token != NULL) {
        struct direntv6 dirent;
        int res = directory_findname(fs, token, curr_inumber, &dirent);
        if (res < 0) {
            return -1;
        }

        curr_inumber = dirent.d_inumber;
        token = strtok(NULL, "/");
    }

    return curr_inumber;
}
