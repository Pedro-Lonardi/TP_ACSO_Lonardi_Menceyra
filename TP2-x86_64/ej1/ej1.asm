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

extern malloc
extern string_proc_node_create_asm
extern str_concat

string_proc_list_create_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov edi, 16
    call malloc
    add rsp, 8
    test rax, rax
    jz .L1
    mov qword [rax], 0
    mov qword [rax+8], 0
.L1:
    pop rbp
    ret

string_proc_node_create_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov edi, 32
    call malloc
    add rsp, 8
    test rax, rax
    jz .L2
    mov qword [rax], 0
    mov qword [rax+8], 0
    mov byte [rax+16], dil
    mov qword [rax+24], rsi
.L2:
    pop rbp
    ret

string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov r12, rdi
    mov edi, esi
    mov rsi, rdx
    call string_proc_node_create_asm
    add rsp, 8
    test rax, rax
    jz .L3
    mov rbx, [r12+8]
    test rbx, rbx
    jnz .L4
    mov [r12], rax
    mov [r12+8], rax
    jmp .L3
.L4:
    mov [rbx], rax
    mov [rax+8], rbx
    mov [r12+8], rax
.L3:
    pop r12
    pop rbx
    pop rbp
    ret

string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov bl, sil
    mov rcx, rdx
    mov r12, [rdi]
.L5:
    test r12, r12
    je .L6
    cmp bl, byte [r12+16]
    jne .L7
    mov rdi, rcx
    mov rsi, [r12+24]
    call str_concat
    mov rcx, rax
.L7:
    mov r12, [r12]
    jmp .L5
.L6:
    add rsp, 8
    pop r12
    pop rbx
    pop rbp
    mov rax, rcx
    ret