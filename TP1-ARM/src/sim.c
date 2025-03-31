#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "shell.h"
#include "utils.h"

// OPCODES
#define OPCODE_HLT      0x6A2  // HLT
#define OPCODE_ADDS     0x558  // ADDS (register)
#define OPCODE_ADDIS_0  0x588  // ADDS (immediate). SHIFT=000
#define OPCODE_ADDIS_1  0x58A  // ADDS (immediate). SHIFT=010
#define OPCODE_SUBS     0x758  // SUBS (register). CMP SI RD=XZR
#define OPCODE_SUBIS_0  0x788  // SUBIS (immediate). SHIFT=000. CMPI SI RD=XZR
#define OPCODE_SUBIS_1  0x78A  // SUBIS (immediate). SHIFT=010. CMPI SI RD=XZR
#define OPCODE_ANDS     0x750  // ANDS (shifted register)
#define OPCODE_EOR      0x650  // EOR (shifted register)
#define OPCODE_ORR      0x550  // ORR (shifted register)
#define OPCODE_B        0x5    // B
#define OPCODE_BR       0x6B0  // BR
#define OPCODE_BCOND    0x54   // B.COND
#define OPCODE_LSL      0x69B  // LSL (immediate)
#define OPCODE_LSR      0x69A  // LSR (immediate)
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

void process_instruction()
{
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);
    printf("Instrucción: 0x%x\n", instruction);

    // Defino la recuperación de bits para diferentes tamaños de opcode
    uint32_t opcode_11 = (instruction >> 21) & 0x7FF;
    uint32_t opcode_6 = (instruction >> 26) & 0x3F;
    uint32_t opcode_8 = (instruction >> 24) & 0x7F;
    printf("Opcode 11 bits: 0x%x\n", opcode_11);
    printf("Opcode 6 bits: 0x%x\n", opcode_6);
    printf("Opcode 8 bits: 0x%x\n", opcode_8);
    
    switch(opcode_11) {
        case OPCODE_HLT:
            execute_hlt(instruction);
            return;
        case OPCODE_ADDS:
            printf("ADDS\n");
            execute_adds(instruction);
            return;
        case OPCODE_ADDIS_0:
            printf("ADDIS (SHIFT=000)\n");
            execute_addis_0(instruction);
            return;
        case OPCODE_ADDIS_1:
            printf("ADDIS (SHIFT=010)\n");
            execute_addis_1(instruction);
            return;
        case OPCODE_SUBS:
            printf("SUBS\n");
            execute_subs(instruction);
            return;
        case OPCODE_SUBIS_0:
            printf("SUBIS (SHIFT=000)\n");
            execute_subis_0(instruction);
            return;
        case OPCODE_SUBIS_1:
            printf("SUBIS (SHIFT=010)\n");
            execute_subis_1(instruction);
            return;
        case OPCODE_ANDS:
            printf("ANDS\n");
            execute_ands(instruction);
            return;
        case OPCODE_EOR:
            printf("EOR\n");
            execute_eor(instruction);
            return;
        case OPCODE_ORR:
            printf("ORR\n");
            execute_orr(instruction);
            return;
        case OPCODE_LSL:
            printf("LSL\n");
            execute_lsl(instruction);
            return;
        case OPCODE_LSR:
            printf("LSR\n");
            execute_lsr(instruction);
            return;
        case OPCODE_MOVZ:
            printf("MOVZ\n");
            execute_movz(instruction);
            return;
        case OPCODE_BR:
            printf("BR\n");
            execute_br(instruction);
            return;
        case OPCODE_STUR:
            printf("STUR\n");
            execute_stur(instruction);
            return;
        case OPCODE_STURB:
            printf("STURB\n");
            execute_sturb(instruction);
            return;
        case OPCODE_STURH:
            printf("STURH\n");
            execute_sturh(instruction);
            return;
        case OPCODE_LDUR:
            printf("LDUR\n");
            execute_ldur(instruction);
            return;
        case OPCODE_LDURB:
            printf("LDURB\n");
            execute_ldurb(instruction);
            return;
        case OPCODE_LDURH:
            printf("LDURH\n");
            execute_ldurh(instruction);
            return;
    }

    switch (opcode_6) {
        case OPCODE_B:
            printf("B\n");
            execute_b(instruction);
            return;
    }

    switch (opcode_8) {
        case OPCODE_CBZ:
            printf("CBZ\n");
            execute_cbz(instruction);
            break;
        case OPCODE_CBNZ:
            printf("CBNZ\n");
            execute_cbnz(instruction);
            break;
        case OPCODE_BCOND:
            printf("B.COND\n");
            execute_b_cond(instruction);
            break;
        default:
            printf("Instrucción 0x%x no reconocida\n", instruction);
            RUN_BIT = 0;
            break;
    }
}