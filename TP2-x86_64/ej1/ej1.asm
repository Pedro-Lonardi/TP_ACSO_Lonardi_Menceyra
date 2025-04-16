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

.global string_proc_list_create_asm
.type string_proc_list_create_asm, @function
string_proc_list_create_asm:
    ; llamar a malloc(sizeof(string_proc_list)) -> 16 bytes (2 punteros)
    mov     $16, %rdi              ; argumento para malloc
    call    malloc                 ; malloc devuelve puntero en %rax

    test    %rax, %rax             ; ¿es NULL?
    je      .error                 ; si es NULL, salta a error

    ; inicializar campos: list->first = NULL; list->last = NULL
    movq    $0, (%rax)             ; *(rax)     = NULL (first)
    movq    $0, 8(%rax)            ; *(rax + 8) = NULL (last)

    ret

.error:
    mov     stderr(%rip), %rdi
    mov     $.errmsg, %rsi
    call    fprintf
    mov     $0, %rax
    ret

.section .rodata
.errmsg:
    .string "Error: No se pudo crear la lista\n"


.global string_proc_node_create_asm
.type string_proc_node_create_asm, @function
string_proc_node_create_asm:
    push    %rbp
    mov     %rsp, %rbp

    ; malloc(sizeof(string_proc_node)) -> 24 bytes (4 campos de 8 bytes cada uno)
    mov     $24, %rdi
    call    malloc
    test    %rax, %rax
    je      .error

    ; rdi = type (uint8_t)  → originalmente estaba en %dil
    ; rsi = hash (char*)   → %rsi

    ; Guardamos el puntero del nodo en %rax, y lo vamos usando para escribir
    mov     %dil, 16(%rax)        ; node->type = type (offset 16)
    mov     %rsi, 8(%rax)         ; node->hash = hash (offset 8)
    movq    $0, 0(%rax)           ; node->next = NULL
    movq    $0,  8+8(%rax)        ; node->previous = NULL (offset 16)

    ; ya seteamos todo, devolvemos el puntero
    leave
    ret

.error:
    mov     stderr(%rip), %rdi
    mov     $.errmsg, %rsi
    call    fprintf
    mov     $0, %rax
    leave
    ret

.section .rodata
.errmsg:
    .string "Error: No se pudo crear el nodo\n"


.global string_proc_list_add_node_asm
.type string_proc_list_add_node_asm, @function
string_proc_list_add_node_asm:
    push    %rbp
    mov     %rsp, %rbp
    push    %rbx                 ; usamos rbx para mantener el puntero a 'list'

    ; argumentos:
    ; rdi = list
    ; sil = type
    ; rdx = hash

    mov     %rdi, %rbx          ; guardamos list en rbx
    mov     %sil, %dil          ; movemos type a %dil (1er arg para call)
    mov     %rdx, %rsi          ; hash en %rsi (2do arg)
    call    string_proc_node_create_asm

    test    %rax, %rax
    je      .error              ; si node == NULL, error

    ; %rax = node
    ; chequear si list->first == NULL
    mov     (%rbx), %rcx        ; rcx = list->first
    test    %rcx, %rcx
    je      .empty_list

    ; caso: lista no vacía
    mov     8(%rbx), %rdx       ; rdx = list->last
    mov     %rax, (%rdx)        ; list->last->next = node
    mov     %rdx, 16(%rax)      ; node->previous = list->last
    mov     %rax, 8(%rbx)       ; list->last = node
    jmp     .done

.empty_list:
    mov     %rax, (%rbx)        ; list->first = node
    mov     %rax, 8(%rbx)       ; list->last = node
    jmp     .done

.error:
    mov     stderr(%rip), %rdi
    mov     $.errmsg_add_node, %rsi
    call    fprintf

.done:
    pop     %rbx
    leave
    ret

.section .rodata
.errmsg_add_node:
    .string "Error: No se pudo crear el nodo\n"


.global string_proc_list_concat_asm
.type string_proc_list_concat_asm, @function
string_proc_list_concat_asm:
    push    %rbp
    mov     %rsp, %rbp
    push    %rbx                  ; guarda registros callee-saved
    push    %r12
    push    %r13
    push    %r14

    ; rdi = list
    ; sil = type
    ; rdx = hash

    mov     %rdi, %rbx            ; list → rbx
    mov     %sil, %r12b           ; type → r12b
    mov     %rdx, %r13            ; hash → r13

    ; result = strdup(hash)
    mov     %r13, %rdi
    call    strdup
    mov     %rax, %r14            ; result → r14

    ; current_node = list->first
    mov     (%rbx), %rsi          ; current_node → rsi

.loop:
    test    %rsi, %rsi
    je      .done                 ; if current_node == NULL → fin

    ; if(current_node->type == type)
    mov     16(%rsi), %al         ; current_node->type → al
    cmp     %r12b, %al
    jne     .next_node            ; si no coincide, salta

    ; str_concat(result, current_node->hash)
    mov     %r14, %rdi            ; arg1: result
    mov     8(%rsi), %rsi         ; arg2: current_node->hash
    call    str_concat
    mov     %rax, %rdi            ; liberar result anterior
    mov     %r14, %rdi
    call    free
    mov     %rax, %r14            ; result = temp

.next_node:
    mov     (%rsi), %rsi          ; current_node = current_node->next
    jmp     .loop

.done:
    mov     %r14, %rax            ; return result

    pop     %r14
    pop     %r13
    pop     %r12
    pop     %rbx
    leave
    ret


