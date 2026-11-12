# Peach Console instruction reference

All 31 instructions with readable operand syntax, the exact 16-bit encoding, and a hexadecimal example. The syntax below is a notation for your assembler to adopt; no assembler implementation is assumed.

Read fields from left to right as bits [15:12], [11:8], [7:4], [3:0]. Each hex digit is four bits. d, a and b are register numbers 0–15; i is an immediate nibble. x marks an unused four-bit field: its value is a don't care. Literal digits such as 0 are required opcode or function bits. Hex examples use zero for unused fields as a convenient convention.

## Arithmetic logic and memory

| Syntax | Fields | Example | Hex | Effect |
| :--- | :---: | :--- | :---: | :--- |
| `ADD Rd, Ra, Rb` | `0 d a b` | `ADD R3, R1, R2` | `0312` | Rd = Ra + Rb |
| `SUB Rd, Ra, Rb` | `1 d a b` | `SUB R3, R1, R2` | `1312` | Rd = Ra - Rb |
| `AND Rd, Ra, Rb` | `2 d a b` | `AND R3, R1, R2` | `2312` | Rd = Ra & Rb |
| `OR Rd, Ra, Rb` | `3 d a b` | `OR R3, R1, R2` | `3312` | Rd = Ra \| Rb |
| `XOR Rd, Ra, Rb` | `4 d a b` | `XOR R3, R1, R2` | `4312` | Rd = Ra ^ Rb |
| `SHL Rd, Ra, Rb` | `5 d a b` | `SHL R3, R1, R2` | `5312` | Rd = Ra << (Rb & 15) |
| `SHR Rd, Ra, Rb` | `6 d a b` | `SHR R3, R1, R2` | `6312` | Rd = Ra >> (Rb & 15); logical zero fill |
| `ADDI Rd, Ra, imm4` | `7 d a i` | `ADDI R3, R1, -1` | `731F` | Rd = Ra + signed imm4 |
| `LOADI Rd, imm8` | `8 d imm8` | `LOADI R3, 0xFF` | `83FF` | Rd = zero-extended imm8 |
| `LOAD Rd, [Ra + imm4]` | `9 d a i` | `LOAD R3, [R1 - 2]` | `931E` | Rd = MEM16[Ra + signed imm4] |
| `STORE [Ra + imm4], Rb` | `A i a b` | `STORE [R1 + 2], R3` | `A213` | MEM16[Ra + signed imm4] = Rb |

Immediate ranges: imm4 = -8 to +7; LOADI imm8 = 0 to 255. Arithmetic results keep the low 16 bits. STORE puts its immediate in [11:8], not the low nibble.

R0 always reads as zero and ignores writes. R15 is SP; initialize it before stack use. RAM addresses count bytes, but LOAD and STORE transfer an entire 16-bit word. Odd addresses alias the preceding even address.

## Branches jumps and stack

Conditional branch offsets count instructions relative to PC + 2. A taken branch sets PC = PC + 2 + 2 × off4; otherwise PC advances by 2. off4 ranges from -8 to +7.

| Syntax | Fields | Example | Hex | Effect |
| :--- | :---: | :--- | :---: | :--- |
| `BEQ Ra, Rb, off4` | `B i a b` | `BEQ R1, R2, -1` | `BF12` | Branch if Ra == Rb |
| `BNE Ra, Rb, off4` | `C i a b` | `BNE R1, R2, -1` | `CF12` | Branch if Ra != Rb |
| `BLT Ra, Rb, off4` | `D i a b` | `BLT R1, R2, -1` | `DF12` | Branch if signed Ra < signed Rb |
| `BGE Ra, Rb, off4` | `E i a b` | `BGE R1, R2, -1` | `EF12` | Branch if signed Ra >= signed Rb |
| `JMP Rb` | `F x 0 b` | `JMP R10` | `F00A` | PC = Rb; target is a byte address |
| `CALL Rb` | `F x 1 b` | `CALL R10` | `F01A` | SP -= 2; MEM16[SP] = PC + 2; PC = original Rb |
| `RET` | `F x 2 x` | `RET` | `F020` | PC = MEM16[SP]; SP += 2 |
| `PUSH Rs` | `F s 9 x` | `PUSH R1` | `F190` | SP -= 2; MEM16[SP] = original Rs |
| `POP Rd` | `F d A 0` | `POP R3` | `F3A0` | Rd = MEM16[SP]; SP += 2 |
| `JMP_REL8 off8` | `F hi E lo` | `JMP_REL8 -2` | `FFEE` | PC = PC + 2 + 2 × signed off8 |

PUSH reads its source register from [11:8]. CALL and JMP read their target register from [3:0]. RET has no explicit operands. R15 supplies SP implicitly for CALL, RET, PUSH and POP.

POP R15 is illegal by definition in this ISA; the current RTL has no illegal-instruction trap. POP R0 discards the loaded value but still increments SP. PUSH R15 pushes the original SP.

JMP_REL8 uses a signed -128 to +127 offset split across [11:8] and [3:0]. For -2, off8 is 0xFE, giving F F E E. To encode a branch target: offset = (target - (PC + 2)) / 2, with an even displacement and an in-range result.

## Special arithmetic and execution

Special instructions use opcode F and funct4 in [7:4]. MUL, NOT, NEG, SHLI and SHRI reuse the destination as their first operand.

| Syntax | Fields | Example | Hex | Effect |
| :--- | :---: | :--- | :---: | :--- |
| `MUL Rd, Rb` | `F d 5 b` | `MUL R3, R2` | `F352` | Rd = low16(Rd × Rb) |
| `NOT Rd` | `F d 6 x` | `NOT R3` | `F360` | Rd = bitwise complement of Rd |
| `NEG Rd` | `F d 7 x` | `NEG R3` | `F370` | Rd = -Rd, modulo 65536 |
| `MOV Rd, Rb` | `F d 8 b` | `MOV R3, R2` | `F382` | Rd = Rb |
| `RNG Rd` | `F d B x` | `RNG R3` | `F3B0` | Rd = current RNG state; RNG then advances |
| `SHLI Rd, imm4` | `F d C i` | `SHLI R3, 8` | `F3C8` | Rd = Rd << unsigned imm4 |
| `SHRI Rd, imm4` | `F d D i` | `SHRI R3, 8` | `F3D8` | Rd = Rd >> unsigned imm4; logical zero fill |
| `LUI Rd, imm8` | `F d imm8` | `LUI R3, 0xF0` | `F3F0` | Rd = imm8 << 8; currently only F0–FF encodes LUI |
| `HALT` | `F x 3 x` | `HALT` | `F030` | Stop execution until reset |
| `NOP` | `F x 4 x` | `NOP` | `F040` | No architectural change except PC += 2 |

SHLI and SHRI immediates range from 0 to 15 and are unsigned, unlike ADDI and memory offsets. RNG resets to ACE1 and returns ACE1, 5670, AB38, … on successive requests. RNG R0 discards the output but still advances the generator.

LUI encoding limitation: the documented F d imm8 format overlaps every other special instruction. The current decoder selects LUI only when imm8[7:4] = F, so only F0–FF are usable. For example, F312 is CALL R2, not LUI R3, 0x12.

For an arbitrary 16-bit constant without LUI, load the upper byte with LOADI, shift it left by 8 with SHLI, load the lower byte into a scratch register, and combine them with OR.

## Encoding example

`PUSH R1` has fields `F 1 9 x`. Both `0xF190` and `0xF19F` encode the same operation because the low nibble is unused. By contrast, `JMP R10` has fields `F x 0 A`: the `0` in [7:4] is required to select JMP.
