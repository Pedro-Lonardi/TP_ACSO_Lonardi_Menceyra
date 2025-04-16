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
    mov rdi, 16
    call malloc

    test rax, rax
    jz .malloc_failed

    mov qword [rax], 0
    mov qword [rax + 8], 0

    ret

.malloc_failed:
    xor rax, rax
    ret

string_proc_node_create_asm:

    push rdi
    push rsi
    mov rdi, 32
    call malloc
    pop rsi
    pop rdi

    test rax, rax
    jz .malloc_failed

    mov qword [rax], 0
    mov qword [rax + 8], 0
    mov byte [rax + 16], dil
    mov qword [rax + 24], rsi
    ret

.malloc_failed:
    xor rax, rax
    ret

string_proc_list_add_node_asm:

    push rdi
    mov rdi, rsi
    mov rsi, rdx
    call string_proc_node_create_asm
    pop rdi

    test rax, rax
    jz .return

    mov r8, rax
    mov r9, [rdi]
    test r9, r9
    jz .empty_list

    mov r10, [rdi + 8]
    mov [r8 + 8], r10
    mov [r10], r8
    mov [rdi + 8], r8
    jmp .return

.empty_list:
    mov [rdi], r8
    mov [rdi + 8], r8

.return:
    ret

string_proc_list_concat_asm:

    mov r8, rdx
    mov r9, [rdi]
    mov r10, rsi
    mov r11, rdx

.loop:
    test r9, r9
    jz .done

    movzx rax, byte [r9 + 16]
    cmp rax, r10
    jne .next

    mov rdi, r8
    mov rsi, [r9 + 24]
    push r8
    push r9
    push r10
    push r11
    call str_concat
    pop r11
    pop r10
    pop r9
    pop r8

    cmp r8, r11
    je .skip_free
    mov rdi, r8
    push rax
    push r9
    push r10
    push r11
    call free
    pop r11
    pop r10
    pop r9
    pop rax

.skip_free:
    mov r8, rax

.next:
    mov r9, [r9]
    jmp .loop

.done:
    mov rax, r8
    ret

