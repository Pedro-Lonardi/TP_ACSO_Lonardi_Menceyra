#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "shell.h"

void execute_hlt(uint32_t instruction)
{
    printf("HLT\n");
    RUN_BIT = 0;
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
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
    
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_addis_0(uint32_t instruction)
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

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_addis_1(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm = (instruction >> 10) & 0xFFF;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n + (imm << 12);

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_subs(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n - val_m;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_subis_0(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm = (instruction >> 10) & 0xFFF;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n - imm;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_subis_1(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm = (instruction >> 10) & 0xFFF;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n - (imm << 12);

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_ands(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n & val_m;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_eor(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n ^ val_m;

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_orr(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n | val_m;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

int64_t sign_extend(int32_t value, int bits) {
    int64_t mask = (int64_t)1 << (bits - 1);
    return (int64_t)(value ^ mask) - mask;
}

void execute_b(uint32_t instruction)
{
    int imm26 = instruction & 0x3FFFFFF;
    int64_t offset = sign_extend(imm26 << 2, 28);

    if (instruction != 31) {
        NEXT_STATE.PC = CURRENT_STATE.PC + offset;
    } else {
        NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_br(uint32_t instruction)
{ 
    uint32_t rn = instruction >> 5 & 0x1F;

    if (rn != 31) {
        NEXT_STATE.PC = CURRENT_STATE.REGS[rn];
    } else {
        NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_b_cond(uint32_t instruction)
{
    int cond = instruction & 0xF;
    int imm19 = (instruction >> 5) & 0x7FFFF;

    int64_t offset = sign_extend(imm19 << 2, 21);

    // Verifica la condición unicamente para BEQ, BNE, BGT, BLT, BGE, BLE
    switch (cond) {
        case 0x0: // BEQ
            if (CURRENT_STATE.FLAG_Z) {
                printf("Cond: BEQ\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        case 0x1:  // BNE
            if (!CURRENT_STATE.FLAG_Z) {
                printf("Cond: BNE\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        case 0xC:  // BGT
            if (!CURRENT_STATE.FLAG_Z && !CURRENT_STATE.FLAG_N) {       // asumimos flag V=0 por enunciado.
                printf("Cond: BGT\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        case 0xB:  // BLT
            if (CURRENT_STATE.FLAG_N) {                                 // asumimos flag V=0 por enunciado.
                printf("Cond: BLT\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        case 0xA:  // BGE
            if (!CURRENT_STATE.FLAG_N) {                                // asumimos flag V=0 por enunciado.
                printf("Cond: BGE\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        case 0xD:  // BLE
            if (!(!CURRENT_STATE.FLAG_Z && !CURRENT_STATE.FLAG_N)) {    // asumimos flag V=0 por enunciado.
                printf("Cond: BLE\n");
                NEXT_STATE.PC = CURRENT_STATE.PC + offset;
            }
            break;
        default:
            printf("No cumple ninguna condición\n");
            NEXT_STATE.PC = CURRENT_STATE.PC + 4;
            break;
        }
}

void execute_lsl(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imms = (instruction >> 10) & 0x3F;

    int shift = 63 - imms;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n << shift;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}


void execute_lsr(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int immr = (instruction >> 16) & 0x3F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t result = val_n >> immr;

    NEXT_STATE.FLAG_N = (result < 0);
    NEXT_STATE.FLAG_Z = (result == 0);

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_stur(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;

    mem_write_32(addr, (uint32_t)CURRENT_STATE.REGS[rt] & 0xFFFFFFFF);
    mem_write_32(addr + 4, (uint32_t)(CURRENT_STATE.REGS[rt] >> 32));

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_sturb(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;

    uint32_t data = CURRENT_STATE.REGS[rt] & 0xFF;
    mem_write_32(addr, data);

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_sturh(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;
    uint64_t half = CURRENT_STATE.REGS[rt] & 0xFFFF;

    uint32_t value = mem_read_32(addr);
    value = (value & 0xFFFF0000) | half;
    mem_write_32(addr, value);

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_ldur(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;

    uint64_t start = mem_read_32(addr);
    uint64_t end = mem_read_32(addr + 4);
    NEXT_STATE.REGS[rt] = (end << 32) | start;
    
    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_ldurb(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;
    uint64_t word = mem_read_32(addr & ~0x3);
    uint8_t byte = (word >> ((addr & 0x3) * 8)) & 0xFF;

    NEXT_STATE.REGS[rt] = (uint64_t)byte;

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_ldurh(uint32_t instruction) {
    int rt = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int imm9 = (instruction >> 12) & 0x1FF;
    imm9 = (imm9 << 23) >> 23;

    uint64_t addr = CURRENT_STATE.REGS[rn] + imm9;
    uint64_t word = mem_read_32(addr & ~0x3);
    uint16_t half = (word >> ((addr & 0x3) * 8)) & 0xFFFF;

    NEXT_STATE.REGS[rt] = (uint64_t)half;

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_movz(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int imm = (instruction >> 5) & 0xFFFF;

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = imm;
    }

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

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_mul(uint32_t instruction)
{
    int rd = instruction & 0x1F;
    int rn = (instruction >> 5) & 0x1F;
    int rm = (instruction >> 16) & 0x1F;

    int64_t val_n = (rn == 31) ? 0 : CURRENT_STATE.REGS[rn];
    int64_t val_m = (rm == 31) ? 0 : CURRENT_STATE.REGS[rm];
    int64_t result = val_n * val_m;

    if (rd != 31) {
        NEXT_STATE.REGS[rd] = result;
    }

    NEXT_STATE.PC = CURRENT_STATE.PC + 4;
}

void execute_cbz(uint32_t instruction)
{
    int rt = instruction & 0x1F;
    int32_t imm = (instruction >> 5) & 0x7FFFF;

    // Verifica si el imm es positivo o negativo y hace el sign-extend
    if (imm & (1 << 18)) {
        imm |= ~0x7FFFF;
    }

    int64_t offset = ((int64_t)imm << 2);

    if (CURRENT_STATE.REGS[rt] == 0) {
        NEXT_STATE.PC = CURRENT_STATE.PC + offset;
    } else {
        NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    }
}

void execute_cbnz(uint32_t instruction)
{
    int rt = instruction & 0x1F;
    int32_t imm = (instruction >> 5) & 0x7FFFF;

    // Verifica si el imm es positivo o negativo y hace el sign-extend
    if (imm & (1 << 18)) {
        imm |= ~0x7FFFF;
    }

    int64_t offset = ((int64_t)imm << 2);

    if (CURRENT_STATE.REGS[rt] != 0) {
        NEXT_STATE.PC = CURRENT_STATE.PC + offset;
    } else {
        NEXT_STATE.PC = CURRENT_STATE.PC + 4;
    }
}