`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2025 03:01:26
// Design Name: 
// Module Name: testbench
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


// testbench.v
// This testbench will drive the datapath and dump waves.

module testbench;

    // Define the clock period (10 time units = 1 cycle)
    localparam CLK_PERIOD = 10;

    // Signals to connect to the datapath
    reg clk;
    reg reset;

    // Instantiate the "Device Under Test" (DUT)
    datapath dut (
        .clk(clk),
        .reset(reset)
    );

    // 1. Clock Generation
    // This 'always' block generates a clock signal
    // that flips every 5 time units (half the period)
    initial begin
        clk = 1'b0;
    end
    always #(CLK_PERIOD / 2) begin
        clk = ~clk;
    end

    // 2. Simulation Control (Reset and Waveform Dump)
    initial begin
        // --- Setup Waveform Dumping ---
        // This tells the simulator to record all signals from the 'dut'
        // and save them to a file named "wave.vcd"
        $dumpfile("wave.vcd");
        $dumpvars(0, dut); // Dump all variables, starting from module 'dut'

        // --- Initialize and Reset the Processor ---
        $display("Simulation Started: Asserting Reset...");
        reset = 1'b1; // Assert reset
        
        #(CLK_PERIOD * 2); // Hold reset for 2 clock cycles
        
        $display("Reset De-asserted: Processor starting.");
        reset = 1'b0; // De-assert reset, processor starts fetching from 0x0

        // --- Run the Simulation ---
        #(CLK_PERIOD * 200); // Let the simulation run for 200 cycles

        // --- End the Simulation ---
        $display("Simulation Finished: 200 cycles elapsed.");
        $finish; // Stop the simulation
    end

endmodule