# Peach Console

Peach Console is a custom FPGA-targeted 16-bit game console architecture featuring a custom ISA, C-based emulator, MMIO subsystem, and fixed-function graphics hardware for 2D games.

## Features

- Custom 16-bit ISA
- 16 general-purpose registers
- Stack support with CALL/RET
- Branch instructions
- Memory-mapped I/O architecture
- Pseudo-random number generation unit
- C-based software emulator
- FPGA-oriented CPU datapath design

## Current Progress

Implemented:
- Instruction decoder
- Control unit
- Register file
- ALU
- Branch unit
- Stack operations
- CALL/RET support
- Memory subsystem
- RNG unit
- CPU execution loop

In progress:
- Assembler
- Compiler frontend
- VGA graphics output
- Controller input
- MMIO peripherals
- Fixed-function graphics accelerator
- RTL/FPGA implementation

## Architecture Goals

The project is designed to explore:
- CPU architecture
- ISA design
- FPGA development
- Emulator development
- Compiler construction
- Memory-mapped I/O
- Graphics hardware
- Low-level systems programming

## Planned Hardware

The planned hardware platform includes:
- Custom CPU core
- Fixed-function graphics processor
- VGA video output
- Controller interface
- Memory-mapped peripherals
- FPGA deployment

## Current Project Structure

```text
software_emulator/ -> software CPU emulator
Console_RTL/       -> FPGA implementation
ISA/               -> ISA documentation
Compiler/          -> compiler and toolchain
```
