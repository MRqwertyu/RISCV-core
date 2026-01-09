`timescale 1ns / 1ps

module memory (
    input         clk,
    // Instruction Fetch Port
    input  [31:0] InstrAddr,
    output [31:0] InstrData,

    // Data Memory Port
    input  [31:0] DataAddr,
    input  [31:0] DataWrite,
    input         MemRead,  // Read enable
    input         MemWrite, // Write enable
    output [31:0] DataRead
);

    // 1. Memory Array (32-bit wide, 256 words deep)
    reg [31:0] mem [0:255]; 

    // 2. Variable declaration must be OUTSIDE the begin block
    integer i; 

    initial begin
        // Initialize memory to 0
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 32'd0;
        end
        
        // Load the program
        $readmemh("complex_test.mem", mem);
    end

    // 3. Instruction Fetch
    // Shift right by 2 (divide by 4) to convert Byte Address to Word Index
    assign InstrData = mem[InstrAddr[9:2]];

    // 4. Data Read
    assign DataRead = (MemRead) ? mem[DataAddr[9:2]] : 32'd0;

    // 5. Data Write
    always @(posedge clk) begin
        if (MemWrite) begin
            mem[DataAddr[9:2]] <= DataWrite;
        end
    end

endmodule