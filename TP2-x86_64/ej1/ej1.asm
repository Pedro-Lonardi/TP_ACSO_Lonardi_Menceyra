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

section .text

; ========================================
; string_proc_list_create_asm
; void* string_proc_list_create_asm()
; Devuelve puntero a una lista vacía
; ========================================
string_proc_list_create_asm:
    mov rdi, 16             ; sizeof(string_proc_list): 2 punteros (first, last)
    call malloc

    test rax, rax
    je .error_list

    ; Inicializa list->first y list->last a NULL
    mov qword [rax], 0
    mov qword [rax + 8], 0
    ret

.error_list:
    xor rax, rax
    ret


; ========================================
; string_proc_node_create_asm
; void* string_proc_node_create_asm(uint8_t type, char* hash)
; Entradas:
;   rdi = uint8_t type
;   rsi = char* hash
; ========================================
string_proc_node_create_asm:
    mov rdx, rdi            ; guardar type en rdx (solo 1 byte)
    mov rcx, rsi            ; guardar hash en rcx

    mov rdi, 32             ; tamaño del nodo con alineación
    call malloc

    test rax, rax
    je .error_node

    ; rax = nodo
    mov [rax], dl           ; node->type = (uint8_t) type
    mov [rax + 4], rcx      ; node->hash
    mov qword [rax + 12], 0 ; node->next
    mov qword [rax + 20], 0 ; node->previous
    ret

.error_node:
    xor rax, rax
    ret


; ========================================
; string_proc_list_add_node_asm
; void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash)
; Entradas:
;   rdi = list
;   rsi = type
;   rdx = hash
; ========================================
string_proc_list_add_node_asm:
    push rbx

    ; rdi = list, rsi = type, rdx = hash
    mov r8, rdi             ; guardar list en r8

    ; llamar a string_proc_node_create_asm(type, hash)
    mov rdi, rsi
    mov rsi, rdx
    call string_proc_node_create_asm

    test rax, rax
    je .add_done

    mov rbx, rax            ; rbx = new_node
    mov rcx, [r8]           ; list->first

    test rcx, rcx
    je .empty_list

    ; list->last->next = node
    mov rdx, [r8 + 8]       ; rdx = list->last
    mov [rdx + 12], rbx     ; last->next = node
    mov [rbx + 20], rdx     ; node->previous = last
    mov [r8 + 8], rbx       ; list->last = node
    jmp .add_done

.empty_list:
    mov [r8], rbx           ; list->first = node
    mov [r8 + 8], rbx       ; list->last = node

.add_done:
    pop rbx
    ret


; ========================================
; string_proc_list_concat_asm
; char* string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash)
; Entradas:
;   rdi = list
;   sil = type (uint8_t)
;   rdx = hash
; ========================================
string_proc_list_concat_asm:
    push rbx
    push r12

    ; result = strdup(hash)
    mov rdi, rdx
    call strdup
    mov r12, rax            ; r12 = result

    mov rbx, [rdi]          ; rbx = list->first

.loop:
    test rbx, rbx
    je .done

    movzx eax, byte [rbx]   ; eax = node->type
    cmp al, sil
    jne .next

    ; str_concat(result, node->hash)
    mov rdi, r12
    mov rsi, [rbx + 4]
    call str_concat

    ; free(result)
    mov rdi, r12
    call free

    mov r12, rax            ; result = nuevo string

.next:
    mov rbx, [rbx + 12]     ; node = node->next
    jmp .loop

.done:
    mov rax, r12            ; devolver result
    pop r12
    pop rbx
    ret
