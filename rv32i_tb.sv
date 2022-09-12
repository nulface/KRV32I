`timescale 1ns/1ns
module rv32i_TB();

logic clk, reset_;
logic [31:0] ram [31:0];

logic [31:0] inst;
logic [31:0] pc;
logic [31:0] addr;
logic [31:0] str;
logic [31:0] ld;

RV32I cpu (clk, reset_, inst, pc, addr, str, ld);



always #10 clk = !clk;

always_ff @ (posedge clk)
	inst <= ram[pc[31:2]];


initial begin

$dumpfile("waves.vcd");
$dumpvars;


$readmemh("../program.txt", ram);


reset_ = 1;
clk = 1;
ld = 32'hF;
#1;
reset_ = 0;
#1;
reset_ = 1;
#1;


#10;

end




endmodule
