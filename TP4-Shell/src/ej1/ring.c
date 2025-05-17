#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>


int main(int argc, char **argv)
{	
	int start, status, pid, n;
	int buffer[1];

	if (argc != 4){ printf("Uso: anillo <n> <c> <s> \n"); exit(0);}
    
    /* Parsing of arguments */
  	/* TO COMPLETE */
	n = atoi(argv[1]);
    buffer[0] = atoi(argv[2]);
    start = atoi(argv[3]);
    printf("Se crearán %i procesos, se enviará el caracter %i desde proceso %i \n", n, buffer[0], start);
    
   	/* You should start programming from here... */

	int pipe_inicial[2];
    int pipe_final[2];
    int pipes[n][2];

    pipe(pipe_inicial);
    pipe(pipe_final);

    for (int i = 0; i < n; i++) {
        pipe(pipes[i]);
    }

    for (int i = 0; i < n; i++) {
        pid_t pid = fork();
        if (pid == 0) {
            if (i == start) {
                close(pipe_inicial[1]);
                read(pipe_inicial[0], buffer, sizeof(int));
            } else {
                close(pipes[(i + n - 1) % n][1]);
                read(pipes[(i + n - 1) % n][0], buffer, sizeof(int));
            }

            printf("Proceso %d recibió: %d\n", i, buffer[0]);
            buffer[0]++;
            printf("Proceso %d envía: %d\n", i, buffer[0]);

            if ((i + 1) % n == start) {
                close(pipe_final[0]);
                write(pipe_final[1], buffer, sizeof(int));
            } else {
                close(pipes[i][0]);
                write(pipes[i][1], buffer, sizeof(int));
            }

            exit(0);
        }
    }

    close(pipe_inicial[0]);
    write(pipe_inicial[1], buffer, sizeof(int));

    close(pipe_final[1]);
    int result;
    read(pipe_final[0], &result, sizeof(int));

    printf("Resultado final: %d\n", result);

    for (int i = 0; i < n; i++) {
        wait(NULL);
    }

    return 0;
}
