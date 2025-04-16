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
; params: rdi=list ptr, rsi=node ptr
string_proc_list_add_node_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov r12, rdi          ; list ptr
    mov rax, rsi          ; node ptr
    test rax, rax         ; if node NULL
    jz .Ladd_end
    mov rbx, [r12+8]      ; tail ptr
    test rbx, rbx
    jnz .Ladd_middle
    ; empty list: head = tail = node
    mov [r12], rax
    mov [r12+8], rax
    jmp .Ladd_end
.Ladd_middle:
    ; append to non-empty list
    mov [rbx], rax        ; old tail.next = node
    mov [rax+8], rbx      ; node.prev = old tail
    mov [r12+8], rax      ; list.tail = node
.Ladd_end:
    add rsp, 8
    pop r12
    pop rbx
    pop rbp
    ret

; concatenate strings in list where node.char == delimiter in list where node.char == delimiter
; params: rdi=list ptr, esi=delimiter, rdx=initial str
string_proc_list_concat_asm:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 8
    mov r12, rdi          ; list ptr
    mov bl, sil           ; delimiter char
    ; handle NULL initial string
    mov rax, rdx
    test rax, rax
    jne .Linit
    lea rdi, [rel empty_str]
    lea rsi, [rel empty_str]
    call str_concat       ; duplicate empty string
    mov rcx, rax          ; current result
    jmp .Lprep
.Linit:
    mov rdi, rax          ; initial str
    lea rsi, [rel empty_str]
    call str_concat       ; duplicate initial
    mov rcx, rax          ; current result
.Lprep:
    mov r12, [r12]        ; head ptr
.L5:
    test r12, r12
    je .L6
    cmp bl, byte [r12+16] ; compare delimiter
    jne .L7
    mov rdi, rcx          ; current str
    mov rsi, [r12+24]     ; node.str
    call str_concat
    mov rcx, rax          ; update result
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
