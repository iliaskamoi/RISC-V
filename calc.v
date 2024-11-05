`include "alu.v"
`include "decoder.v"
module calc (
    input wire clk, btnc, btnl, btnu, btnr, btnd,
    input wire [15:0] sw,
    output reg [15:0] led = 0
);

wire signed [31:0] op1, op2;
assign op1 = {{16{accumulator[15]}}, accumulator};
assign op2 = {{16{sw[15]}}, sw};

reg [15:0] accumulator;
wire [31:0] result;
wire zero;
wire [3:0] alu_op;


alu alu1 (
    .op1(op1), 
    .op2(op2), 
    .alu_op(alu_op), 
    .zero(zero), 
    .result(result)
);
decoder dec1(.btnr(btnr), .btnl(btnl), .btnc(btnc), .alu_op(alu_op));


always @ (posedge clk or posedge btnu) begin

    if (btnu == 1)
        accumulator <= 0;
    else if (btnd == 1)
        accumulator <= result[15:0];
end
endmodule

always @ (*) begin
    led = accumulator;
end