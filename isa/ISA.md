# Peach Console ISA specification

All 31 native instructions with readable operand syntax, the exact 16-bit encoding, and a hexadecimal example. The syntax below is a notation for your assembler to adopt; no assembler implementation is assumed.

Read fields from left to right as bits [15:12], [11:8], [7:4], [3:0]. Each hex digit is four bits. d, a, b and s are register numbers 0–15; i is an immediate nibble. x marks an unused four-bit field: its value is a don't care. Literal digits such as 0 are required opcode or function bits. Hex examples use zero for unused fields as a convenient convention.

## Instruction encoding

Every instruction is 16 bits. The primary opcode is bits [15:12]. Opcodes 0x0 through 0xE identify instructions directly. Opcode 0xF selects the special group, where bits [7:4] are the function code. The tables below are in numeric opcode order, followed by numeric function-code order within opcode 0xF.

For opcode 0xF, the remaining fields depend on the function. LUI uses function 0xF: its immediate is formed from the fixed high nibble F and the low nibble in [3:0], so its encodable immediate range is 0xF0–0xFF.

### Primary opcodes 0x0–0xE

| Opcode [15:12] | Syntax | Fields | Example | Hex | Effect |
| :---: | :--- | :---: | :--- | :---: | :--- |
| `0x0` | `ADD Rd, Ra, Rb` | `0 d a b` | `ADD R3, R1, R2` | `0312` | Rd = Ra + Rb |
| `0x1` | `SUB Rd, Ra, Rb` | `1 d a b` | `SUB R3, R1, R2` | `1312` | Rd = Ra - Rb |
| `0x2` | `AND Rd, Ra, Rb` | `2 d a b` | `AND R3, R1, R2` | `2312` | Rd = Ra & Rb |
| `0x3` | `OR Rd, Ra, Rb` | `3 d a b` | `OR R3, R1, R2` | `3312` | Rd = Ra \| Rb |
| `0x4` | `XOR Rd, Ra, Rb` | `4 d a b` | `XOR R3, R1, R2` | `4312` | Rd = Ra ^ Rb |
| `0x5` | `SLT Rd, Ra, Rb` | `5 d a b` | `SLT R3, R1, R2` | `5312` | Rd = 1 if signed16(Ra) < signed16(Rb), otherwise 0 |
| `0x6` | `SLTU Rd, Ra, Rb` | `6 d a b` | `SLTU R3, R1, R2` | `6312` | Rd = 1 if unsigned16(Ra) < unsigned16(Rb), otherwise 0 |
| `0x7` | `ADDI Rd, Ra, imm4` | `7 d a i` | `ADDI R3, R1, -1` | `731F` | Rd = Ra + signed imm4 |
| `0x8` | `LOADI Rd, imm8` | `8 d imm8` | `LOADI R3, 0xFF` | `83FF` | Rd = zero-extended imm8 |
| `0x9` | `LOAD Rd, [Ra + imm4]` | `9 d a i` | `LOAD R3, [R1 - 2]` | `931E` | Rd = MEM16[Ra + signed imm4] |
| `0xA` | `STORE [Ra + imm4], Rb` | `A i a b` | `STORE [R1 + 2], R3` | `A213` | MEM16[Ra + signed imm4] = Rb |
| `0xB` | `BEQ Ra, Rb, off4` | `B i a b` | `BEQ R1, R2, -1` | `BF12` | Branch if Ra == Rb |
| `0xC` | `BNE Ra, Rb, off4` | `C i a b` | `BNE R1, R2, -1` | `CF12` | Branch if Ra != Rb |
| `0xD` | `BLT Ra, Rb, off4` | `D i a b` | `BLT R1, R2, -1` | `DF12` | Branch if signed Ra < signed Rb |
| `0xE` | `BGE Ra, Rb, off4` | `E i a b` | `BGE R1, R2, -1` | `EF12` | Branch if signed Ra >= signed Rb |

### Opcode 0xF: special instructions

