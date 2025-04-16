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
    subq $16, %rsp

    movq $16, %rdi
    call malloc
    movq %rax, -8(%rbp)

    cmpq $0, %rax
    jne .init_list
    movq stderr(%rip), %rdi 
    leaq .error_msg(%rip), %rsi
    call fprintf
    movq $0, %rax
    jmp .return

.init_list:
    movq $0, (%rax)
    movq $0, 8(%rax)

.return:
    movq -8(%rbp), %rax
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear la lista\n"

string_proc_node_create_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp
    movb %dil, -9(%rbp)
    movq %rsi, -8(%rbp)

    movq $32, %rdi
    call malloc
    movq %rax, -16(%rbp)

    cmpq $0, %rax
    jne .init_node
    movq stderr(%rip), %rdi
    leaq .error_msg(%rip), %rsi
    call fprintf
    movq $0, %rax
    jmp .return

.init_node:
    movq $0, (%rax)
    movq $0, 8(%rax)
    movb -9(%rbp), %cl
    movb %cl, 16(%rax)
    movq -8(%rbp), %rcx
    movq %rcx, 24(%rax)

.return:
    movq -16(%rbp), %rax
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear el nodo\n"

string_proc_list_add_node_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    movq %rdi, -8(%rbp)
    movb %sil, -9(%rbp)
    movq %rdx, -16(%rbp)

    movb -9(%rbp), %dil
    movq -16(%rbp), %rsi
    call string_proc_node_create_asm
    movq %rax, -24(%rbp)

    cmpq $0, %rax
    jne .check_list
    movq stderr(%rip), %rdi
    leaq .error_msg(%rip), %rsi
    call fprintf
    jmp .return

.check_list:
    movq -8(%rbp), %rax
    movq (%rax), %rcx
    cmpq $0, %rcx
    jne .add_to_end

    movq -24(%rbp), %rcx
    movq %rcx, (%rax)
    movq %rcx, 8(%rax)
    jmp .return

.add_to_end:
    movq 8(%rax), %rcx
    movq -24(%rbp), %rdx
    movq %rdx, (%rcx)
    # node->previous = list->last
    movq 8(%rax), %rcx
    movq %rcx, 8(%rdx)
    # list->last = node
    movq -24(%rbp), %rcx
    movq %rcx, 8(%rax)

.return:
    leave
    ret

.section .rodata
.error_msg:
    .string "Error: No se pudo crear el nodo\n"

string_proc_list_concat_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp
    movq %rdi, -8(%rbp)
    movb %sil, -9(%rbp)
    movq %rdx, -16(%rbp)

    movq %rdx, %rdi
    call strdup
    movq %rax, -24(%rbp)

    movq -8(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -32(%rbp)

.loop:
    movq -32(%rbp), %rax
    cmpq $0, %rax
    je .return

    movb 16(%rax), %cl
    cmpb -9(%rbp), %cl
    jne .next_node

    movq -24(%rbp), %rdi
    movq 24(%rax), %rsi
    call str_concat
    movq %rax, %rbx

    movq -24(%rbp), %rdi
    call free

    movq %rbx, -24(%rbp)

.next_node:
    movq -32(%rbp), %rax
    movq (%rax), %rax
    movq %rax, -32(%rbp)
    jmp .loop

.return:
    movq -24(%rbp), %rax
    leave
    ret