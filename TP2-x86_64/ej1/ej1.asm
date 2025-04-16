; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

.intel_syntax noprefix
.section .text
.global string_proc_list_create_asm
.global string_proc_node_create_asm
.global string_proc_list_add_node_asm
.global string_proc_list_concat_asm

.extern malloc
.extern free
.extern fprintf
.extern strdup
.extern str_concat
.extern stderr

;----------------------------------------------------------------------
; string_proc_list_create_asm(void)
;   - Reserva 16 bytes para el struct string_proc_list.
;   - Si falla la asignación, imprime "Error: No se pudo crear la lista\n"
;     y retorna NULL.
;   - Inicializa list->first y list->last a 0.
;----------------------------------------------------------------------
string_proc_list_create_asm:
    mov rdi, 16
    call malloc
    test rax, rax
    jne .create_list_ok
    mov rdi, qword ptr [stderr]
    lea rsi, [rip+err_list]
    xor rax, rax
    call fprintf
    xor rax, rax
    ret
.create_list_ok:
    mov qword ptr [rax], 0
    mov qword ptr [rax+8], 0
    ret

;----------------------------------------------------------------------
; string_proc_node_create_asm(uint8_t type, char* hash)
;----------------------------------------------------------------------
string_proc_node_create_asm:
    mov r8b, dil
    mov rdi, 32
    call malloc
    test rax, rax
    jne .create_node_ok
    mov rdi, qword ptr [stderr]
    lea rsi, [rip+err_node]
    xor rax, rax
    call fprintf
    xor rax, rax
    ret
.create_node_ok:
    mov qword ptr [rax], 0
    mov qword ptr [rax+8], 0
    mov byte ptr [rax+16], r8b
    mov qword ptr [rax+24], rsi
    ret

;----------------------------------------------------------------------
; string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash)
;----------------------------------------------------------------------
string_proc_list_add_node_asm:
    mov r8, rdi
    mov rdi, rsi
    mov rsi, rdx
    call string_proc_node_create_asm
    test rax, rax
    je .node_fail
    mov rcx, qword ptr [r8]
    test rcx, rcx
    jne .list_not_empty
    mov qword ptr [r8], rax
    mov qword ptr [r8+8], rax
    jmp .add_node_end
.list_not_empty:
    mov rcx, qword ptr [r8+8]
    mov qword ptr [rcx], rax
    mov qword ptr [rax+8], rcx
    mov qword ptr [r8+8], rax
.add_node_end:
    ret
.node_fail:
    ret

;----------------------------------------------------------------------
; string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash)
;----------------------------------------------------------------------
string_proc_list_concat_asm:
    push rbx
    push r12
    push r13
    mov r12, rdi
    mov r13b, sil
    mov rdi, rdx
    call strdup
    mov rbx, rax
    mov rcx, qword ptr [r12]
.concat_loop:
    cmp rcx, 0
    je .concat_done
    mov al, byte ptr [rcx+16]
    cmp al, r13b
    jne .skip_concat
    mov rdi, rbx
    mov rsi, qword ptr [rcx+24]
    call str_concat
    mov rdi, rbx
    call free
    mov rbx, rax
.skip_concat:
    mov rcx, qword ptr [rcx]
    jmp .concat_loop
.concat_done:
    mov rax, rbx
    pop r13
    pop r12
    pop rbx
    ret

.section .rodata
err_list:
    .string "Error: No se pudo crear la lista\n"
err_node:
    .string "Error: No se pudo crear el nodo\n"