| Opcode [15:12] | Function [7:4] | Syntax | Fields | Example | Hex | Effect |
| :---: | :---: | :--- | :---: | :--- | :---: | :--- |
| `0xF` | `0x0` | `JMP Rb` | `F x 0 b` | `JMP R10` | `F00A` | PC = Rb; target is a word address |
| `0xF` | `0x1` | `CALL Rb` | `F x 1 b` | `CALL R10` | `F01A` | SP -= 1; MEM16[SP] = PC + 1; PC = original Rb |
| `0xF` | `0x2` | `RET` | `F x 2 x` | `RET` | `F020` | PC = MEM16[SP]; SP += 1 |
| `0xF` | `0x3` | `HALT` | `F x 3 x` | `HALT` | `F030` | Stop execution until reset |
| `0xF` | `0x4` | `NOP` | `F x 4 x` | `NOP` | `F040` | No architectural change except PC += 1 |
| `0xF` | `0x5` | `MUL Rd, Rb` | `F d 5 b` | `MUL R3, R2` | `F352` | Rd = low16(Rd × Rb) |
| `0xF` | `0x6` | `NOT Rd` | `F d 6 x` | `NOT R3` | `F360` | Rd = bitwise complement of Rd |
| `0xF` | `0x7` | `SHL Rd, Rs` | `F d 7 s` | `SHL R3, R2` | `F372` | Rd = low16(old_Rd << (old_Rs & 15)); ignore Rs[15:4] |
| `0xF` | `0x8` | `SHR Rd, Rs` | `F d 8 s` | `SHR R3, R2` | `F382` | Shift old_Rd right by old_Rs[3:0]; old_Rs[4] selects logical (0) or arithmetic (1); ignore Rs[15:5] |
| `0xF` | `0x9` | `PUSH Rs` | `F s 9 x` | `PUSH R1` | `F190` | SP -= 1; MEM16[SP] = original Rs |
| `0xF` | `0xA` | `POP Rd` | `F d A 0` | `POP R3` | `F3A0` | Rd = MEM16[SP]; SP += 1 |
| `0xF` | `0xB` | `RNG Rd` | `F d B x` | `RNG R3` | `F3B0` | Rd = current RNG state; RNG then advances |
| `0xF` | `0xC` | `SHLI Rd, imm4` | `F d C i` | `SHLI R3, 8` | `F3C8` | Rd = Rd << unsigned imm4 |
| `0xF` | `0xD` | `SHRI Rd, imm4` | `F d D i` | `SHRI R3, 8` | `F3D8` | Rd = Rd >> unsigned imm4; logical zero fill |
| `0xF` | `0xE` | `JMP_REL8 off8` | `F hi E lo` | `JMP_REL8 -2` | `FFEE` | PC = PC + 1 + signed off8 |
| `0xF` | `0xF` | `LUI Rd, imm8` | `F d F i` | `LUI R3, 0xF0` | `F3F0` | Rd = imm8 << 8; only F0–FF encodes LUI |
## Registers, memory, and execution

R0 always reads as zero and ignores writes. R15 is SP; initialize it before stack use. Registers, instructions, and memory words are 16 bits. Arithmetic results keep the low 16 bits.

Memory is word-addressed: each address identifies one 16-bit word. Consecutive addresses identify consecutive words; odd and even addresses are distinct. LOAD and STORE transfer one word, and their signed offsets count words. MEM16[address] denotes the word at that address. PC, jump targets, return addresses, pointers, and SP are word addresses. Each instruction occupies one word; normal sequential execution advances PC by 1. Address calculations, PC updates, and SP updates wrap to 16 bits.

Signed imm4 ranges from -8 to +7 for ADDI, LOAD, and STORE. LOADI accepts 0–255 and zero-extends the value. SHLI and SHRI use unsigned immediate amounts 0–15. STORE places its immediate in [11:8], not the low nibble.

MUL, NOT, SHL, SHR, SHLI, and SHRI reuse the destination as their first operand. All sources are read before the destination is written, including when operands alias.

## Branches, jumps, and stack

Conditional branch offsets are signed -8 to +7 and count words relative to PC + 1. A taken branch sets PC = PC + 1 + signed off4; otherwise PC advances by 1. An offset of -1 branches to the branch instruction itself. BLT and BGE compare signed 16-bit values.

JMP_REL8 uses a signed -128 to +127 offset split across [11:8] (high nibble) and [3:0] (low nibble). The function nibble [7:4] is always E. For -2, the offset is 0xFE and the instruction is F F E E. The target is PC + 1 + signed off8.

