#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "shell.h"

// OPERACIONES ARITMÉTICAS
#define OPCODE_ADD      0x458   // ADD (register)
#define OPCODE_ADDI     0x488   // ADD (immediate)
#define OPCODE_ADDS     0x558   // ADDS (register)


// --- Prototipos de funciones auxiliares ---

// Aritméticas
void execute_add(uint32_t instruction);

void execute_adds(uint32_t instruction);

void process_instruction()
{
    uint32_t instruction = mem_read_32(CURRENT_STATE.PC);

    printf("Instrucción: 0x%x\n", instruction);

    // Defino la recuperación de bits para diferentes tamaños de opcode
    uint32_t opcode11 = (instruction >> 21) & 0x7FF;

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;

    switch(opcode11) {
        case OPCODE_ADD:
            printf("ADD\n");
            execute_add(instruction);
            break;
        case OPCODE_ADDS:
            printf("ADDS\n");
            execute_adds(instruction);
            break;
        default:
            printf("Instrucción no implementada: 0x%x (opcode 0x%x)\n", instruction, opcode11);
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