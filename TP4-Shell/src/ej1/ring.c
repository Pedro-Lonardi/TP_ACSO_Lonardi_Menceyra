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

	int pipes[n][2];

    for (int i = 0; i < n; i++) {
        if (pipe(pipes[i]) == -1) {
            perror("pipe");
            exit(1);
        }
    }

    for (int i = 0; i < n; i++) {
        pid = fork();
        if (pid == 0) {
            for (int j = 0; j < n; j++) {
                if (j != i) close(pipes[j][0]);
                if (j != (i + n - 1) % n) close(pipes[j][1]);
            }

            int msg;
            read(pipes[(i + n - 1) % n][0], &msg, sizeof(int));
            printf("Proceso %d recibió: %d\n", i, msg);
            msg++;
            printf("Proceso %d envía: %d\n", i, msg + 1);
            write(pipes[i][1], &msg, sizeof(int));

            exit(0);
        }
    }

    for (int i = 0; i < n; i++) {
        if (i != (start + n - 1) % n) close(pipes[i][1]);
        if (i != (start + n - 2 + n) % n) close(pipes[i][0]);
    }

    write(pipes[(start + n - 1) % n][1], buffer, sizeof(int));

    read(pipes[(start + n - 2) % n][0], buffer, sizeof(int));
    printf("Resultado final: %d\n", buffer[0]);

    for (int i = 0; i < n; i++) {
        wait(NULL);
    }

    return 0;
}