For either relative branch format, offset = target - (PC + 1), using word addresses and an in-range signed displacement. There is no division by two or even-address restriction.

The stack grows toward lower word addresses. CALL and PUSH decrement SP by one before storing. RET and POP read the word at SP before incrementing it by one. CALL stores PC + 1 and uses the original target-register value, including when the target is R15. PUSH R15 stores the original SP.

PUSH reads its source register from [11:8]. CALL and JMP read their target register from [3:0]. RET has no explicit operands. R15 supplies SP implicitly for CALL, RET, PUSH, and POP.

POP R15 is illegal; no illegal-instruction trap is specified. POP R0 discards the loaded word but still increments SP. POP requires the low nibble to be 0.

## Special instruction details

RNG resets to 0xACE1 and returns 0xACE1, 0x5670, 0xAB38, … on successive requests. RNG R0 discards the result but still advances the generator.

LUI accepts only immediates 0xF0–0xFF. Its function nibble is fixed at F; the immediate's low nibble occupies [3:0]. For example, LUI R3, 0xF0 encodes as F3F0. F312 is CALL R2, not LUI R3, 0x12.

To build an arbitrary 16-bit constant, load its upper byte with LOADI, shift left by 8 with SHLI, load the lower byte into a scratch register, and combine with OR.

## Encoding examples

PUSH R1 has fields F 1 9 x. Both 0xF190 and 0xF19F encode it because the low nibble is unused. JMP R10 has fields F x 0 A: function 0 is required, while [11:8] is unused.
## Comparison semantics

SLT interprets the sources as 16-bit two's-complement signed integers (-32768 to 32767). SLTU interprets them as unsigned integers (0 to 65535). Each writes the entire destination as 0x0000 or 0x0001. Sources are read before the write, so Rd may alias either source. Writes to R0 are discarded as usual.

For example, comparing 0xFFFF with 0x0001 yields 1 with SLT (-1 < 1) and 0 with SLTU (65535 is not less than 1). Signed comparison must handle overflow correctly; testing only the sign of wrapped subtraction is insufficient.

Unsigned conditional branches can use a scratch register:

```asm
SLTU R3, R1, R2
BNE R3, R0, off4   ; branch if unsigned R1 < unsigned R2
```

Signed conditions can still use BLT and BGE directly.

## Register shift control

SHL and SHR overwrite their first operand. The control comes from the value stored in Rs, not the register number. All source values, including the sign bit and control, are read before the destination write.

| Instruction | Amount | Mode | Ignored control bits |
| :--- | :--- | :--- | :--- |
| SHL Rd, Rs | Rs[3:0], 0–15 | Left shift; zero fill; discard high bits | Rs[15:4] |
| SHR Rd, Rs | Rs[3:0], 0–15 | Rs[4] = 0: logical right; zero fill | Rs[15:5] |
| SHR Rd, Rs | Rs[3:0], 0–15 | Rs[4] = 1: arithmetic right; replicate original Rd[15] | Rs[15:5] |

A zero shift amount leaves the data unchanged in either mode. Arithmetic right shift rounds signed values toward negative infinity; it is not generally equivalent to signed division rounded toward zero.

```asm
LOADI R2, 3
SHR R3, R2         ; logical right shift by 3
LOADI R2, 19       ; 0x10 | 3
SHR R3, R2         ; arithmetic right shift by 3
```

For a variable right shift, prepare control = amount & 15 for logical mode, or control = (amount & 15) | 16 for arithmetic mode. Masking can be omitted when the range is known. Preserve the original amount if it is still needed.

SHLI and SHRI use four-bit immediates (0–15). SHRI always shifts logically. There is no immediate arithmetic-right-shift instruction: load 16 + amount into a control register and use SHR.

## Assembler pseudoinstructions

MOV and NEG are assembler pseudoinstructions, each expanding to one native instruction:

| Syntax | Expansion | Example | Hex |
| :--- | :--- | :--- | :---: |
| MOV Rd, Rs | ADDI Rd, Rs, 0 | MOV R3, R2 | 7320 |
| NEG Rd | SUB Rd, R0, Rd | NEG R3 | 1303 |

Negation wraps modulo 65536, including 0x8000 -> 0x8000.

