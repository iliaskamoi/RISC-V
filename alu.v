 module alu #(
    parameter [3:0] ALU_AND = 4'b0000,
    parameter [3:0] ALU_OR  = 4'b0001,
    parameter [3:0] ALU_ADD = 4'b0010,
    parameter [3:0] ALU_SUB = 4'b0110,
    parameter [3:0] ALU_LESS = 4'b0111,
    parameter [3:0] ALU_LR = 4'b1000,
    parameter [3:0] ALU_LL = 4'b1001,
    parameter [3:0] ALU_NR = 4'b1010,
    parameter [3:0] ALU_XOR = 4'b1101
 )
 (
    input wire [31:0] op1, op2,
    input wire [3:0] alu_op,
    output reg zero,
    output reg [31:0] result 
 );
integer op1_int;
integer op2_int;

always @(*) begin
    op1_int = op1;
    op2_int = op2;
    case (alu_op)
        ALU_AND: result = (op1) & (op2);
        ALU_OR: result = op1 | op2;
        ALU_ADD: result = (op1) + (op2);
        ALU_SUB: result = op1 - op2;
        ALU_LESS: result = ((op1_int) < (op2_int)) ? 32'b1 : 32'b0;
        ALU_LR: result = op1 >> op2[4:0];
        ALU_LL: result = op1 << op2[4:0];
        ALU_NR: result = (op1_int) >>> op2[4:0];
        ALU_XOR: result = op1 ^ op2;
        default: result = 0; 
    endcase
    zero = (result == 32'b0);
end
endmodule