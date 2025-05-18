#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

#define MAX_COMMANDS 200

int main() {

    char command[256];
    char *commands[MAX_COMMANDS];

    while (1) 
    {
        printf("Shell> ");
        fflush(stdout);
        
        /*Reads a line of input from the user from the standard input (stdin) and stores it in the variable command */
        fgets(command, sizeof(command), stdin);
        
        /* Removes the newline character (\n) from the end of the string stored in command, if present. 
           This is done by replacing the newline character with the null character ('\0').
           The strcspn() function returns the length of the initial segment of command that consists of 
           characters not in the string specified in the second argument ("\n" in this case). */
        command[strcspn(command, "\n")] = '\0';

        /* Tokenizes the command string using the pipe character (|) as a delimiter using the strtok() function. 
           Each resulting token is stored in the commands[] array. 
           The strtok() function breaks the command string into tokens (substrings) separated by the pipe character |. 
           In each iteration of the while loop, strtok() returns the next token found in command. 
           The tokens are stored in the commands[] array, and command_count is incremented to keep track of the number of tokens found. */
        int command_count = 0;
        char *token = strtok(command, "|");
        while (token != NULL) 
        {
            commands[command_count++] = token;
            token = strtok(NULL, "|");
        }

        /* You should start programming from here... */

        int prev_pipe_fd[2] = {-1, -1};

        for (int i = 0; i < command_count; i++) 
        {
            printf("Command %d: %s\n", i, commands[i]);

            char *args[50];
            int argc = 0;

            char *arg = strtok(commands[i], " ");
            while (arg != NULL) {
                args[argc++] = arg;
                arg = strtok(NULL, " ");
            }
            args[argc] = NULL;

            int pipe_fd[2];
            if (i < command_count - 1) {
                pipe(pipe_fd);
            }

            if (i < command_count - 1) {
                pipe(pipe_fd);
                printf(">> pipe() creado: fd[%d,%d] para comando %d\n", pipe_fd[0], pipe_fd[1], i);
            }

            pid_t pid = fork();
            if (pid == 0) {
                printf(">> (hijo %d) Ejecutando: %s\n", i, args[0]);

                if (i > 0) {
                    printf(">> (hijo %d) dup2 prev_pipe_fd[0] (%d) -> STDIN\n", i, prev_pipe_fd[0]);
                    dup2(prev_pipe_fd[0], STDIN_FILENO);
                    close(prev_pipe_fd[0]);
                    close(prev_pipe_fd[1]);
                }

                if (i < command_count - 1) {
                    close(pipe_fd[0]);
                    printf(">> (hijo %d) dup2 pipe_fd[1] (%d) -> STDOUT\n", i, pipe_fd[1]);
                    dup2(pipe_fd[1], STDOUT_FILENO);
                    close(pipe_fd[1]);
                }

                execvp(args[0], args);
                perror("execvp");
                printf(">> execvp falló: %s\n", args[0]);
                exit(EXIT_FAILURE);
            } else if (pid > 0) {

                if (i > 0) {
                    close(prev_pipe_fd[0]);
                    close(prev_pipe_fd[1]);
                }

                if (i < command_count - 1) {
                    close(pipe_fd[1]);
                    if (i != command_count - 2) {
                        close(pipe_fd[0]);
                    }
                    prev_pipe_fd[0] = pipe_fd[0];
                    prev_pipe_fd[1] = pipe_fd[1];
                }
            } else {
                perror("fork");
                exit(EXIT_FAILURE);
            }
        }

        for (int i = 0; i < command_count; i++) {
            wait(NULL);
            printf(">> Comando %d finalizó\n", i);
        }
        if (prev_pipe_fd[0] != -1) close(prev_pipe_fd[0]);
        if (prev_pipe_fd[1] != -1) close(prev_pipe_fd[1]);
    }
    return 0;
}
