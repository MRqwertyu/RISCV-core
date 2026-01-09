`timescale 1ns / 1ps

module if_id_reg (
    input         clk,
    input         reset,
    input         Stall,
    input         Flush,
    
    // Inputs from IF
    input  [31:0] IN_Instr,
    input  [31:0] IN_PC_plus_4,
    input         IN_Predict_Taken, // <--- NEW: Prediction from BPU

    // Outputs to ID
    output reg [31:0] OUT_Instr,
    output reg [31:0] OUT_PC_plus_4,
    output reg        OUT_Predict_Taken // <--- NEW: Passed to ID
);

    always @(posedge clk) begin
        // PRIORITY 1: Sync Reset
        if (reset) begin
            OUT_Instr         <= 32'h00000013; // NOP
            OUT_PC_plus_4     <= 32'd0;
            OUT_Predict_Taken <= 1'b0;         // <--- Reset to Not Taken
        end 
        // PRIORITY 2: Flush
        else if (Flush) begin
            OUT_Instr         <= 32'h00000013; 
            OUT_PC_plus_4     <= 32'd0;
            OUT_Predict_Taken <= 1'b0;         // <--- Flush to Not Taken
        end 
        // PRIORITY 3: Normal Load
        else if (!Stall) begin
            OUT_Instr         <= IN_Instr;
            OUT_PC_plus_4     <= IN_PC_plus_4;
            OUT_Predict_Taken <= IN_Predict_Taken; // <--- Pass the bit
        end
        // Else: Stall (keep values)
    end

endmodule