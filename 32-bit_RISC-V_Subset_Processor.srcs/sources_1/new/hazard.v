`timescale 1ns / 1ps

module hazard_unit (
    input         clk,
    input         reset,

    // Stall Inputs
    input  [4:0]  Rs1_ID,
    input  [4:0]  Rs2_ID,
    
    // Forwarding Inputs
    input  [4:0]  Rs1_EX, 
    input  [4:0]  Rs2_EX,

    // Pipeline State Inputs
    input         MemRead_EX, 
    input         RegWrite_EX,
    input  [4:0]  Rd_EX,
    input         Branch_EX,
    input         Zero_EX,
    input         Predict_Taken_EX, // <--- NEW: What we predicted earlier

    input         RegWrite_MEM,
    input  [4:0]  Rd_MEM,
    
    input         RegWrite_WB,
    input  [4:0]  Rd_WB,

    // Outputs
    output reg [1:0]  ForwardA,
    output reg [1:0]  ForwardB,
    output reg        PCSrc,
    output reg        Stall_IF,
    output reg        Stall_ID,
    output reg        Flush_ID,
    output reg        Flush_EX
);

    wire stall_load_use_raw;
    wire mispredict_raw;

    // 1. Hazard Detection
    assign stall_load_use_raw = MemRead_EX && 
                                ( (Rd_EX == Rs1_ID) || (Rd_EX == Rs2_ID) ) &&
                                (Rd_EX != 5'd0);

    // 2. Branch Misprediction Logic (UPDATED)
    // Mispredict if: It is a branch AND (Actual Outcome != Predicted Outcome)
    // For beq: Zero_EX=1 means Taken.
    assign mispredict_raw = Branch_EX && (Zero_EX != Predict_Taken_EX); 

    // 3. Output Logic
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;
        
        // Forwarding Logic
        if (RegWrite_MEM && (Rd_MEM != 0) && (Rd_MEM == Rs1_EX)) ForwardA = 2'b10;
        else if (RegWrite_WB && (Rd_WB != 0) && (Rd_WB == Rs1_EX)) ForwardA = 2'b11;

        if (RegWrite_MEM && (Rd_MEM != 0) && (Rd_MEM == Rs2_EX)) ForwardB = 2'b10;
        else if (RegWrite_WB && (Rd_WB != 0) && (Rd_WB == Rs2_EX)) ForwardB = 2'b11;
        
        // Control Signals
        if (reset) begin
            PCSrc    = 1'b0;
            Stall_IF = 1'b0;
            Stall_ID = 1'b0;
            Flush_ID = 1'b0;
            Flush_EX = 1'b0;
        end else begin
            PCSrc    = mispredict_raw;
            Stall_IF = stall_load_use_raw;
            Stall_ID = stall_load_use_raw;
            Flush_EX = stall_load_use_raw || mispredict_raw;
            Flush_ID = mispredict_raw;
        end
    end
endmodule