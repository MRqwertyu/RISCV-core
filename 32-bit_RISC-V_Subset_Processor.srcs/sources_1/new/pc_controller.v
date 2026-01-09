`timescale 1ns / 1ps

module pc_controller (
    input         clk,
    input         reset,
    input         Stall,
    input         PCSrc,        // 1 = Misprediction Correction (Flush/Jump)
    input  [31:0] BranchTarget, // The "Correct" address (from EX stage)
    
    input  [31:0] PredictedPC,  // <--- NEW: Input from Branch Predictor
    
    
    output [31:0] PC_plus_4,
    output [31:0] PC
);

    reg [31:0] pc_reg;

    assign PC = pc_reg;
    assign PC_plus_4 = pc_reg + 32'd4;
    
    wire PC_Enable = !Stall; // Only toggle when NOT stalled
    
    always @(posedge clk) begin
        if (reset) begin
            pc_reg <= 32'd0;
        end else if (PC_Enable) begin
            // Priority 1: Correction from EX stage (Misprediction)
            if (PCSrc) begin
                pc_reg <= BranchTarget; 
            end 
            // Priority 2: Prediction from IF stage (BPU)
            else begin
                pc_reg <= PredictedPC; 
            end
        end
    end
endmodule