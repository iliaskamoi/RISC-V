`timescale 1ns / 1ps
`include "multicycle.v"
`include "ram.v"
`include "rom.v"
module riscv_core_testbench;

// Clock and reset signals
reg clk = 0; 
reg rst = 0;
wire [31:0] instr; 
wire [31:0] PC;
wire [31:0] dAdress; 
wire [31:0] dWriteData;
wire MemRead;
wire MemWrite;
wire [31:0] dReadData; 
wire [31:0] WriteBackData;
reg [8:0] ProgramAdress = 0;


// Instantiate the RISC-V core
multicycle core(
    .clk(clk),
    .rst(rst),
    .instr(instr),
    .PC(PC),
    .dAdress(dAdress),
    .dWriteData(dWriteData),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .dReadData(dReadData),
    .WriteBackData(WriteBackData)
);

INSTRUCTION_MEMORY rom(
    .clk(clk),
    .addr(PC),
    .dout(instr)
);

always begin
    #5; 
    clk <= ~clk; 
end

initial begin
    $dumpfile("final.vcd");
    $dumpvars(0, riscv_core_testbench);  
    rst = 1;
    rst = 0;
    #50000;
    $finish;
end

endmodule