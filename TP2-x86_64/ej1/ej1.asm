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

section .text
global  string_proc_list_concat_asm
extern  strdup
extern  str_concat
extern  free

string_proc_list_concat_asm:
    ; RDI = list, RSI = type (uint8_t), RDX = initial hash
    push    rbx
    push    r12
    push    r13
    push    r14

    mov     r13, rdi            ; r13 = list*
    movzx   ecx, sil            ; ecx = type (zero-extend from sil)

    ; result = strdup(initial_hash)
    mov     rdi, rdx
    call    strdup
    test    rax, rax
    jz      .done               ; si falla strdup, devolvemos NULL
    mov     r14, rax            ; r14 = result

    ; current = list->first
    mov     rbx, [r13]          ; rbx = list->first

.loop:
    test    rbx, rbx
    jz      .done_loop

    ; if (current->type == type)
    movzx   ecx, byte [rbx+16]  ; ecx = current->type
    cmp     ecx, sil
    jne     .next_node

    ; hash_ptr = current->hash
    mov     rdx, [rbx+24]
    test    rdx, rdx
    jz      .next_node          ; si hash es NULL, nos saltamos

    ; temp = str_concat(result, hash_ptr)
    mov     rdi, r14            ; arg1 = result
    mov     rsi, rdx            ; arg2 = hash_ptr
    call    str_concat
    test    rax, rax
    jz      .cleanup            ; si falla, liberamos y salimos

    ; free(old result)
    mov     rdi, r14
    call    free

    mov     r14, rax            ; result = temp

.next_node:
    mov     rbx, [rbx]          ; current = current->next
    jmp     .loop

.done_loop:
    mov     rax, r14            ; devolvemos result
    jmp     .epilog

.cleanup:
    ; en caso de error, liberamos lo que tengamos
    mov     rdi, r14
    call    free
    xor     rax, rax

.epilog:
    pop     r14
    pop     r13
    pop     r12
    pop     rbx
    ret