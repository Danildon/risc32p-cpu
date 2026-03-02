# risc32p-cpu
This repository contains an experimental implementation of a custom 32-bit pipelined processor (RISC32P) written in SystemVerilog and simulated using Xilinx Vivado.  The project is a modular HDL design intended for learning, experimentation, and future refinement.

Features

-  32-bit custom RISC architecture

-  5-stage pipeline:
  -  Instruction Fetch (IF)
  -  Instruction Decode (ID)
  -  Execute (EX)
  -  Memory (MEM)
  -  Writeback (WB)

-  Modular SystemVerilog design:
  -  Separate control unit and datapath
  -  Unified memory model
  -  8 general-purpose registers
  -  Immediate, memory, stack, and branch instructions
  -  Simulation testbench with program loading


Instruction Examples:
-  Supported instructions include:
-  Arithmetic: ADD, SUB, AND, INC
-  Data movement: MOV, LDM (load immediate), LDD, STD
-  Stack: PUSH, POP
-  Control flow: JMP, CALL, RET
-  I/O: OUT, IN
-  Interrupt handling support


Project Structure:

  src/
    risc32p_cpu_top.sv
    risc32p_if_stage.sv
    risc32p_id_stage.sv
    risc32p_ex_stage.sv
    risc32p_mem_stage.sv
    risc32p_wb_stage.sv
    risc32p_regfile.sv
    risc32p_control_unit.sv
    risc32p_types.sv
  
  testbench/
    risc32p_tb.sv
  
  program/
    program.asm
    program.mem


Status:

This is an early development version!!!

Known limitations:
-  Some pipeline hazards are not fully resolved
-  Forwarding and stall logic are incomplete
-  Certain instructions may not behave correctly in simulation

Goals:
-  Complete hazard detection and forwarding
-  Improve ISA definition
-  Add assembler tooling
-  FPGA deployment

Tools:
-  SystemVerilog
-  Xilinx Vivado Simulator
-  Custom memory initialization tools
