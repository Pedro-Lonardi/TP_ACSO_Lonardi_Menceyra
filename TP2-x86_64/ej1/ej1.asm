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
extern strdup
extern malloc
extern free
extern str_concat


string_proc_list_create_asm:
    push rbp
    mov rbp, rsp

    mov edi, 16
    call malloc

    test rax, rax
    je .return_null

    mov qword [rax], 0
    mov qword [rax + 8], 0

    jmp .done

.return_null:

.done:
pop rbp
ret

string_proc_node_create_asm:
    push rbp
    mov rbp, rsp

    mov edi, 32
    call malloc

    test rax, rax
    je .return_null

    mov qword [rax], 0

    mov qword [rax + 8], 0

    mov byte [rax + 16], dil

    mov [rax + 24], rsi

    jmp .done

.return_null:

.done:
    pop rbp
    ret

string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp

    mov r8, rdi
    mov r9b, sil
    mov r10, rdx

    mov dil, r9b
    mov rsi, r10
    call string_proc_node_create_asm

    test rax, rax
    je .end

    cmp qword [r8], 0
    je .lista_vacia

    mov rcx, [r8 + 8]
    mov [rcx], rax

    mov [rax + 8], rcx

    mov [r8 + 8], rax

    jmp .end

.lista_vacia:
    mov [r8], rax
    mov [r8 + 8], rax

.end:
    pop rbp
    ret

string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp

    mov r8, rdi
    mov r9b, sil
    mov r10, rdx

    mov rdi, r10
    call strdup
    mov r12, rax

    mov r11, [r8]

.loop:
    test r11, r11
    je .done

    mov al, [r11 + 16]
    cmp al, r9b
    jne .next_node

    mov rdi, r12
    mov rsi, [r11 + 24]
    call str_concat
    mov r13, rax

    mov rdi, r12
    call free

    mov r12, r13

.next_node:
    mov r11, [r11]
    jmp .loop

.done:
    mov rax, r12 

    pop rbp
    ret
