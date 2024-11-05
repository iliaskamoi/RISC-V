`timescale 1ns / 1ps
`include "calc.v"
module calculator_tb;

    // Inputs
    reg clk = 0;
    reg btnc = 0;
    reg btnl = 0;
    reg btnu = 0;
    reg btnr = 0;
    reg btnd = 0;
    reg [15:0] sw = 0;

    // Outputs
    wire [15:0] led;

    // Instantiate the Unit Under Test (UUT)
    calc uut (
        .clk(clk), 
        .btnc(btnc), 
        .btnl(btnl), 
        .btnu(btnu), 
        .btnr(btnr), 
        .btnd(btnd), 
        .sw(sw), 
        .led(led)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("calctb.vcd");
        $dumpvars(0, calculator_tb);  
        btnu = 1;
        #5;
        btnu = 0;
    
        btnd = 1; 
        //btnd = 1;
        {btnl, btnc, btnr} = 3'b011;
        sw = 32'h1234;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b010;
        sw = 32'h0FF0; 
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b000;
        sw = 32'h324F;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b001;
        sw = 32'h2D31;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b100;
        sw = 32'hFFFF;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b101;
        sw = 32'h7346;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b110;
        sw = 32'h0004;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b111;
        sw = 32'h0004;
        #5;
        btnd = ~btnd;
        #5;
        btnd = ~btnd;
        {btnl, btnc, btnr} = 3'b101;
        sw = 32'hFFFF;
        #10;
        $finish;
    end
      
endmodule