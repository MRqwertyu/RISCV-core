`timescale 1ns / 1ps

module control (
    input  [31:0] Instr,
    output        RegWrite,
    output        MemToReg,
    output        MemRead,
    output        MemWrite,
    output        Branch,
    output        ALUSrc,
    output [31:0] Immediate,
    output [3:0]  ALUControl
);

    // Decode fields
    wire [6:0] opcode = Instr[6:0];
    wire [2:0] funct3 = Instr[14:12];
    wire [6:0] funct7 = Instr[31:25];
    
    // Intermediate ALUOp signal from ROM
    wire [1:0] ALUOp; 

    // ==================================================================
    // 1. MICROCODE ROM LOGIC
    // ==================================================================
    
    // Define the ROM (128 entries, 8 bits wide)
    reg [7:0] micro_rom [0:127];
    integer i;

    initial begin
        // A. Initialize everything to 0 (NOP) first
        for (i = 0; i < 128; i = i + 1) begin
            micro_rom[i] = 8'd0;
        end

        // B. Load the file
        // IMPORTANT: "microcode.mem" must be in your simulation folder
        $readmemh("final_fix.mem", micro_rom);
    end

    // Map the 8-bit ROM data to the wires
    // Format: {RegWrite, MemToReg, MemRead, MemWrite, Branch, ALUSrc, ALUOp[1:0]}
    assign {RegWrite, MemToReg, MemRead, MemWrite, Branch, ALUSrc, ALUOp} = micro_rom[opcode];


    // ==================================================================
    // 2. SUB-MODULES (ALU Control & Immediate Gen)
    // ==================================================================
    
    // These stay exactly the same as before
    alu_control alu_ctrl (
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7), .ALUControl(ALUControl)
    );

    immediate_generator imm_gen (
        .Instr(Instr), .Immediate(Immediate)
    );

endmodule


// --- SUBMODULES (Keep these exactly as they were) ---

module immediate_generator (input [31:0] Instr, output reg [31:0] Immediate);
    wire [6:0] opcode = Instr[6:0];
    wire sign = Instr[31];
    always @(*) begin
        case (opcode)
            7'b0010011, 7'b0000011, 7'b1100111: Immediate = {{21{sign}}, Instr[30:20]}; 
            7'b0100011: Immediate = {{21{sign}}, Instr[30:25], Instr[11:7]}; 
            7'b1100011: Immediate = {{20{sign}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0}; 
            7'b1101111: Immediate = {{12{sign}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0}; 
            default:    Immediate = 32'd0;
        endcase
    end
endmodule

module alu_control (input [1:0] ALUOp, input [2:0] funct3, input [6:0] funct7, output reg [3:0] ALUControl);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010; 
            2'b01: ALUControl = 4'b0110; 
            2'b10: begin 
                if (funct3 == 3'b000 && funct7 == 7'b0100000) ALUControl = 4'b0110; 
                else if (funct3 == 3'b110) ALUControl = 4'b0001; 
                else if (funct3 == 3'b111) ALUControl = 4'b0000; 
                else ALUControl = 4'b0010; 
            end
            default: ALUControl = 4'b0010;
        endcase
    end
endmodule