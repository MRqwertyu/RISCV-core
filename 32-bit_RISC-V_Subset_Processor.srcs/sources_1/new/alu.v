`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2025 23:49:18
// Design Name: 
// Module Name: alu
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


// alu.v
// The Arithmetic Logic Unit
module alu (
    input  [31:0] A,         // Operand A
    input  [31:0] B,         // Operand B
    input  [3:0]  ALUControl, // 4-bit control signal
    output reg [31:0] Result,    // 32-bit result
    output reg        Zero      // 1-bit Zero flag (for branches)
);

    // Define ALU operation codes (can be parameters)
    localparam ALU_ADD  = 4'b0010;
    localparam ALU_SUB  = 4'b0110;
    localparam ALU_AND  = 4'b0000;
    localparam ALU_OR   = 4'b0001;
    localparam ALU_SLT  = 4'b0111; // Set on Less Than (signed)
    // Add other operations like XOR, SLL, SRL as needed

    // Combinational logic for ALU operations
    always @(*) begin
        case (ALUControl)
            ALU_ADD: Result = A + B;
            ALU_SUB: Result = A - B;
            ALU_AND: Result = A & B;
            ALU_OR:  Result = A | B;
            ALU_SLT: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            default: Result = 32'hDEADBEEF; // Default for unsupported op
        endcase
    end

    // Combinational logic for the Zero flag
    always @(*) begin
        if (Result == 32'd0) begin
            Zero = 1'b1;
        end else begin
            Zero = 1'b0;
        end
    end

endmodule
