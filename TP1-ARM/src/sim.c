#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "shell.h"

// OPCODES
#define OPCODE_HLT      0x6A2  // HLT
#define OPCODE_ADDS     0x558  // ADDS (register)
#define OPCODE_ADDIS_0  0x588  // ADDS (immediate). SHIFT=000
#define OPCODE_ADDIS_1  0x58A  // ADDS (immediate). SHIFT=010
#define OPCODE_SUBS     0x758  // SUBS (register)
#define OPCODE_SUBIS_0  0x788  // SUBIS (immediate). SHIFT=000
#define OPCODE_SUBIS_1  0x78A  // SUBIS (immediate). SHIFT=010
#define OPCODE_CMP      0x759  // CMP (register)
// #define OPCODE_CMPI     0xF1   // CMP (immediate) ES IGUAL A SUBIS
#define OPCODE_ANDS     0x750  // ANDS (shifted register)
#define OPCODE_EOR      0x650  // EOR (shifted register)
#define OPCODE_ORR      0x550  // ORR (shifted register)
// #define OPCODE_B        0x5    // B. REVISAR
// #define OPCODE_BR       0x___ // BR. REVISAR
// #define OPCODE_B.COND   0x54   // B.COND. REVISAR
#define OPCODE_LSL      0x34D  // LSL (immediate)
// #define OPCODE_LSR      0x34D  // LSR (immediate) ES IGUAL A LSL. REVISAR
#define OPCODE_STUR     0x7C0  // STUR
#define OPCODE_STURB    0x1C0  // STURB
#define OPCODE_STURH    0x3C0  // STURH
#define OPCODE_LDUR     0x7C2  // LDUR
#define OPCODE_LDURB    0x1C2  // LDURB
#define OPCODE_LDURH    0x3C2  // LDURH
#define OPCODE_MOVZ     0x694  // MOVZ
#define OPCODE_ADD      0x458  // ADD (register)
#define OPCODE_ADDI_0   0x488  // ADD (immediate). SHIFT=000
#define OPCODE_ADDI_1   0x48A  // ADD (immediate). SHIFT=010
#define OPCODE_MUL      0x4D8  // MUL
#define OPCODE_CBZ      0xB4   // CBZ
#define OPCODE_CBNZ     0xB5   // CBNZ

// --- Prototipos de funciones auxiliares ---
void execute_hlt(uint32_t instruction);
void execute_adds(uint32_t instruction);
void execute_addis_0(uint32_t instruction);
void execute_addis_1(uint32_t instruction);
void execute_subs(uint32_t instruction);
void execute_subis_0(uint32_t instruction);
void execute_subis_1(uint32_t instruction);
void execute_cmp(uint32_t instruction);
// void execute_cmpi(uint32_t instruction);
void execute_ands(uint32_t instruction);
void execute_eor(uint32_t instruction);
void execute_orr(uint32_t instruction);
// void execute_b(uint32_t instruction);
// void execute_br(uint32_t instruction);
// void execute_b_cond(uint32_t instruction);
void execute_lsl(uint32_t instruction);
// void execute_lsr(uint32_t instruction);
void execute_stur(uint32_t instruction);
void execute_sturb(uint32_t instruction);
void execute_sturh(uint32_t instruction);
void execute_ldur(uint32_t instruction);
void execute_ldurb(uint32_t instruction);
void execute_ldurh(uint32_t instruction);
void execute_movz(uint32_t instruction);
void execute_add(uint32_t instruction);
void execute_addi_0(uint32_t instruction);
void execute_addi_1(uint32_t instruction);
void execute_mul(uint32_t instruction);
void execute_cbz(uint32_t instruction);
void execute_cbnz(uint32_t instruction);


void process_instruction()
{
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);
    printf("Instrucción: 0x%x\n", instruction);

    // Defino la recuperación de bits para diferentes tamaños de opcode
    uint32_t opcode_6 = (instruction >> 26) & 0x3F;
    uint32_t opcode_8 = (instruction >> 24) & 0x7F;
    uint32_t opcode_11 = (instruction >> 21) & 0x7FF;
    printf("Opcode 6 bits: 0x%x\n", opcode_6);
    printf("Opcode 8 bits: 0x%x\n", opcode_8);
    printf("Opcode 11 bits: 0x%x\n", opcode_11);

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
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

void execute_adds(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n + val_m;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }
}

void execute_addis(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm = (instruction >> 10) & 0xFFF;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n + imm;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }
}