#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "shell.h"

// OPERACIONES ARITMÉTICAS
#define OPCODE_ADD      0x458   // ADD (register)
#define OPCODE_ADDI     0x488   // ADD (immediate)
#define OPCODE_ADDS     0x558   // ADDS (register)
#define OPCODE_ADDSI    0x5A8   // ADDS (immediate)
#define OPCODE_SUBS     0x758   // SUBS (register)
#define OPCODE_SUBSI    0x7A8   // SUBS (immediate)

// OPERACIONES COMPARATIVAS
#define OPCODE_CMP      0x758   // CMP es un SUBS con XZR como destino
#define OPCODE_CMPI     0x7A8

// OPERACIONES LÓGICAS
#define OPCODE_ANDS     0x750   // ANDS (shifted register)
#define OPCODE_EOR      0x650   // EOR (shifted register)
#define OPCODE_ORR      0x550   // ORR (shifted register)

// OPERACIONES DE SALTO
#define OPCODE_B        0x5     // B (branch), usa bits [31:26]
#define OPCODE_BR       0x6B0   // BR (register)
#define OPCODE_BCOND    0x2A0   // B.cond → BEQ, BNE, etc. (usa bits [31:24])

// OPERACIONES DE DESPLAZAMIENTO
#define OPCODE_LSL      0x69B   // LSL (alias de UBFM)
#define OPCODE_LSR      0x69A   // LSR (alias de UBFM)

// OPERACIONES DE MEMORIA
#define OPCODE_LDUR     0x7C2
#define OPCODE_LDURB    0x1C2
#define OPCODE_LDURH    0x5C2
#define OPCODE_STUR     0x7C0
#define OPCODE_STURB    0x1C0
#define OPCODE_STURH    0x5C0

// OTRAS OPERACIONES
#define OPCODE_MOVZ     0x528   // MOVZ (hw=00)
#define OPCODE_MUL      0x1B7   // MUL (alias de MADD con rn=rm)
#define OPCODE_CBZ      0xB4
#define OPCODE_CBNZ     0xB5
#define OPCODE_HLT      0x6A2

// --- Prototipos de funciones auxiliares ---

// Aritméticas
void execute_add(uint32_t instruction);
void execute_addi(uint32_t instruction);
void execute_adds(uint32_t instruction);
void execute_addsi(uint32_t instruction);
void execute_subs(uint32_t instruction);  // CMP si el destino es XZR
void execute_subsi(uint32_t instruction);  // CMPI si el destino es XZR

// Lógicas
void execute_ands(uint32_t instruction);
void execute_eor(uint32_t instruction);
void execute_orr(uint32_t instruction);

// Desplazamientos
void execute_lsl(uint32_t instruction);
void execute_lsr(uint32_t instruction);

// Saltos
void execute_b(uint32_t instruction);
void execute_br(uint32_t instruction);
void execute_bcond(uint32_t instruction);

// Memoria
void execute_ldur(uint32_t instruction);
void execute_ldurb(uint32_t instruction);
void execute_ldurh(uint32_t instruction);
void execute_stur(uint32_t instruction);
void execute_sturb(uint32_t instruction);
void execute_sturh(uint32_t instruction);

// Otros
void execute_movz(uint32_t instruction);
void execute_mul(uint32_t instruction);
void execute_cbz(uint32_t instruction);
void execute_cbnz(uint32_t instruction);
void execute_hlt(uint32_t instruction);

void process_instruction()
{
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);
    uint32_t opcode = (instruction >> 21) & 0x7FF;

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;

    switch(opcode) {
        case OPCODE_ADD:
            execute_add(instruction);
            break;
        case OPCODE_ADDI:
            execute_addi(instruction);
            break;
        case OPCODE_ADDS:
            execute_adds(instruction);
            break;
        case OPCODE_ADDSI:
            execute_addsi(instruction);
            break;
        case OPCODE_SUBS:             // Es igual a un CMP si el destino es XZR
            execute_subs(instruction);
            break;
        case OPCODE_SUBSI:            // Es igual a un CMPI si el destino es XZR
            execute_subsi(instruction);
            break;
        case OPCODE_ANDS:
            execute_ands(instruction);
            break;
        case OPCODE_EOR:
            execute_eor(instruction);
            break;
        case OPCODE_ORR:
            execute_orr(instruction);
            break;
        case OPCODE_LSL:
            execute_lsl(instruction);
            break;
        case OPCODE_LSR:
            execute_lsr(instruction);
            break;
        case OPCODE_B:
            execute_b(instruction);
            break;
        case OPCODE_BR:
            execute_br(instruction);
            break;
        case OPCODE_BCOND:
            execute_bcond(instruction);
            break;
        case OPCODE_LDUR:
            execute_ldur(instruction);
            break;
        case OPCODE_LDURB:
            execute_ldurb(instruction);
            break;
        case OPCODE_LDURH:
            execute_ldurh(instruction);
            break;
        case OPCODE_STUR:
            execute_stur(instruction);
            break;
        case OPCODE_STURB:
            execute_sturb(instruction);
            break;
        case OPCODE_STURH:
            execute_sturh(instruction);
            break;
        case OPCODE_MOVZ:
            execute_movz(instruction);
            break;
        case OPCODE_MUL:
            execute_mul(instruction);
            break;
        case OPCODE_CBZ:
            execute_cbz(instruction);
            break;
        case OPCODE_CBNZ:
            execute_cbnz(instruction);
            break;
        case OPCODE_HLT:
            execute_hlt(instruction);
            break;
        default:
            printf("Instrucción no implementada: 0x%08x (opcode 0x%x)\n", instruction, opcode);
            break;
    }
}

void execute_add(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n + val_m;

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }
}

void execute_addi(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm = (instruction >> 10) & 0xFFF;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n + imm;

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }
}