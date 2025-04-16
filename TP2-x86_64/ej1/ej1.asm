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


.LC0:
        .string "Error: No se pudo crear la lista\n"
string_proc_list_create_asm:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 16
        mov     edi, 16
        call    malloc
        mov     QWORD PTR [rbp-8], rax
        cmp     QWORD PTR [rbp-8], 0
        jne     .L2
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 33
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC0
        call    fwrite
        mov     eax, 0
        jmp     .L1
.L2:
        mov     rax, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax], 0
        mov     rax, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax+8], 0
.L1:
        leave
        ret

.LC1:
        .string "Error: No se pudo crear el nodo\n"
string_proc_node_create_asm:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 32
        mov     eax, edi
        mov     QWORD PTR [rbp-32], rsi
        mov     BYTE PTR [rbp-20], al
        mov     edi, 32
        call    malloc
        mov     QWORD PTR [rbp-8], rax
        cmp     QWORD PTR [rbp-8], 0
        jne     .L5
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 32
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        mov     eax, 0
        jmp     .L6
.L5:
        mov     rax, QWORD PTR [rbp-8]
        movzx   edx, BYTE PTR [rbp-20]
        mov     BYTE PTR [rax+16], dl
        mov     rax, QWORD PTR [rbp-8]
        mov     rdx, QWORD PTR [rbp-32]
        mov     QWORD PTR [rax+24], rdx
        mov     rax, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax], 0
        mov     rax, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax+8], 0
        mov     rax, QWORD PTR [rbp-8]
.L6:
        leave
        ret

string_proc_list_add_node_asm:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48
        mov     QWORD PTR [rbp-24], rdi
        mov     eax, esi
        mov     QWORD PTR [rbp-40], rdx
        mov     BYTE PTR [rbp-28], al
        movzx   eax, BYTE PTR [rbp-28]
        mov     rdx, QWORD PTR [rbp-40]
        mov     rsi, rdx
        mov     edi, eax
        call    string_proc_node_create
        mov     QWORD PTR [rbp-8], rax
        cmp     QWORD PTR [rbp-8], 0
        jne     .L8
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 32
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        jmp     .L7
.L8:
        mov     rax, QWORD PTR [rbp-24]
        mov     rax, QWORD PTR [rax]
        test    rax, rax
        jne     .L10
        mov     rax, QWORD PTR [rbp-24]
        mov     rdx, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax], rdx
        mov     rax, QWORD PTR [rbp-24]
        mov     rdx, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax+8], rdx
        jmp     .L7
.L10:
        mov     rax, QWORD PTR [rbp-24]
        mov     rax, QWORD PTR [rax+8]
        mov     rdx, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax], rdx
        mov     rax, QWORD PTR [rbp-24]
        mov     rdx, QWORD PTR [rax+8]
        mov     rax, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax+8], rdx
        mov     rax, QWORD PTR [rbp-24]
        mov     rdx, QWORD PTR [rbp-8]
        mov     QWORD PTR [rax+8], rdx
.L7:
        leave
        ret

string_proc_list_concat_asm:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 64
        mov     QWORD PTR [rbp-40], rdi
        mov     eax, esi
        mov     QWORD PTR [rbp-56], rdx
        mov     BYTE PTR [rbp-44], al
        mov     rax, QWORD PTR [rbp-40]
        mov     rax, QWORD PTR [rax]
        mov     QWORD PTR [rbp-8], rax
        mov     rax, QWORD PTR [rbp-56]
        mov     rdi, rax
        call    strdup
        mov     QWORD PTR [rbp-16], rax
        jmp     .L12
.L14:
        mov     rax, QWORD PTR [rbp-8]
        movzx   eax, BYTE PTR [rax+16]
        cmp     BYTE PTR [rbp-44], al
        jne     .L13
        mov     rax, QWORD PTR [rbp-8]
        mov     rdx, QWORD PTR [rax+24]
        mov     rax, QWORD PTR [rbp-16]
        mov     rsi, rdx
        mov     rdi, rax
        call    str_concat
        mov     QWORD PTR [rbp-24], rax
        mov     rax, QWORD PTR [rbp-16]
        mov     rdi, rax
        call    free
        mov     rax, QWORD PTR [rbp-24]
        mov     QWORD PTR [rbp-16], rax
.L13:
        mov     rax, QWORD PTR [rbp-8]
        mov     rax, QWORD PTR [rax]
        mov     QWORD PTR [rbp-8], rax
.L12:
        cmp     QWORD PTR [rbp-8], 0
        jne     .L14
        mov     rax, QWORD PTR [rbp-16]
        leave
        ret

