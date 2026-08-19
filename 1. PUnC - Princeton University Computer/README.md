# PUnC: Princeton University Computer

PUnC is a 16-bit LC-3-style processor written in Verilog. It implements a small sequential CPU with a separate control unit and datapath, including an 8-register file, condition codes, an ALU, program counter, instruction register, indirect-address register, and 128-word memory.

## Files

- `PUnC.v` - Top-level processor module.
- `PUnCControl.v` - Control FSM that sequences instruction fetch, decode, execution, memory access, and writeback.
- `PUnCDatapath.v` - Registers, ALU, register file, memory, address selection, and NZP condition-code logic.
- `PUnC.t.v` - Simulation testbench with debug access to memory, registers, and the PC.

## Instruction Coverage

The supplied testbench includes cases for:

- Arithmetic and logic: `ADD` (register and immediate), `AND` (register and immediate), and `NOT`
- Memory operations: `LD`, `LDI`, `LDR`, `LEA`, `ST`, `STI`, and `STR`
- Control flow: `BR`, `JMP`, `JSR`, `JSRR`, and `RET`
- A multi-instruction `GCD` program

## Status

The PUnC RTL and testbench are included as a work in progress. Simulation requires the supporting modules and program images described above.
