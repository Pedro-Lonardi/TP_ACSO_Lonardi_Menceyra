    .intel_syntax noprefix
    .section .text

    .extern malloc
    .extern free
    .extern fprintf
    .extern strdup
    .extern str_concat
    .extern stderr

############################################
# string_proc_list_create_asm
############################################
.global string_proc_list_create_asm
.type string_proc_list_create_asm, @function
string_proc_list_create_asm:
    mov     rdi, 16                  # sizeof(string_proc_list)
    call    malloc
    test    rax, rax
    je      .error_list_create
    mov     qword ptr [rax], 0      # list->first = NULL
    mov     qword ptr [rax + 8], 0  # list->last  = NULL
    ret

.error_list_create:
    mov     rdi, qword ptr stderr[rip]
    mov     rsi, offset .errmsg_list
    call    fprintf
    xor     rax, rax
    ret

############################################
# string_proc_node_create_asm
############################################
.global string_proc_node_create_asm
.type string_proc_node_create_asm, @function
string_proc_node_create_asm:
    push    rbp
    mov     rbp, rsp

    mov     rdi, 24                  # sizeof(string_proc_node)
    call    malloc
    test    rax, rax
    je      .error_node_create

    mov     byte ptr [rax + 16], dil    # node->type
    mov     qword ptr [rax + 8], rsi    # node->hash
    mov     qword ptr [rax], 0          # node->next
    mov     qword ptr [rax + 16 + 8], 0 # node->previous

    leave
    ret

.error_node_create:
    mov     rdi, qword ptr stderr[rip]
    mov     rsi, offset .errmsg_node
    call    fprintf
    xor     rax, rax
    leave
    ret

############################################
# string_proc_list_add_node_asm
############################################
.global string_proc_list_add_node_asm
.type string_proc_list_add_node_asm, @function
string_proc_list_add_node_asm:
    push    rbp
    mov     rbp, rsp
    push    rbx

    mov     rbx, rdi                # list
    mov     dil, sil               # type (1st arg)
    mov     rsi, rdx               # hash (2nd arg)
    call    string_proc_node_create_asm

    test    rax, rax
    je      .error_add_node

    mov     rcx, qword ptr [rbx]   # list->first
    test    rcx, rcx
    je      .empty_list

    mov     rdx, qword ptr [rbx + 8]  # list->last
    mov     qword ptr [rdx], rax      # last->next = node
    mov     qword ptr [rax + 16], rdx # node->previous = last
    mov     qword ptr [rbx + 8], rax  # list->last = node
    jmp     .done_add

.empty_list:
    mov     qword ptr [rbx], rax      # list->first = node
    mov     qword ptr [rbx + 8], rax  # list->last  = node
    jmp     .done_add

.error_add_node:
    mov     rdi, qword ptr stderr[rip]
    mov     rsi, offset .errmsg_node
    call    fprintf

.done_add:
    pop     rbx
    leave
    ret

############################################
# string_proc_list_concat_asm
############################################
.global string_proc_list_concat_asm
.type string_proc_list_concat_asm, @function
string_proc_list_concat_asm:
    push    rbp
    mov     rbp, rsp
    push    rbx
    push    r12
    push    r13
    push    r14

    mov     rbx, rdi                # list
    mov     r12b, sil               # type
    mov     r13, rdx                # hash

    mov     rdi, r13
    call    strdup
    mov     r14, rax                # result

    mov     rsi, qword ptr [rbx]    # current_node = list->first

.loop_concat:
    test    rsi, rsi
    je      .done_concat

    mov     al, byte ptr [rsi + 16]   # current_node->type
    cmp     al, r12b
    jne     .next_node

    mov     rdi, r14
    mov     rsi, qword ptr [rsi + 8]  # current_node->hash
    call    str_concat
    mov     rdi, r14
    call    free
    mov     r14, rax

.next_node:
    mov     rsi, qword ptr [rsi]      # current_node = current_node->next
    jmp     .loop_concat

.done_concat:
    mov     rax, r14                  # return result

    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    leave
    ret

############################################
.section .rodata
.errmsg_list:
    .string "Error: No se pudo crear la lista\n"
.errmsg_node:
    .string "Error: No se pudo crear el nodo\n"
