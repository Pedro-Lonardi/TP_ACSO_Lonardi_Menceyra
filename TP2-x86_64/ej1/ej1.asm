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
extern free
extern fprintf
extern strdup
extern str_concat
extern stderr

;------------------------------------------------------------
; string_proc_list_create_asm(void)
;------------------------------------------------------------
string_proc_list_create_asm:
    mov     rdi, 16             ; tamaño de string_proc_list
    call    malloc
    test    rax, rax
    jne     .create_list_ok
    ; error: fprintf(stderr, ...)
    mov     rdi, [rel stderr]
    lea     rsi, [rel err_list]
    xor     rax, rax
    call    fprintf
    xor     rax, rax
    ret
.create_list_ok:
    mov     qword [rax], 0      ; list->first = NULL
    mov     qword [rax+8], 0    ; list->last = NULL
    ret

;------------------------------------------------------------
; string_proc_node_create_asm(uint8_t type, char* hash)
;------------------------------------------------------------
string_proc_node_create_asm:
    mov     r8b, dil            ; guardar 'type'
    mov     rdi, 32             ; tamaño de string_proc_node
    call    malloc
    test    rax, rax
    jne     .create_node_ok
    ; error: fprintf(stderr, ...)
    mov     rdi, [rel stderr]
    lea     rsi, [rel err_node]
    xor     rax, rax
    call    fprintf
    xor     rax, rax
    ret
.create_node_ok:
    mov     qword [rax], 0      ; node->next = NULL
    mov     qword [rax+8], 0    ; node->previous = NULL
    mov     byte  [rax+16], r8b ; node->type = type
    mov     qword [rax+24], rsi ; node->hash = hash
    ret

;------------------------------------------------------------
; string_proc_list_add_node_asm(list, type, hash)
;------------------------------------------------------------
string_proc_list_add_node_asm:
    push    rbx                 ; preservar callee-saved para list pointer
    mov     rbx, rdi            ; rbx = list
    mov     rdi, rsi            ; rdi = type
    mov     rsi, rdx            ; rsi = hash
    call    string_proc_node_create_asm
    test    rax, rax
    je      .node_fail
    ; rax = new node, rbx = list
    mov     rcx, [rbx]          ; rcx = list->first
    test    rcx, rcx
    jne     .list_not_empty
    ; lista vacía
    mov     [rbx], rax          ; list->first = node
    mov     [rbx+8], rax        ; list->last  = node
    jmp     .add_node_done
.list_not_empty:
    mov     rcx, [rbx+8]        ; rcx = list->last
    mov     [rcx], rax          ; last->next = node
    mov     [rax+8], rcx        ; node->previous = old last
    mov     [rbx+8], rax        ; list->last = node
.add_node_done:
    pop     rbx
    ret
.node_fail:
    pop     rbx
    ret

;------------------------------------------------------------
; string_proc_list_concat_asm(list, type, hash)
;------------------------------------------------------------
string_proc_list_concat_asm:
    push    rbx
    push    r12
    push    r13
    mov     r12, rdi            ; r12 = list
    mov     r13b, sil           ; r13b = type
    mov     rdi, rdx            ; rdi = initial hash
    call    strdup
    mov     rbx, rax            ; rbx = result
    mov     rcx, [r12]          ; rcx = list->first
.concat_loop:
    cmp     rcx, 0
    je      .concat_done
    mov     al, [rcx+16]        ; node->type
    cmp     al, r13b
    jne     .skip_concat
    mov     rdi, rbx            ; arg1: accumulated string
    mov     rsi, [rcx+24]       ; arg2: node->hash
    call    str_concat
    mov     rdi, rbx
    call    free
    mov     rbx, rax            ; update result
.skip_concat:
    mov     rcx, [rcx]          ; next node
    jmp     .concat_loop
.concat_done:
    mov     rax, rbx
    pop     r13
    pop     r12
    pop     rbx
    ret

section .rodata
err_list:
    db "Error: No se pudo crear la lista\n", 0
err_node:
    db "Error: No se pudo crear el nodo\n", 0