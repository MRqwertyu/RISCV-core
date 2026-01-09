`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2025 00:05:29
// Design Name: 
// Module Name: ex_mem_reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// ex_mem_reg.v
// Pipeline Register between EX and MEM
module ex_mem_reg (
    input         clk,
    input         reset,

    // Inputs from EX
    input         IN_RegWrite,
    input         IN_MemToReg,
    input         IN_MemRead,
    input         IN_MemWrite,
    input  [31:0] IN_ALUResult,
    input  [31:0] IN_StoreData, // Data from rs2, to be stored
    input  [4:0]  IN_Rd,

    // Outputs to MEM
    output reg        OUT_RegWrite,
    output reg        OUT_MemToReg,
    output reg        OUT_MemRead,
    output reg        OUT_MemWrite,
    output reg [31:0] OUT_ALUResult,
    output reg [31:0] OUT_StoreData,
    output reg [4:0]  OUT_Rd
);

    always @(posedge clk) begin
        if (reset) begin
            OUT_RegWrite <= 1'b0;
            OUT_MemToReg <= 1'b0;
            OUT_MemRead  <= 1'b0;
            OUT_MemWrite <= 1'b0;
            OUT_ALUResult<= 32'd0;
            OUT_StoreData<= 32'd0;
            OUT_Rd       <= 5'd0;
        end else begin
            // Load data from EX
            OUT_RegWrite <= IN_RegWrite;
            OUT_MemToReg <= IN_MemToReg;
            OUT_MemRead  <= IN_MemRead;
            OUT_MemWrite <= IN_MemWrite;
            OUT_ALUResult<= IN_ALUResult;
            OUT_StoreData<= IN_StoreData;
            OUT_Rd       <= IN_Rd;
        end
    end

endmodule
