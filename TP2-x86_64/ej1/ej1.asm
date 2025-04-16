; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

extern strdup
extern malloc, fprintf, stderr
extern free
extern str_concat

string_proc_list_create_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp          # Reservar espacio en la pila

    # Llamar a malloc(sizeof(string_proc_list)) = 16 bytes
    movq $16, %rdi          # Argumento: tamaño = 16
    call malloc
    movq %rax, -8(%rbp)     # Guardar puntero retornado en variable local

    # Verificar si malloc retornó NULL
    cmpq $0, %rax
    jne .init_list
    # Error: Imprimir mensaje
    movq stderr(%rip), %rdi # Primer argumento: stderr
    leaq .error_msg(%rip), %rsi # Segundo argumento: mensaje
    call fprintf
    movq $0, %rax           # Retornar NULL
    jmp .return

.init_list:
    # Inicializar list->first = NULL
    movq $0, (%rax)
    # Inicializar list->last = NULL
    movq $0, 8(%rax)

.return:
    movq -8(%rbp), %rax     # Retornar puntero a la lista
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear la lista\n"

string_proc_node_create_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp          # Reservar espacio en la pila
    movb %dil, -9(%rbp)     # Guardar type (uint8_t) en la pila
    movq %rsi, -8(%rbp)     # Guardar hash (char*) en la pila

    # Llamar a malloc(sizeof(string_proc_node)) = 32 bytes
    movq $32, %rdi          # Argumento: tamaño = 32
    call malloc
    movq %rax, -16(%rbp)    # Guardar puntero retornado

    # Verificar si malloc retornó NULL
    cmpq $0, %rax
    jne .init_node
    # Error: Imprimir mensaje
    movq stderr(%rip), %rdi
    leaq .error_msg(%rip), %rsi
    call fprintf
    movq $0, %rax           # Retornar NULL
    jmp .return

.init_node:
    # Inicializar node->next = NULL
    movq $0, (%rax)
    # Inicializar node->previous = NULL
    movq $0, 8(%rax)
    # Inicializar node->type = type
    movb -9(%rbp), %cl
    movb %cl, 16(%rax)
    # Inicializar node->hash = hash
    movq -8(%rbp), %rcx
    movq %rcx, 24(%rax)

.return:
    movq -16(%rbp), %rax    # Retornar puntero al nodo
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear el nodo\n"

string_proc_list_add_node_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp          # Reservar espacio en la pila
    movq %rdi, -8(%rbp)     # Guardar list
    movb %sil, -9(%rbp)     # Guardar type
    movq %rdx, -16(%rbp)    # Guardar hash

    # Llamar a string_proc_node_create_asm(type, hash)
    movb -9(%rbp), %dil
    movq -16(%rbp), %rsi
    call string_proc_node_create_asm
    movq %rax, -24(%rbp)    # Guardar puntero al nodo

    # Verificar si node es NULL
    cmpq $0, %rax
    jne .check_list
    # Error: Imprimir mensaje
    movq stderr(%rip), %rdi
    leaq .error_msg(%rip), %rsi
    call fprintf
    jmp .return

.check_list:
    # Verificar si list->first es NULL
    movq -8(%rbp), %rax     # rax = list
    movq (%rax), %rcx       # rcx = list->first
    cmpq $0, %rcx
    jne .add_to_end

    # Lista vacía: list->first = node, list->last = node
    movq -24(%rbp), %rcx    # rcx = node
    movq %rcx, (%rax)       # list->first = node
    movq %rcx, 8(%rax)      # list->last = node
    jmp .return

.add_to_end:
    # Lista no vacía: list->last->next = node
    movq 8(%rax), %rcx      # rcx = list->last
    movq -24(%rbp), %rdx    # rdx = node
    movq %rdx, (%rcx)       # list->last->next = node
    # node->previous = list->last
    movq 8(%rax), %rcx      # rcx = list->last
    movq %rcx, 8(%rdx)      # node->previous = list->last
    # list->last = node
    movq -24(%rbp), %rcx
    movq %rcx, 8(%rax)      # list->last = node

.return:
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear el nodo\n"

string_proc_list_concat_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp          # Reservar espacio en la pila
    movq %rdi, -8(%rbp)     # Guardar list
    movb %sil, -9(%rbp)     # Guardar type
    movq %rdx, -16(%rbp)    # Guardar hash

    # Llamar a strdup(hash)
    movq %rdx, %rdi
    call strdup
    movq %rax, -24(%rbp)    # Guardar result

    # Obtener current_node = list->first
    movq -8(%rbp), %rax
    movq (%rax), %rax       # rax = list->first
    movq %rax, -32(%rbp)    # Guardar current_node

.loop:
    # Verificar si current_node es NULL
    movq -32(%rbp), %rax
    cmpq $0, %rax
    je .return

    # Verificar si current_node->type == type
    movb 16(%rax), %cl      # cl = current_node->type
    cmpb -9(%rbp), %cl
    jne .next_node

    # Llamar a str_concat(result, current_node->hash)
    movq -24(%rbp), %rdi    # Primer argumento: result
    movq 24(%rax), %rsi     # Segundo argumento: current_node->hash
    call str_concat
    movq %rax, %rbx         # Guardar temp en rbx (callee-saved)

    # Liberar result anterior
    movq -24(%rbp), %rdi
    call free

    # Actualizar result = temp
    movq %rbx, -24(%rbp)

.next_node:
    # current_node = current_node->next
    movq -32(%rbp), %rax
    movq (%rax), %rax       # rax = current_node->next
    movq %rax, -32(%rbp)
    jmp .loop

.return:
    movq -24(%rbp), %rax    # Retornar result
    leave
    ret