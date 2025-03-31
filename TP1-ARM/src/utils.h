#ifndef UTILS_H
#define UTILS_H

#include <stdint.h>

// Prototipos de funciones auxiliares
void execute_hlt(uint32_t instruction);
void execute_adds(uint32_t instruction);
void execute_addis_0(uint32_t instruction);
void execute_addis_1(uint32_t instruction);
void execute_subs(uint32_t instruction);
void execute_subis_0(uint32_t instruction);
void execute_subis_1(uint32_t instruction);
void execute_ands(uint32_t instruction);
void execute_eor(uint32_t instruction);
void execute_orr(uint32_t instruction);
void execute_b(uint32_t instruction);
void execute_br(uint32_t instruction);
void execute_b_cond(uint32_t instruction);
void execute_lsl(uint32_t instruction);
void execute_lsr(uint32_t instruction);
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

#endif