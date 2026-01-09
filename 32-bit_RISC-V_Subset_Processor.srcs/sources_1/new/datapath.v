`timescale 1ns / 1ps

module datapath (
    input clk,
    input reset,
    output [31:0] debug_pc,   // Add this
    output [31:0] debug_data  // Add this
);

    // --- Control Signals ---
    wire        RegWrite_ID, MemToReg_ID, MemRead_ID, MemWrite_ID, Branch_ID, ALUSrc_ID;
    wire [3:0]  ALUControl_ID;
    wire        RegWrite_EX, MemToReg_EX, MemRead_EX, MemWrite_EX, Branch_EX, ALUSrc_EX;
    wire [3:0]  ALUControl_EX;
    wire        RegWrite_MEM, MemToReg_MEM, MemRead_MEM, MemWrite_MEM;
    wire        RegWrite_WB, MemToReg_WB;
    wire Is_Arithmetic;


    // --- Hazard / Prediction Signals ---
    wire        PCSrc, Stall_IF, Stall_ID, Flush_ID, Flush_EX;
    wire [1:0]  ForwardA, ForwardB;
    
    // NEW: Prediction Wires
    wire        Predict_Taken_IF, Predict_Taken_ID, Predict_Taken_EX;
    wire [31:0] Predict_Target_IF;

    // --- IF Stage ---
    wire [31:0] BranchTarget_EX;
    wire [31:0] PC, PC_plus_4;
    wire [31:0] Instr_IF;

    // --- ID Stage ---
    wire [31:0] Instr_ID, PC_plus_4_ID;
    wire [31:0] ReadData1_ID, ReadData2_ID, Immediate_ID;
    wire [4:0]  Rs1_ID, Rs2_ID, Rd_ID;

    // --- EX Stage ---
    wire [4:0]  Rs1_EX, Rs2_EX;
    wire [31:0] ReadData1_EX, ReadData2_EX, Immediate_EX;
    wire [31:0] ALU_A, ALU_B, ALUResult_EX;
    wire [4:0]  Rd_EX;
    wire        Zero_EX;
    wire [31:0] PC_EX;
    
    // --- MEM / WB Stage ---
    wire [31:0] ALUResult_MEM, StoreData_MEM, ReadData_MEM;
    wire [4:0]  Rd_MEM;
    wire [31:0] ALUResult_WB, ReadData_WB, WriteData_WB;
    wire [4:0]  Rd_WB;

    // ==================================================================
    // MODULE INSTANTIATIONS
    // ==================================================================

    // 1. BRANCH PREDICTOR (The Hybrid Model)
    branch_predictor bpu (
        .clk(clk), .reset(reset),
        // IF Stage
        .PC_IF(PC),
        .Predict_Taken(Predict_Taken_IF),
        .Predict_Target(Predict_Target_IF),
        // EX Stage (Training)
        .PC_EX(PC_EX),
        .Branch_EX(Branch_EX),
        .Actual_Taken(Zero_EX),       // For beq, Zero=1 means Taken
        .Actual_Target(BranchTarget_EX)
    );

    control ctrl_unit (
        .Instr(Instr_ID),
        .RegWrite(RegWrite_ID), .MemToReg(MemToReg_ID), .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID), .Branch(Branch_ID), .ALUSrc(ALUSrc_ID),
        .ALUControl(ALUControl_ID), .Immediate(Immediate_ID)
    );

    hazard_unit haz_unit (
        .clk(clk), .reset(reset),
        .Rs1_ID(Rs1_ID), .Rs2_ID(Rs2_ID),
        .Rs1_EX(Rs1_EX), .Rs2_EX(Rs2_EX),
        .MemRead_EX(MemRead_EX), .RegWrite_EX(RegWrite_EX), .Rd_EX(Rd_EX),
        .Branch_EX(Branch_EX), .Zero_EX(Zero_EX),
        .Predict_Taken_EX(Predict_Taken_EX), // <--- Connected new signal
        .RegWrite_MEM(RegWrite_MEM), .Rd_MEM(Rd_MEM),
        .RegWrite_WB(RegWrite_WB), .Rd_WB(Rd_WB),
        .PCSrc(PCSrc), .Stall_IF(Stall_IF), .Stall_ID(Stall_ID),
        .Flush_ID(Flush_ID), .Flush_EX(Flush_EX),
        .ForwardA(ForwardA), .ForwardB(ForwardB)
    );

    // IF Stage 
    pc_controller pc_ctrl (
        .clk(clk), .reset(reset),
        .Stall(Stall_IF),
        .PCSrc(PCSrc),
        .BranchTarget(BranchTarget_EX),
        .PredictedPC(Predict_Target_IF), // <--- Connected BPU Target
        .PC_plus_4(PC_plus_4),
        .PC(PC)
    );

    memory main_mem (
        .clk(clk),
        .InstrAddr(PC), .InstrData(Instr_IF),
        .DataAddr(ALUResult_MEM), .DataWrite(StoreData_MEM),
        .MemRead(MemRead_MEM), .MemWrite(MemWrite_MEM), .DataRead(ReadData_MEM)
    );

    if_id_reg pipe_if_id (
        .clk(clk), .reset(reset),
        .Stall(Stall_ID), .Flush(Flush_ID),
        .IN_Instr(Instr_IF),
        .IN_PC_plus_4(PC_plus_4),
        .IN_Predict_Taken(Predict_Taken_IF),   // <--- Pass Prediction
        .OUT_Instr(Instr_ID),
        .OUT_PC_plus_4(PC_plus_4_ID),
        .OUT_Predict_Taken(Predict_Taken_ID)   // <--- Pass Prediction
    );

    // ID Stage 
    register_file reg_file (
        .clk(clk), .RegWrite(RegWrite_WB),
        .ReadAddr1(Instr_ID[19:15]), .ReadAddr2(Instr_ID[24:20]),
        .WriteAddr(Rd_WB), .WriteData(WriteData_WB),
        .ReadData1(ReadData1_ID), .ReadData2(ReadData2_ID)
    );
    
    assign Rs1_ID = Instr_ID[19:15];
    assign Rs2_ID = Instr_ID[24:20];
    assign Rd_ID  = Instr_ID[11:7];

    id_ex_reg pipe_id_ex (
        .clk(clk), .reset(reset), .Flush(Flush_EX),
        .IN_RegWrite(RegWrite_ID), .IN_MemToReg(MemToReg_ID),
        .IN_MemRead(MemRead_ID), .IN_MemWrite(MemWrite_ID),
        .IN_Branch(Branch_ID), .IN_ALUControl(ALUControl_ID),
        .IN_ALUSrc(ALUSrc_ID), .IN_ReadData1(ReadData1_ID),
        .IN_ReadData2(ReadData2_ID), .IN_Immediate(Immediate_ID),
        .IN_Rd(Rd_ID), .IN_PC(PC_plus_4_ID - 4), 
        .IN_Rs1(Rs1_ID), .IN_Rs2(Rs2_ID),
        .IN_Predict_Taken(Predict_Taken_ID),  // <--- Pass Prediction
        
        .OUT_RegWrite(RegWrite_EX), .OUT_MemToReg(MemToReg_EX),
        .OUT_MemRead(MemRead_EX), .OUT_MemWrite(MemWrite_EX),
        .OUT_Branch(Branch_EX), .OUT_ALUControl(ALUControl_EX),
        .OUT_ALUSrc(ALUSrc_EX), .OUT_ReadData1(ReadData1_EX),
        .OUT_ReadData2(ReadData2_EX), .OUT_Immediate(Immediate_EX),
        .OUT_Rd(Rd_EX), .OUT_PC(PC_EX),
        .OUT_Rs1(Rs1_EX), .OUT_Rs2(Rs2_EX),
        .OUT_Predict_Taken(Predict_Taken_EX) // <--- To Hazard Unit
    );

    // EX Stage
    assign BranchTarget_EX = PC_EX + Immediate_EX;

// 1. Define the Detection Signal

    assign Is_Arithmetic = ( (Instr_ID[6:0] == 7'h33) || (Instr_ID[6:0] == 7'h13) ) && 
                           (RegWrite_ID == 1'b1) && 
                           (MemRead_ID == 1'b0) && 
                           (MemWrite_ID == 1'b0);

    // 2. Operand Isolation Logic (The Muxes)
    // Note: This logic belongs in the EX stage, but let's assume Is_Arithmetic is passed to EX
    // or calculated in EX using Instr_EX or control signals.
    
    // Assuming you calculated 'Is_Arithmetic_EX' correctly for the Execute stage:
    
    assign ALU_A = (Is_Arithmetic == 1'b0) ? 32'd0 : // If NOT arithmetic -> 0
                   (ForwardA == 2'b00) ? ReadData1_EX :
                   (ForwardA == 2'b10) ? ALUResult_MEM :
                   (ForwardA == 2'b11) ? WriteData_WB :
                   ReadData1_EX;

    assign ALU_B = (Is_Arithmetic == 1'b0) ? 32'd0 : // If NOT arithmetic -> 0
                   (ForwardB == 2'b00) ? ReadData2_EX :
                   (ForwardB == 2'b10) ? ALUResult_MEM :
                   (ForwardB == 2'b11) ? WriteData_WB :
                   ReadData2_EX;                  

    wire [31:0] ALU_B_Muxed = (ALUSrc_EX) ? Immediate_EX : ALU_B;

    alu main_alu (
        .A(ALU_A), .B(ALU_B_Muxed),
        .ALUControl(ALUControl_EX), .Result(ALUResult_EX), .Zero(Zero_EX)
    );

    ex_mem_reg pipe_ex_mem (
        .clk(clk), .reset(reset),
        .IN_RegWrite(RegWrite_EX), .IN_MemToReg(MemToReg_EX),
        .IN_MemRead(MemRead_EX), .IN_MemWrite(MemWrite_EX),
        .IN_ALUResult(ALUResult_EX), .IN_StoreData(ALU_B), .IN_Rd(Rd_EX),
        .OUT_RegWrite(RegWrite_MEM), .OUT_MemToReg(MemToReg_MEM),
        .OUT_MemRead(MemRead_MEM), .OUT_MemWrite(MemWrite_MEM),
        .OUT_ALUResult(ALUResult_MEM), .OUT_StoreData(StoreData_MEM), .OUT_Rd(Rd_MEM)
    );

    // MEM Stage
    mem_wb_reg pipe_mem_wb (
        .clk(clk), .reset(reset),
        .IN_RegWrite(RegWrite_MEM), .IN_MemToReg(MemToReg_MEM),
        .IN_ReadData(ReadData_MEM), .IN_ALUResult(ALUResult_MEM), .IN_Rd(Rd_MEM),
        .OUT_RegWrite(RegWrite_WB), .OUT_MemToReg(MemToReg_WB),
        .OUT_ReadData(ReadData_WB), .OUT_ALUResult(ALUResult_WB), .OUT_Rd(Rd_WB)
    );

    // WB Stage
    assign WriteData_WB = (MemToReg_WB) ? ReadData_WB : ALUResult_WB;
    
    assign debug_pc = PC;
    assign debug_data = WriteData_WB;
    
endmodule