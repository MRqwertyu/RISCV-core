`timescale 1ns / 1ps

module branch_predictor (
    input wire clk,
    input wire reset,
    
    // --- IF Stage (Making the Prediction) ---
    input wire [31:0] PC_IF,          // Current PC
    output reg        Predict_Taken,  // 1 = Jump, 0 = Stay
    output reg [31:0] Predict_Target, // Where to jump to?

    // --- EX Stage (Updating the Model) ---
    input wire [31:0] PC_EX,          // PC of the branch being resolved
    input wire        Branch_EX,      // Is it actually a branch?
    input wire        Actual_Taken,   // Did it actually jump?
    input wire [31:0] Actual_Target   // Where did it actually go?
);

    // ============================================================
    // 1. CONFIGURATION & DECLARATIONS
    // ============================================================
    localparam TABLE_SIZE = 256; 
    integer i;

    // A. Global History Register (GHR)
    reg [7:0] GHR; 
    
    // B. Pattern History Tables (2-bit saturating counters)
    reg [1:0] global_pht [0:TABLE_SIZE-1];
    reg [1:0] local_pht  [0:TABLE_SIZE-1];
    reg [1:0] choice_table [0:TABLE_SIZE-1];

    // C. Branch Target Buffer (BTB)
    reg [31:0] btb [0:TABLE_SIZE-1];
    reg        btb_valid [0:TABLE_SIZE-1];

    // D. Internal Signals (Moved out of always blocks)
    wire [7:0] idx_if;
    wire [7:0] idx_ex;
    reg        local_pred;
    reg        global_pred;
    reg        local_result_ex;
    reg        global_result_ex;

    // ============================================================
    // 2. PREDICTION LOGIC (Combinational - IF Stage)
    // ============================================================
    
    assign idx_if = PC_IF[9:2]; // Simple hash of PC

    always @(*) begin
        // Default values
        Predict_Taken = 1'b0;
        Predict_Target = PC_IF + 32'd4;
        
        // Temporary variables for reading tables
        local_pred  = local_pht[idx_if][1]; // MSB is the prediction
        global_pred = global_pht[GHR][1];   // MSB is the prediction

        // Only predict if we have seen this branch before (BTB Valid)
        if (btb_valid[idx_if]) begin
            
            // Consult the Choice Table: 1=Global, 0=Local
            if (choice_table[idx_if][1] == 1'b1) begin
                Predict_Taken = global_pred;
            end else begin
                Predict_Taken = local_pred;
            end

            // If we predict Taken, output the stored target
            if (Predict_Taken) begin
                Predict_Target = btb[idx_if];
            end
        end
    end

    // ============================================================
    // 3. UPDATE LOGIC (Synchronous - EX Stage)
    // ============================================================
    
    assign idx_ex = PC_EX[9:2];

    always @(posedge clk) begin
        if (reset) begin
            GHR <= 8'd0;
            for (i=0; i<TABLE_SIZE; i=i+1) begin
                local_pht[i]    <= 2'b01; // Weak Not Taken
                global_pht[i]   <= 2'b01; // Weak Not Taken
                choice_table[i] <= 2'b01; // Weak Prefer Local
                btb[i]          <= 32'd0;
                btb_valid[i]    <= 1'b0;
            end
        end 
        else if (Branch_EX) begin 
            
            // 1. Update Global History Register
            GHR <= {GHR[6:0], Actual_Taken};

            // 2. Update Branch Target Buffer
            if (Actual_Taken) begin
                btb[idx_ex] <= Actual_Target;
                btb_valid[idx_ex] <= 1'b1;
            end

            // 3. Update Local Predictor (2-bit Saturation)
            if (Actual_Taken) begin
                if (local_pht[idx_ex] != 2'b11) 
                    local_pht[idx_ex] <= local_pht[idx_ex] + 1;
            end else begin
                if (local_pht[idx_ex] != 2'b00) 
                    local_pht[idx_ex] <= local_pht[idx_ex] - 1;
            end

            // 4. Update Global Predictor
            if (Actual_Taken) begin
                if (global_pht[GHR] != 2'b11) 
                    global_pht[GHR] <= global_pht[GHR] + 1;
            end else begin
                if (global_pht[GHR] != 2'b00) 
                    global_pht[GHR] <= global_pht[GHR] - 1;
            end

            // 5. Update Tournament Choice
            // We need to know what the predictors WOULD HAVE predicted
            // We check the current state of the tables (MSB)
            local_result_ex  = local_pht[idx_ex][1];
            global_result_ex = global_pht[GHR][1];
            
            // Update logic: Strengthen the one that was right
            if (global_result_ex == Actual_Taken && local_result_ex != Actual_Taken) begin
                // Global right, Local wrong -> Increment (Bias towards Global)
                if (choice_table[idx_ex] != 2'b11) 
                    choice_table[idx_ex] <= choice_table[idx_ex] + 1;
            end 
            else if (local_result_ex == Actual_Taken && global_result_ex != Actual_Taken) begin
                // Local right, Global wrong -> Decrement (Bias towards Local)
                if (choice_table[idx_ex] != 2'b00) 
                    choice_table[idx_ex] <= choice_table[idx_ex] - 1;
            end
        end
    end

endmodule