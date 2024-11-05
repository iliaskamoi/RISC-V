`include "alu.v"
`include "regfile.v"
module datapath #(
    parameter [31:0] INITIAL_PC = 32'h00400000
)
(
    input wire clk, 
    input wire rst, 
    input wire [31:0] instr, 
    input wire PCSrc, 
    input wire ALUSrc, 
    input wire RegWrite, 
    input wire MemToReg, 
    input wire [3:0] ALUCtrl,
    input wire loadPC,
    output wire [31:0] PC, 
    output wire Zero,
    output reg [31:0] dAdress, 
    output reg [31:0] dWriteData, 
    input wire [31:0] dReadData, 
    output reg [31:0] WriteBackData
);

localparam [6:0] IMMEDIATE = 7'b0010011;
localparam [6:0] NON_IMMEDIATE = 7'b0110011;
localparam [6:0] LW = 7'b0000011;
localparam [6:0] SW = 7'b0100011;
localparam [6:0] BEQ = 7'b1100011;

reg [31:0] PC_inter = INITIAL_PC; 
reg [31:0] op2;
wire [31:0] result_inter;
reg [11:0] immediate;

// Immediate Generation
wire [31:0] complete_sign_extended_immediate = {sign_extended_immediate[31:12], immediate[11:0]};
wire [31:0] sign_extended_immediate = $signed(immediate)>>>20;
wire [11:0] beq_immediate = { instr[31], instr[7], instr[11:8], 1'b0};
wire [11:0] sw_immediate = { instr[31:25], instr[11:7]}; 
wire [11:0] lw_arithm_immediate = instr[31:20];
//Write Back
reg [31:0] register_write_data; 

assign PC = PC_inter;

wire [31:0] readData1, readData2;

regfile registers(
    .clk(clk), 
    .write(RegWrite), 
    .readReg1(instr[19:15]), 
    .readReg2(instr[24:20]), 
    .writeReg(instr[11:7]), 
    .writeData(result_inter), 
    .readData1(readData1), 
    .readData2(readData2)
);

always @(*) begin
    if ( instr[6:0] == SW )
        immediate = sw_immediate;
    else if ( instr[6:0] == BEQ )
        immediate = beq_immediate<<1;
    else if ( instr[6:0] == IMMEDIATE || instr[6:0] == LW )
        immediate =  lw_arithm_immediate;
end

always @(posedge clk) begin
    if ( rst == 1 )
        PC_inter <= INITIAL_PC; 
end

// ALU
    alu alu_inst(
        .op1(readData1), 
        .op2(op2), 
        .alu_op(ALUCtrl), 
        .zero(Zero), 
        .result(result_inter)
    );

    always @(*) begin
        if ( ALUSrc == 1 )
            op2 = complete_sign_extended_immediate;
        else if ( ALUSrc == 0 )
            op2 = readData2;
    end 

//Branch Target
    always @(posedge loadPC) begin
        if ( PCSrc == 1 )
            PC_inter <= PC_inter + immediate;
        else if ( PCSrc == 0 )
            PC_inter <= PC_inter + 4;
    end 

// Write Back
    always @(*) begin
        if ( MemToReg == 1 ) begin
            WriteBackData = dReadData;
        end
        else if ( MemToReg == 0 ) begin
            WriteBackData = result_inter;
        end        

end

always @(*) begin
    dAdress = result_inter;
end

always @(*) begin
    dWriteData = readData2;
end
endmodule
