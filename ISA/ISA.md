# Peach Console ISA

## Overview

- Instruction width: 16 bits
- Registers: 16 (`R0–R15`)
- Word size: 16 bits (2 bytes)
- Stack grows downward
- Fixed-width instruction encoding
- FPGA-oriented architecture

---

# Register Conventions

| Register | Purpose |
|---|---|
| R0 | Constant zero register (writes ignored) |
| R1–R14 | General-purpose registers |
| R15 | Stack pointer (`SP`) |

---

# Top-Level Encoding

| bit[15] | Group |
|---|---|
| 0 | ALU group |
| 1 | Non-ALU group |

---

# ALU Group

## Common Format

| Bits | Field |
|---|---|
| [15:12] | Opcode |
| [11:8] | `rd` |
| [7:4] | `rs1` |
| [3:0] | `rs2` or `imm4` |

## Encoding

```text
[15:12] [11:8] [7:4] [3:0]
opcode   rd      rs1    rs2/imm4
```

## Instructions

| Opcode | Instruction | Semantics |
|---|---|---|
| 000 | ADD | `rd = rs1 + rs2` |
| 001 | SUB | `rd = rs1 - rs2` |
| 010 | AND | `rd = rs1 & rs2` |
| 011 | OR | `rd = rs1 \| rs2` |
| 100 | XOR | `rd = rs1 ^ rs2` |
| 101 | SHL | `rd = rs1 << (rs2 & 0xF)` |
| 110 | SHR | `rd = rs1 >> (rs2 & 0xF)` |
| 111 | ADDI | `rd = rs1 + sign_extend(imm4)` |

---

# Non-ALU Group

## Common Format

| Bits | Field |
|---|---|
| [15:12] | Opcode |
| [11:0] | Instruction-specific payload |

---

# LOADI

## Encoding

```text
[15:12] [11:8] [7:0]
1 000    rd      imm8
```

## Semantics

```text
rd = zero_extend(imm8)
```

---

# LOAD

## Encoding

```text
[15:12] [11:8] [7:4] [3:0]
1 001    rd      rs      imm4
```

## Semantics

```text
rd = MEM[rs + sign_extend(imm4)]
```

---

# STORE

## Encoding

```text
[15:12] [11:8] [7:4] [3:0]
1 010    rd      rs      imm4
```

## Semantics

```text
MEM[rs + sign_extend(imm4)] = rd
```

---

# Branch Instructions

## Common Format

```text
[15:12] [11:8] [7:4] [3:0]
opcode   rs1     rs2     off4
```

| Opcode | Instruction | Condition |
|---|---|---|
| 1011 | BEQ | `rs1 == rs2` |
| 1100 | BNE | `rs1 != rs2` |
| 1101 | BLT | `signed(rs1) < signed(rs2)` |
| 1110 | BGE | `signed(rs1) >= signed(rs2)` |

## Branch Semantics

```text
PC = PC + 2 + sign_extend(off4)
```

if the condition is true.

---

# Special Group

## Common Format

```text
[15:12] [11:8] [7:4] [3:0]
1 111    rd      funct4  extra
```

---

# Core Special Instructions

| funct4 | Instruction | Semantics |
|---|---|---|
| 0000 | JMP | `PC = rd` |
| 0001 | CALL | Push return address and jump |
| 0010 | RET | Return from subroutine |
| 0011 | HALT | Stop execution |
| 0100 | NOP | No operation |
| 0101 | MUL | `rd = rd * rs` |
| 0110 | NOT | `rd = ~rd` |
| 0111 | NEG | `rd = -rd` |
| 1000 | MOV | `rd = rs` |
| 1001 | PUSH | Push register onto stack |
| 1010 | POP | Pop value from stack |
| 1011 | RNG | `rd = next_random16()` |
| 1100 | SHLI | Shift left immediate |
| 1101 | SHRI | Shift right immediate |

---

# Stack Operations

## CALL

```text
SP = SP - 2
MEM[SP] = PC + 2
PC = rd
```

## RET

```text
PC = MEM[SP]
SP = SP + 2
```

## PUSH

```text
SP = SP - 2
MEM[SP] = rd
```

## POP

```text
rd = MEM[SP]
SP = SP + 2
```

---

# Custom Encodings

# JMP_REL8

## Encoding

```text
[15:12] [11:8] [7:4] [3:0]
1 111 off8[7:4] 1110 off8[3:0]
```

## Semantics

```text
off8 = {off8[7:4], off8[3:0]}
PC = PC + 2 + sign_extend(off8)
```

---

# LUI

## Encoding

```text
[15:12] [11:8] [7:0]
1 111    rd      imm8
```

## Semantics

```text
rd = zero_extend(imm8) << 8
```
