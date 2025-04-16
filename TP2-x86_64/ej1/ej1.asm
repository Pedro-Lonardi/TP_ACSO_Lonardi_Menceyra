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
    ; void* malloc(size_t size)
    mov rdi, 8              ; sizeof(string_proc_list)
    call malloc

    test rax, rax
    je .error

    ; rax = list
    mov qword [rax], 0      ; first = NULL
    mov qword [rax + 8], 0  ; last = NULL
    ret

.error:
    ; return NULL
    xor rax, rax
    ret

string_proc_node_create_asm:
    mov rdx, rdi            ; type en rdx
    mov rcx, rsi            ; hash en rcx

    mov rdi, 32             ; malloc(32) CORRECTO
    call malloc

    test rax, rax
    je .error

    ; rax = nodo
    mov byte [rax], dl          ; type en offset 0
    mov qword [rax + 8], rcx    ; hash en offset 8
    mov qword [rax + 16], 0     ; next en offset 16
    mov qword [rax + 24], 0     ; previous en offset 24
    ret

.error:
    xor rax, rax
    ret

string_proc_list_add_node_asm:
    push rbx

    ; llamar a string_proc_node_create_asm(type, hash)
    mov rdi, rsi
    mov rsi, rdx
    call string_proc_node_create_asm

    test rax, rax
    je .done

    mov rbx, rax        ; rbx = node
    mov rcx, [rdi]      ; list->first

    test rcx, rcx
    je .empty_list

    ; nodo intermedio
    mov rax, [rdi + 8]  ; list->last
    mov [rax + 16], rbx ; last->next = node
    mov [rbx + 24], rax ; node->prev = last
    mov [rdi + 8], rbx  ; list->last = node
    jmp .done

.empty_list:
    mov [rdi], rbx      ; list->first = node
    mov [rdi + 8], rbx  ; list->last  = node

.done:
    pop rbx
    ret

string_proc_list_concat_asm:
    push rbx
    push r12

    ; result = strdup(hash)
    mov rdi, rdx
    call strdup
    mov r12, rax       ; result = r12

    ; current = list->first
    mov rbx, [rdi]

.loop:
    test rbx, rbx
    je .done

    movzx eax, byte [rbx]    ; node->type
    cmp al, sil
    jne .next

    ; str_concat(result, node->hash)
    mov rdi, r12             ; result
    mov rsi, [rbx + 4]       ; node->hash
    call str_concat

    ; free(result)
    mov rdi, r12
    call free

    mov r12, rax             ; result = new string

.next:
    mov rbx, [rbx + 12]      ; current = current->next
    jmp .loop

.done:
    mov rax, r12             ; return result
    pop r12
    pop rbx
    ret
