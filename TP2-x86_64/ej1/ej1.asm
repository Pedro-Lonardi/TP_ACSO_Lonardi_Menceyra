; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

section .text

section .text
global string_proc_list_create_asm
extern malloc, fprintf, stderr

string_proc_list_create_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp                ; Reserve space for local variable

    movq $16, %rdi               ; Size of string_proc_list (2 pointers)
    call malloc
    movq %rax, -8(%rbp)          ; Store pointer

    cmpq $0, %rax                ; Check for NULL
    jne .init_list
    movq stderr(%rip), %rdi      ; Load stderr
    leaq .error_msg(%rip), %rsi  ; Load error message
    call fprintf
    movq $0, %rax                ; Return NULL
    jmp .return

.init_list:
    movq $0, (%rax)              ; list->first = NULL
    movq $0, 8(%rax)             ; list->last = NULL

.return:
    movq -8(%rbp), %rax          ; Return pointer
    leave
    ret

section .rodata
.error_msg: .string "Error: No se pudo crear la lista\n"

section .text
global string_proc_node_create_asm
extern malloc, fprintf, stderr

string_proc_node_create_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $16, %rsp                ; Reserve space
    movb %dil, -9(%rbp)          ; Save type
    movq %rsi, -8(%rbp)          ; Save hash

    movq $32, %rdi               ; Size of string_proc_node
    call malloc
    movq %rax, -16(%rbp)         ; Store pointer

    cmpq $0, %rax                ; Check for NULL
    jne .init_node
    movq stderr(%rip), %rdi      ; Load stderr
    leaq .error_msg(%rip), %rsi  ; Load error message
    call fprintf
    movq $0, %rax                ; Return NULL
    jmp .return

.init_node:
    movq $0, (%rax)              ; node->next = NULL
    movq $0, 8(%rax)             ; node->previous = NULL
    movzbl -9(%rbp), %ecx        ; Load type (zero-extend byte to 32 bits)
    movb %cl, 16(%rax)           ; node->type = type
    movq -8(%rbp), %rcx          ; Load hash
    movq %rcx, 24(%rax)          ; node->hash = hash

.return:
    movq -16(%rbp), %rax         ; Return pointer
    leave
    ret

section .rodata
.error_msg: .string "Error: No se pudo crear el nodo\n"

section .text
global string_proc_list_add_node_asm
extern string_proc_node_create_asm, fprintf, stderr

string_proc_list_add_node_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp                ; Reserve space
    movq %rdi, -8(%rbp)          ; Save list
    movb %sil, -9(%rbp)         ; Save type
    movq %rdx, -16(%rbp)         ; Save hash

    movb %sil, %dil              ; type to %dil
    movq %rdx, %rsi              ; hash to %rsi
    call string_proc_node_create_asm
    movq %rax, -24(%rbp)         ; Store node

    cmpq $0, %rax                ; Check for NULL
    jne .check_list
    movq stderr(%rip), %rdi      ; Load stderr
    leaq .error_msg(%rip), %rsi  ; Load error message
    call fprintf
    jmp .return

.check_list:
    movq -8(%rbp), %rax          ; Load list
    movq (%rax), %rcx            ; list->first
    cmpq $0, %rcx                ; Check if list is empty
    jne .add_to_end

    movq -24(%rbp), %rcx         ; Load node
    movq %rcx, (%rax)            ; list->first = node
    movq %rcx, 8(%rax)           ; list->last = node
    jmp .return

.add_to_end:
    movq 8(%rax), %rcx           ; list->last
    movq -24(%rbp), %rdx         ; Load node
    movq %rdx, (%rcx)            ; list->last->next = node
    movq %rcx, 8(%rdx)           ; node->previous = list->last
    movq -24(%rbp), %rcx         ; Load node
    movq %rcx, 8(%rax)           ; list->last = node

.return:
    leave
    ret

section .rodata
.error_msg: .string "Error: No se pudo crear el nodo\n"

section .text
global string_proc_list_concat_asm
extern strdup, str_concat, free

string_proc_list_concat_asm:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp                ; Reserve space
    movq %rdi, -8(%rbp)          ; Save list
    movb %sil, -9(%rbp)         ; Save type
    movq %rdx, -16(%rbp)         ; Save hash

    movq %rdx, %rdi              ; hash to %rdi
    call strdup
    movq %rax, -24(%rbp)         ; Store result

    movq -8(%rbp), %rax          ; Load list
    movq (%rax), %rax            ; list->first
    movq %rax, -32(%rbp)         ; Store current_node

.loop:
    movq -32(%rbp), %rax         ; Load current_node
    cmpq $0, %rax                ; Check for NULL
    je .return

    movb 16(%rax), %cl           ; current_node->type
    cmpb -9(%rbp), %cl          ; Compare with type
    jne .next_node

    movq -24(%rbp), %rdi         ; result to %rdi
    movq 24(%rax), %rsi          ; current_node->hash to %rsi
    call str_concat
    movq %rax, %rbx              ; Save new result

    movq -24(%rbp), %rdi         ; Old result to %rdi
    call free                    ; Free old result

    movq %rbx, -24(%rbp)         ; Update result

.next_node:
    movq -32(%rbp), %rax         ; Load current_node
    movq (%rax), %rax            ; current_node->next
    movq %rax, -32(%rbp)         ; Update current_node
    jmp .loop

.return:
    movq -24(%rbp), %rax         ; Return result
    leave
    ret