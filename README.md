5-Stage Pipelined RISC-V Processor
A 32-bit RISC-V subset processor designed in Verilog HDL, featuring a classic 5-stage pipeline, speculative execution, dynamic branch prediction, and logic-level power optimizations. This project demonstrates advanced computer architecture concepts, specifically focusing on resolving control and data hazards without relying on software-inserted NOPs.

Key Features
5-Stage Pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Writeback (WB).

Hybrid Branch Predictor: Implements a dynamic tournament-style predictor (Local vs. Global History) with a Branch Target Buffer (BTB). Achieves an 80% reduction in control hazard stall cycles during iterative workloads compared to a static predictor.

Robust Hazard Handling:

Data Forwarding: Custom Hazard Unit bypasses data directly from EX/MEM and MEM/WB pipeline registers to the ALU, resolving Read-After-Write (RAW) hazards instantly.

Load-Use Stalling: Automatically freezes the IF/ID stages and inserts a single bubble when forwarding is physically impossible.

Microcoded Control Unit: Utilizes a Microinstruction ROM (rom.mem) for instruction decoding, making the control logic flexible, scalable, and easy to debug compared to hardwired logic.

Power Optimizations:

Operand Isolation: ALU inputs are gated to 0 during non-arithmetic instructions (like Branches and Jumps) to prevent unnecessary transistor switching and reduce dynamic power consumption.

Clock Gating: Pipeline registers are explicitly gated using stall signals to prevent wasteful clock toggling.

Supported Instruction Set (RV32I Subset)
This core implements a carefully selected subset of the RISC-V base integer instruction set to exercise all major architectural paths:

R-Type (Arithmetic/Logic): add, sub, and, or

I-Type (Immediate): addi

Memory Access: lw (Load Word), sw (Store Word)

Control Flow: beq (Branch if Equal), jal (Jump and Link)

Architecture Overview
IF (Fetch): Fetches instructions from Distributed RAM. The PC is speculatively updated every cycle using the Hybrid Branch Predictor.

ID (Decode): Reads from the Register File and queries the Microcode ROM for control signals. The Hazard Unit continuously monitors for Load-Use dependencies here.

EX (Execute): Houses the main ALU. Resolves data hazards via 3-to-1 multiplexers controlled by the Hazard Unit. Validates branch predictions and triggers a pipeline flush (2-cycle penalty) if a misprediction is detected.

MEM (Memory): Handles synchronous Data Memory reads and writes.

WB (Writeback): Writes the final ALU result or Memory read data back to the Register File, featuring internal bypassing for simultaneous read/write cycles.

Tools & Prerequisites
Hardware Description Language: Verilog (IEEE 1364-2001)

Synthesis & Simulation: Xilinx Vivado Design Suite

Target Hardware: Designed for Xilinx Artix-7 FPGA (Synthesizes to <1% LUT/FF utilization)

Compiler (Optional): RISC-V GNU Toolchain (riscv-none-elf-gcc) for compiling C code into hex mem files.
