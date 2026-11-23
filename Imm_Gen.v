module imm_gen(input [31:0] inst,input [2:0] imm_sel,output reg [31:0] imm);
always @(*) begin
case(imm_sel)
3'b000: imm={{20{inst[31]}},inst[31:20]}; //i
3'b001: imm={{20{inst[31]}},inst[31:25],inst[11:7]}; //s
3'b010: imm={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0}; //b
3'b011: imm={inst[31:12],12'b0}; //u
3'b100: imm={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; //j
default: imm=32'b0;
endcase
end
endmodule
`timescale 1ns/1ps
module tb_imm_gen;
reg [31:0] inst;
reg [2:0] imm_sel;
wire [31:0] imm;
integer errors;
imm_gen uut(inst,imm_sel,imm);
task check(input [63:0] name,input [31:0] i,input [2:0] s,input [31:0] exp);
begin
inst=i;imm_sel=s;
#10;
if(imm===exp) $display("PASS %0s inst=%h imm=%h",name,inst,imm);
else begin $display("FAIL %0s inst=%h imm=%h expected=%h",name,inst,imm,exp); errors=errors+1; end
end
endtask
initial begin
errors=0;
check("I +10",32'h00A00093,3'b000,32'h0000000A); //addi x1,x0,10
check("I -1",32'hFFF00093,3'b000,32'hFFFFFFFF); //addi x1,x0,-1
check("S 0",32'h00302023,3'b001,32'h00000000); //sw x3,0(x0)
check("B +8",32'h00418463,3'b010,32'h00000008); //beq x3,x4,8
check("U",32'h123450B7,3'b011,32'h12345000); //lui x1,0x12345
check("J +8",32'h0080036F,3'b100,32'h00000008); //jal x6,8
$display("--- IMMGEN done, errors=%0d ---",errors);
$stop;
end
endmodule