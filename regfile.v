module regfile(
    input wire clk, write,
    input wire [4:0] readReg1, readReg2, writeReg,
    input wire [31:0] writeData,
    output reg [31:0] readData1, readData2
);
reg [31:0] registers[0:31];
integer i;
initial begin
    for (i = 0; i < 32; i = i + 1) begin
        registers[i] = 0;
    end
end
always @(posedge clk) begin
    readData1 <= registers[readReg1];
    readData2 <= registers[readReg2];
    if (write == 1)
        registers[writeReg] <= writeData;
    
end
endmodule