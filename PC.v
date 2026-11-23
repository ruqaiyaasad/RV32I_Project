module p_c(input clk,input reset,input pc_sel,input [31:0] alu_result,output reg [31:0] pc,output [31:0] pc_plus4);
assign pc_plus4=pc+32'd4;
always @(posedge clk or posedge reset) begin
if(reset)
pc<=32'h00000000;
else if(pc_sel)
pc<={alu_result[31:1],1'b0}; //bit 0 forced to 0 (needed for jalr, harmless for branch/jal)
else
pc<=pc_plus4;
end
endmodule
`timescale 1ns/1ps
module tb_pc;
reg clk,reset,pc_sel;
reg [31:0] alu_result;
wire [31:0] pc,pc_plus4;
integer errors;
p_c uut(clk,reset,pc_sel,alu_result,pc,pc_plus4);
initial clk=0;
always #5 clk=~clk;
task check(input [63:0] name,input [31:0] exp);
begin
if(pc===exp) $display("PASS %0s pc=%h",name,pc);
else begin $display("FAIL %0s pc=%h expected=%h",name,pc,exp); errors=errors+1; end
end
endtask
initial begin
errors=0;
reset=1;pc_sel=0;alu_result=0;
@(negedge clk); check("RESET",32'h00000000);
reset=0;
@(negedge clk); check("SEQ",32'h00000004);
@(negedge clk); check("SEQ",32'h00000008);
@(negedge clk); check("SEQ",32'h0000000C);
pc_sel=1;alu_result=32'h00000040; //branch/jal taken
@(negedge clk); check("BRANCH",32'h00000040);
alu_result=32'h00000081; //jalr, bit 0 must be cleared
@(negedge clk); check("JALR",32'h00000080);
if(pc_plus4===32'h00000084) $display("PASS pc_plus4=%h",pc_plus4);
else begin $display("FAIL pc_plus4=%h expected=00000084",pc_plus4); errors=errors+1; end
pc_sel=0;
@(negedge clk); check("SEQ",32'h00000084);
reset=1;#1; check("ASYNC RESET",32'h00000000);
$display("--- PC done, errors=%0d ---",errors);
$stop;
end
endmodule