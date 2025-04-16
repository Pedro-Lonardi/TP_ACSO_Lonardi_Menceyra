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

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat


string_proc_list_create_asm:
    push rbp
    mov rbp, rsp
    mov edi, 16
    call malloc
    test rax, rax
    jz .Ldone
    mov qword [rax], 0
    mov qword [rax+8], 0
.Ldone:
    pop rbp
    ret

string_proc_node_create_asm:
    push rbp
    mov rbp, rsp
    mov edi, 32
    call malloc
    test rax, rax
    jz .Lend
    mov qword [rax], 0
    mov qword [rax+8], 0
    mov byte [rax+16], dil
    mov qword [rax+24], rsi
.Lend:
    pop rbp
    ret

string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov edi, esi
    mov rsi, rdx
    call string_proc_node_create_asm
    add rsp, 8
    test rax, rax
    jz .Ldone
    mov rcx, [rdi+8]
    test rcx, rcx
    jnz .Lnon_empty
    mov [rdi], rax
    mov [rdi+8], rax
    jmp .Ldone
.Lnon_empty:
    mov [rcx], rax
    mov [rax+8], rcx
    mov [rdi+8], rax
.Ldone:
    pop rbp
    ret

string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push rbx
    sub rsp, 8
    mov ebx, esi
    mov rcx, rdx
    mov rax, [rdi]
.Lloop:
    test rax, rax
    je .Ldone
    cmp byte [rax+16], bl
    jne .Lnext
    mov rdi, rcx
    mov rsi, [rax+24]
    call str_concat
    mov rcx, rax
.Lnext:
    mov rax, [rax]
    jmp .Lloop
.Ldone:
    add rsp, 8
    pop rbx
    pop rbp
    mov rax, rcx
    ret

