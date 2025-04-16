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
extern str_concat

; Allocate and initialize an empty list
string_proc_list_create_asm:
    push rbp
    mov rbp, rsp
    mov edi, 16                ; size of string_proc_list (2 pointers)
    call malloc
    test rax, rax
    jz .sp_list_create_done
    mov QWORD [rax], 0         ; first = NULL
    mov QWORD [rax+8], 0       ; last = NULL
.sp_list_create_done:
    pop rbp
    ret

; Allocate and initialize a node
string_proc_node_create_asm:
    push rbp
    mov rbp, rsp
    push rdi                   ; save type
    push rsi                   ; save hash pointer
    mov edi, 32                ; size of string_proc_node (32 bytes)
    call malloc
    test rax, rax
    pop rsi                    ; restore hash pointer
    pop rdi                    ; restore type
    jz .sp_node_create_end
    mov QWORD [rax], 0         ; next = NULL
    mov QWORD [rax+8], 0       ; previous = NULL
    mov al, dil                ; type (low 8 bits of RDI)
    mov [rax+16], al           ; set node->type
    mov [rax+24], rsi          ; set node->hash
.sp_node_create_end:
    pop rbp
    ret

; Add a node to the end of the list
string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    push rbx                   ; preserve rbx
    sub rsp, 8                 ; align stack for call
    mov rbx, rdi               ; rbx = list pointer
    mov edi, esi               ; edi = type
    mov rsi, rdx               ; rsi = hash pointer
    call string_proc_node_create_asm
    test rax, rax
    jz .sp_list_add_cleanup
    ; rax = new node pointer
    mov rcx, [rbx+8]           ; rcx = list->last
    test rcx, rcx
    jnz .sp_list_add_non_empty
    ; empty list
    mov [rbx], rax             ; list->first = new node
    mov [rbx+8], rax           ; list->last = new node
    jmp .sp_list_add_cleanup
.sp_list_add_non_empty:
    mov [rcx], rax             ; old_last->next = new node
    mov [rax+8], rcx           ; new_node->previous = old last
    mov [rbx+8], rax           ; list->last = new node
.sp_list_add_cleanup:
    add rsp, 8
    pop rbx
    pop rbp
    ret

; Concatenate hash strings for nodes of a given type
string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push rbx                   ; preserve rbx
    sub rsp, 8                 ; align stack
    mov QWORD [rbp-8], rsi     ; save type parameter
    mov rcx, rdx               ; rcx = initial hash pointer
    mov rbx, [rdi]             ; rbx = list->first
.sp_list_concat_loop:
    test rbx, rbx
    jz .sp_list_concat_done
    mov al, BYTE [rbp-8]       ; load saved type
    mov dl, BYTE [rbx+16]      ; node->type
    cmp dl, al
    jne .sp_list_concat_next
    ; concatenate rcx (result) with node->hash
    mov rdi, rcx
    mov rsi, [rbx+24]
    call str_concat
    mov rcx, rax               ; update result
.sp_list_concat_next:
    mov rbx, [rbx]             ; move to next node
    jmp .sp_list_concat_loop
.sp_list_concat_done:
    mov rax, rcx               ; return result
    add rsp, 8
    pop rbx
    pop rbp
    ret
