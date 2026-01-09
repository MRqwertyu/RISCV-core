`timescale 1ns / 1ps

module id_ex_reg (
    input         clk,
    input         reset,
    input         Flush,

    // Inputs
    input         IN_RegWrite,
    input         IN_MemToReg,
    input         IN_MemRead,
    input         IN_MemWrite,
    input         IN_Branch,
    input  [3:0]  IN_ALUControl,
    input         IN_ALUSrc,
    input  [31:0] IN_ReadData1,
    input  [31:0] IN_ReadData2,
    input  [31:0] IN_Immediate,
    input  [31:0] IN_PC,
    input  [4:0]  IN_Rd,
    input  [4:0]  IN_Rs1,
    input  [4:0]  IN_Rs2,
    input         IN_Predict_Taken, // <--- NEW: Input from ID


    // Outputs
    output reg        OUT_RegWrite,
    output reg        OUT_MemToReg,
    output reg        OUT_MemRead,
    output reg        OUT_MemWrite,
    output reg        OUT_Branch,
    output reg [3:0]  OUT_ALUControl,
    output reg        OUT_ALUSrc,
    output reg [31:0] OUT_ReadData1,
    output reg [31:0] OUT_ReadData2,
    output reg [31:0] OUT_Immediate,
    output reg [31:0] OUT_PC,
    output reg [4:0]  OUT_Rd,
    output reg [4:0]  OUT_Rs1,
    output reg [4:0]  OUT_Rs2,
    output reg        OUT_Predict_Taken // <--- NEW: Output to EX (Hazard Unit)
);

    always @(posedge clk) begin
        // PRIORITY 1: Sync Reset
        if (reset) begin
            OUT_RegWrite      <= 0;
            OUT_MemToReg      <= 0;
            OUT_MemRead       <= 0;
            OUT_MemWrite      <= 0;
            OUT_Branch        <= 0;
            OUT_ALUControl    <= 0;
            OUT_ALUSrc        <= 0;
            OUT_ReadData1     <= 0;
            OUT_ReadData2     <= 0;
            OUT_Immediate     <= 0;
            OUT_PC            <= 0;
            OUT_Rd            <= 0;
            OUT_Rs1           <= 0;
            OUT_Rs2           <= 0;
            OUT_Predict_Taken <= 0; // <--- Reset
        end 
        // PRIORITY 2: Flush
        else if (Flush) begin
            OUT_RegWrite      <= 0;
            OUT_MemToReg      <= 0;
            OUT_MemRead       <= 0;
            OUT_MemWrite      <= 0;
            OUT_Branch        <= 0;
            OUT_ALUControl    <= 0;
            OUT_ALUSrc        <= 0;
            OUT_ReadData1     <= 0;
            OUT_ReadData2     <= 0;
            OUT_Immediate     <= 0;
            OUT_PC            <= 0;
            OUT_Rd            <= 0;
            OUT_Rs1           <= 0;
            OUT_Rs2           <= 0;
            OUT_Predict_Taken <= 0; // <--- Flush
        end 
        // PRIORITY 3: Normal Load
        else begin
            OUT_RegWrite      <= IN_RegWrite;
            OUT_MemToReg      <= IN_MemToReg;
            OUT_MemRead       <= IN_MemRead;
            OUT_MemWrite      <= IN_MemWrite;
            OUT_Branch        <= IN_Branch;
            OUT_ALUControl    <= IN_ALUControl;
            OUT_ALUSrc        <= IN_ALUSrc;
            OUT_ReadData1     <= IN_ReadData1;
            OUT_ReadData2     <= IN_ReadData2;
            OUT_Immediate     <= IN_Immediate;
            OUT_PC            <= IN_PC;
            OUT_Rd            <= IN_Rd;
            OUT_Rs1           <= IN_Rs1;
            OUT_Rs2           <= IN_Rs2;
            OUT_Predict_Taken <= IN_Predict_Taken; // <--- Load
        end
    end
endmodule