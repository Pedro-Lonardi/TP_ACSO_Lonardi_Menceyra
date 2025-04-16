; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data
empty_str: db 0

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

extern malloc
extern string_proc_node_create_asm
extern str_concat

; create an empty list: [head=NULL, tail=NULL]
string_proc_list_create_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov edi, 16           ; size of list struct
    call malloc
    add rsp, 8
    test rax, rax
    jz .L1
    mov qword [rax], NULL
    mov qword [rax+8], NULL
.L1:
    pop rbp
    ret

; create a node: [next=NULL, prev=NULL, char=dil, str=rsi]
string_proc_node_create_asm:
    push rbp
    mov rbp, rsp
    sub rsp, 8
    mov edi, 32           ; size of node struct
    call malloc
    add rsp, 8
    test rax, rax
    jz .L2
    mov qword [rax], NULL
    mov qword [rax+8], NULL
    mov byte [rax+16], dil
    mov qword [rax+24], rsi
.L2:
    pop rbp
    ret

; add node to end of list
; params: rdi=list ptr, esi=char, rdx=str ptr
string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov r12, rdi          ; list ptr
    mov edi, esi          ; char
    mov rsi, rdx          ; str ptr
    call string_proc_node_create_asm
    add rsp, 8
    test rax, rax
    jz .L3
    mov rbx, [r12+8]      ; tail ptr
    test rbx, rbx
    jnz .L4
    mov [r12], rax        ; head = new node
    mov [r12+8], rax      ; tail = new node
    jmp .L3
.L4:
    mov [rbx], rax        ; old tail.next = new node
    mov [rax+8], rbx      ; new node.prev = old tail
    mov [r12+8], rax      ; tail = new node
.L3:
    pop r12
    pop rbx
    pop rbp
    ret

; concatenate strings in list where node.char == delimiter
; params: rdi=list ptr, esi=delimiter, rdx=initial str
string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov bl, sil           ; delimiter char
    mov r12, rdi          ; save list ptr
    mov rdi, rdx          ; initial str
    lea rsi, [rel empty_str]
    call str_concat       ; duplicate initial str
    mov rcx, rax          ; current result
    mov r12, [r12]        ; head ptr
.L5:
    test r12, r12
    je .L6
    cmp bl, byte [r12+16] ; compare delimiter
    jne .L7
    mov rdi, rcx          ; current str
    mov rsi, [r12+24]     ; node.str
    call str_concat
    mov rcx, rax
.L7:
    mov r12, [r12]        ; next node
    jmp .L5
.L6:
    add rsp, 8
    pop r12
    pop rbx
    pop rbp
    mov rax, rcx
    ret
