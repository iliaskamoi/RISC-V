`include "datapath.v"
module multicycle #(
    parameter [31:0] INITIAL_PC = 32'h00400000
)
(
    input wire clk, 
    input wire rst, 
    input wire [31:0] instr, 
    output wire [31:0] PC, 
    output wire [31:0] dAdress, 
    output wire [31:0] dWriteData, 
    output reg MemRead,
    output reg MemWrite,
    output wire [31:0] dReadData, 
    output wire [31:0] WriteBackData
);

wire [8:0] address = dAdress;
DATA_MEMORY ram(
    .clk(clk),
    .we(MemWrite),
    .addr(address),
    .din(dWriteData),
    .dout(dReadData)
);

// Variables for datapath instantiation.
wire Zero;
reg PCSrc = 0, ALUSrc = 0, RegWrite = 0, MemToReg = 0, loadPC = 0;
reg [3:0] ALUCtrl = 0;
reg [3:0] FSM_state = 0;

reg the_if = 0, id = 0, ex = 0, mem = 0, wb = 0;

datapath datapath_inst(
    .clk(clk), 
    .rst(rst), 
    .instr(instr), 
    .PCSrc(PCSrc), 
    .ALUSrc(ALUSrc), 
    .RegWrite(RegWrite), 
    .MemToReg(MemToReg), 
    .ALUCtrl(ALUCtrl), 
    .loadPC(loadPC), 
    .PC(PC), 
    .Zero(Zero), 
    .dAdress(dAdress), 
    .dWriteData(dWriteData), 
    .dReadData(dReadData), 
    .WriteBackData(WriteBackData)
);  



//fsm parameters. Bits are assigned abstractly
parameter [2:0] IF = 3'b000;
parameter [2:0] ID = 3'b001;
parameter [2:0] EX = 3'b010;
parameter [2:0] MEM = 3'b011;
parameter [2:0] WB = 3'b100;

// Parameters for opcode.
wire [6:0] OPCODE  = instr[6:0];
parameter [6:0] IMMEDIATE = 7'b0010011;
parameter [6:0] NON_IMMEDIATE = 7'b0110011;
parameter [6:0] LW = 7'b0000011;
parameter [6:0] SW = 7'b0100011;
parameter [6:0] BEQ = 7'b1100011;

//Parameters for funct3.
wire [2:0] FUNCT3 = instr[14:12];
parameter [2:0] ARITHMETIC = 3'b000;
parameter [2:0] SLT = 3'b010;
parameter [2:0] XOR = 3'b100;
parameter [2:0]  OR = 3'b110;
parameter [2:0] AND = 3'b111;
parameter [2:0] SLL = 3'b001;
parameter [2:0] SRL = 3'b101;
parameter [2:0] SRA = 3'b101;
parameter [2:0] MEMORY_TRANSACTION = 3'b010;
parameter [2:0] BRANCH = 3'b000;

// Parameters for ALU
parameter [3:0] ALU_AND = 4'b0000;
parameter [3:0] ALU_OR  = 4'b0001;
parameter [3:0] ALU_ADD = 4'b0010;
parameter [3:0] ALU_SUB = 4'b0110;
parameter [3:0] ALU_LESS = 4'b0111;
parameter [3:0] ALU_LR = 4'b1000;
parameter [3:0] ALU_LL = 4'b1001;
parameter [3:0] ALU_NR = 4'b1010;
parameter [3:0] ALU_XOR = 4'b1101;

always @(posedge clk) begin
    if ( FSM_state == WB || rst )
        FSM_state <= IF;
    else 
        FSM_state <= FSM_state + 1;
end

always @(posedge clk) begin
    case ( FSM_state )
        IF : begin 
            {the_if, id, mem, ex, wb} = 5'b10000;
            loadPC <= 0;
        end
        ID : {the_if, id, mem, ex, wb} = 5'b01000;
        MEM : {the_if, id, mem, ex, wb} = 5'b00100;
        EX : {the_if, id, mem, ex, wb} = 5'b00010;
        WB : begin 
            {the_if, id, mem, ex, wb} = 5'b00001;
            loadPC <= 1;
        end
    endcase
end

always @(*) begin
    if ( OPCODE == NON_IMMEDIATE ) begin
        case ( FUNCT3 )
            ARITHMETIC : begin 
                if ( instr[30] == 0 )
                    ALUCtrl = ALU_ADD;
                else 
                    ALUCtrl = ALU_SUB;
            end
            SLT : ALUCtrl = ALU_LESS;
            XOR : ALUCtrl = ALU_XOR;
            OR : ALUCtrl = ALU_OR;
            AND : ALUCtrl = ALU_AND;
            SLL : ALUCtrl = ALU_LL;
            SRL : begin
                if ( instr[30] == 0 )
                    ALUCtrl = ALU_LR;
                else if ( instr[30] == 1 )
                    ALUCtrl = ALU_NR;
            end
        endcase
    end
    else if ( OPCODE == IMMEDIATE ) begin
        case ( FUNCT3 )
            ARITHMETIC : ALUCtrl = ALU_ADD;
            SLT : ALUCtrl = ALU_LESS;
            XOR : ALUCtrl = ALU_XOR;
            OR : ALUCtrl = ALU_OR;
            AND : ALUCtrl = ALU_AND;
            SLL : ALUCtrl = ALU_LL;
            SRL : begin
                if ( instr[30] == 0 )
                    ALUCtrl = ALU_LR;
                else if ( instr[30] == 1 )
                    ALUCtrl = ALU_NR;
            end
        endcase
    end
    else if ( OPCODE == LW || OPCODE == SW )
        ALUCtrl = ALU_ADD;
    else if ( OPCODE == BEQ )
        ALUCtrl = ALU_SUB;
end

// ALUSrc
    always @(*) begin
        if ( OPCODE == LW || OPCODE == SW || OPCODE == IMMEDIATE  )
            ALUSrc = 1;
        else 
            ALUSrc = 0; 
    end

// MemRead and MemWrite
    always @(posedge mem) begin
        if ( OPCODE == LW ) begin
            MemRead <= 1;
            MemWrite <= 0;
        end
        else if ( OPCODE == SW ) begin
            MemWrite <= 1;
            MemRead <= 0;
        end
    end

    always @(posedge wb) begin
        if ( OPCODE == SW || OPCODE == BEQ )
            RegWrite <= 0;
        else
            RegWrite <= 1;
    end

    always @(*) begin
        if ( OPCODE == LW )
            MemToReg = 1;
        else
            MemToReg = 0;
    end
//  loadPC and PCSRc
    always @(posedge wb) begin
        
        if ( OPCODE == BEQ )
        begin
            PCSrc <= 1;
        end
        else
            PCSrc <= 0;
    end

    always @(*) begin
        
        if ( wb == 1 )
            loadPC = 1;
        else if (the_if == 1)
            loadPC = 0;
    end
endmodule