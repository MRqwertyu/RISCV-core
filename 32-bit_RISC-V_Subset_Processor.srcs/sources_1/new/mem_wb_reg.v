`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2025 00:05:29
// Design Name: 
// Module Name: mem_wb_reg
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


// mem_wb_reg.v
// Pipeline Register between MEM and WB
module mem_wb_reg (
    input         clk,
    input         reset,

    // Inputs from MEM
    input         IN_RegWrite,
    input         IN_MemToReg,
    input  [31:0] IN_ReadData,   // Data from memory (lw)
    input  [31:0] IN_ALUResult,  // Result from ALU
    input  [4:0]  IN_Rd,

    // Outputs to WB
    output reg        OUT_RegWrite,
    output reg        OUT_MemToReg,
    output reg [31:0] OUT_ReadData,
    output reg [31:0] OUT_ALUResult,
    output reg [4:0]  OUT_Rd
);

    always @(posedge clk) begin
        if (reset) begin
            OUT_RegWrite <= 1'b0;
            OUT_MemToReg <= 1'b0;
            OUT_ReadData <= 32'd0;
            OUT_ALUResult<= 32'd0;
            OUT_Rd       <= 5'd0;
        end else begin
            // Load data from MEM
            OUT_RegWrite <= IN_RegWrite;
            OUT_MemToReg <= IN_MemToReg;
            OUT_ReadData <= IN_ReadData;
            OUT_ALUResult<= IN_ALUResult;
            OUT_Rd       <= IN_Rd;
        end
    end

endmodule
