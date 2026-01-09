`timescale 1ns / 1ps
// register_file.v
// The 32x32-bit Register File
module register_file (
    input         clk,       // Clock
    input         RegWrite,  // Write enable signal (from WB stage)
    input  [4:0]  ReadAddr1, // Address for rs1 (from ID stage)
    input  [4:0]  ReadAddr2, // Address for rs2 (from ID stage)
    input  [4:0]  WriteAddr, // Address for rd (from WB stage)
    input  [31:0] WriteData, // Data to write (from WB stage)
    output [31:0] ReadData1, // Data from rs1
    output [31:0] ReadData2  // Data from rs2
);

    // 32-entry array of 32-bit registers
    reg [31:0] registers [0:31];

    // Initialization (optional, good for simulation)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'd0;
        end
    end

// Internal Forwarding / Bypass for simultaneous Read/Write
    assign ReadData1 = (ReadAddr1 == 0) ? 32'd0 :
                       ((ReadAddr1 == WriteAddr) && RegWrite) ? WriteData : // <--- THE FIX
                       registers[ReadAddr1];

    assign ReadData2 = (ReadAddr2 == 0) ? 32'd0 :
                       ((ReadAddr2 == WriteAddr) && RegWrite) ? WriteData : // <--- THE FIX
                       registers[ReadAddr2];

    // Synchronous Write Port (on positive clock edge)
    always @(posedge clk) begin
        if (RegWrite && (WriteAddr != 5'd0)) begin
            // Only write if RegWrite is high AND not writing to x0
            registers[WriteAddr] <= WriteData;
        end
    end

endmodule