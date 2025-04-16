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
extern malloc
extern free
extern str_concat

string_proc_list_create_asm:
    mov rdi, 16             ; sizeof(string_proc_list) = 16 bytes
    call malloc
    test rax, rax
    je .error
    mov qword [rax], 0      ; list->first = NULL
    mov qword [rax + 8], 0  ; list->last = NULL
    ret
.error:
    xor rax, rax
    ret

string_proc_node_create_asm:
    push rbx
    push r12
    mov rbx, rsi            ; Guardar hash en rbx
    mov r12, rdi            ; Guardar type en r12
    mov rdi, 32             ; malloc(32) para string_proc_node
    call malloc
    test rax, rax
    je .error
    mov r8, rax             ; r8 = puntero al nodo
    mov byte [r8], r12b     ; node->type = type
    mov rdi, rbx            ; hash para strdup
    call strdup
    test rax, rax
    je .free_node
    mov qword [r8 + 8], rax ; node->hash = strdup(hash)
    mov qword [r8 + 16], 0  ; node->next = NULL
    mov qword [r8 + 24], 0  ; node->previous = NULL
    mov rax, r8             ; Retornar puntero al nodo
    pop r12
    pop rbx
    ret
.free_node:
    mov rdi, r8             ; Liberar nodo
    call free
.error:
    xor rax, rax
    pop r12
    pop rbx
    ret

string_proc_list_add_node_asm:
    push rbx
    test rdi, rdi           ; Verificar si list es NULL
    je .done
    mov rbx, rdi            ; Guardar list en rbx
    mov rdi, rsi            ; type
    mov rsi, rdx            ; hash
    call string_proc_node_create_asm
    test rax, rax
    je .done
    mov rcx, [rbx]          ; list->first
    test rcx, rcx
    je .empty_list
    mov rcx, [rbx + 8]      ; list->last
    mov [rcx + 16], rax     ; last->next = node
    mov [rax + 24], rcx     ; node->prev = last
    mov [rbx + 8], rax      ; list->last = node
    jmp .done
.empty_list:
    mov [rbx], rax          ; list->first = node
    mov [rbx + 8], rax      ; list->last = node
.done:
    pop rbx
    ret

string_proc_list_concat_asm:
    push rbx
    push r12
    test rdi, rdi           ; Verificar si list es NULL
    je .return_empty
    mov rbx, [rdi]          ; list->first
    test rbx, rbx           ; Verificar si list->first es NULL
    je .return_empty
    mov rdi, rdx            ; hash
    call strdup
    test rax, rax           ; Verificar si strdup falla
    je .return_null
    mov r12, rax            ; result = r12
.loop:
    test rbx, rbx
    je .done
    movzx eax, byte [rbx]   ; node->type
    cmp al, sil
    jne .next
    mov rdi, r12            ; result
    mov rsi, [rbx + 8]      ; node->hash
    call str_concat
    mov rdi, r12            ; Liberar result anterior
    call free
    mov r12, rax            ; result = new string
.next:
    mov rbx, [rbx + 16]     ; current = current->next
    jmp .loop
.done:
    mov rax, r12            ; return result
    pop r12
    pop rbx
    ret
.return_empty:
    mov rdi, rdx            ; hash
    call strdup             ; Retornar copia de hash si lista vacía
    pop r12
    pop rbx
    ret
.return_null:
    xor rax, rax
    pop r12
    pop rbx
    ret