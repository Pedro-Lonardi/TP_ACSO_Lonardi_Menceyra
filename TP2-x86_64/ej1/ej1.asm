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

extern  malloc
extern  fprintf
extern  stderr
extern  strdup
extern  free
extern  str_concat
extern  string_proc_node_create_asm

section .rodata
Lcreate_list_err: db "Error: No se pudo crear la lista",10,0
Lcreate_node_err: db "Error: No se pudo crear el nodo",10,0

section .text

; — string_proc_list_create_asm — malloc(sizeof(list)) y cero campos — 
string_proc_list_create_asm:
    mov     rdi, 16           ; tamaño de string_proc_list (2 punteros = 16 bytes)
    call    malloc
    test    rax, rax
    jnz     .Lcl_ok
    ; en error, fprintf(stderr, msg)
    mov     rdi, stderr
    lea     rsi, [rel Lcreate_list_err]
    xor     rax, rax
    call    fprintf
    xor     rax, rax
    ret
.Lcl_ok:
    mov     qword [rax],    0 ; list->first = NULL
    mov     qword [rax+8],  0 ; list->last  = NULL
    ret

; — string_proc_node_create_asm — malloc(sizeof(node)), asigna tipo y hash —
string_proc_node_create_asm:
    ; recibe: RDI=type, RSI=hash
    push    rdi               ; guardo type
    push    rsi               ; guardo hash
    mov     rdi, 32           ; tamaño string_proc_node (3 punteros + 1 byte + padding)
    call    malloc
    test    rax, rax
    jnz     .Lnc_ok
    ; error:
    mov     rdi, stderr
    lea     rsi, [rel Lcreate_node_err]
    xor     rax, rax
    call    fprintf
    pop     rsi
    pop     rdi
    xor     rax, rax
    ret
.Lnc_ok:
    pop     rsi               ; RSI = hash
    pop     rdi               ; RDI = type
    ; inicializa enlaces a NULL
    mov     qword [rax],    0
    mov     qword [rax+8],  0
    ; guarda type (byte) y hash (puntero)
    mov     byte [rax+16],  dil
    mov     qword [rax+24], rsi
    ret

; — string_proc_list_add_node_asm — llama a node_create y lo enlaza al final —
string_proc_list_add_node_asm:
    ; recibe: RDI = list, RSI = type, RDX = hash
    push    rbx
    push    r12
    push    r13

    mov     r12, rdi          ; r12 = list
    mov     rdi, rsi          ; arg1 = type
    mov     rsi, rdx          ; arg2 = hash
    call    string_proc_node_create_asm
    test    rax, rax
    jz      .Ladd_end

    ; comprueba si la lista está vacía
    mov     r13, [r12]        ; r13 = list->first
    test    r13, r13
    jnz     .Lnot_empty

    ; vacía → first = last = node
    mov     [r12],    rax
    mov     [r12+8],  rax
    jmp     .Ladd_end

.Lnot_empty:
    ; last->next = node
    mov     r13,    [r12+8]   ; r13 = list->last
    mov     [r13],  rax       ; r13->next = node
    mov     [rax+8], r13      ; node->previous = last
    mov     [r12+8], rax      ; list->last = node

.Ladd_end:
    pop     r13
    pop     r12
    pop     rbx
    ret

; — string_proc_list_concat_asm — duplica hash y concatena todas las coincidencias —
string_proc_list_concat_asm:
    ; recibe: RDI = list, RSI = type, RDX = hash
    push    rbx
    push    r12
    push    r13
    push    r14

    mov     r13, rdi          ; r13 = list
    movzx   r12d, sil         ; r12b = type
    ; result = strdup(hash)
    mov     rdi, rdx
    call    strdup
    mov     r14, rax          ; r14 = result
    ; current = list->first
    mov     rbx, [r13]

.Lconcat_loop:
    test    rbx, rbx
    jz      .Lconcat_done
    mov     al, [rbx+16]      ; current->type
    cmp     al, r12b
    jne     .Lnext
    ; temp = str_concat(result, current->hash)
    mov     rdi, r14
    mov     rsi, [rbx+24]
    call    str_concat
    ; free(old)
    mov     rdi, r14
    call    free
    mov     r14, rax          ; result = temp
.Lnext:
    mov     rbx, [rbx]        ; next node
    jmp     .Lconcat_loop

.Lconcat_done:
    mov     rax, r14          ; devuelve result
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret