`timescale 1ns/1ps
module tb_program;
reg clk,reset;
integer i,errors;
reg [31:0] expected [0:31];
riscv_top uut(clk,reset);
initial clk=0;
always #5 clk=~clk;
initial begin
//expected register values after the program finishes
expected[0]=32'h00000000;
expected[1]=32'h000000EF;
expected[2]=32'hFFFFBEEF;
expected[3]=32'h0000BEEF;
expected[4]=32'h000000AA;
expected[5]=32'hDEADAAEF;
expected[6]=32'h00000123;
expected[7]=32'h0123AAEF;
expected[8]=32'hDEADAAEF;
expected[9]=32'h00000001;
expected[10]=32'h00000023;
expected[11]=32'h00000005;
expected[12]=32'h00000005;
expected[13]=32'hFFFFFFFF;
expected[14]=32'h00000001;
expected[15]=32'h00000007;
expected[16]=32'h00000007;
expected[17]=32'h00000008;
expected[18]=32'h00000005;
expected[19]=32'h0000003A;
expected[20]=32'h00000009;
expected[21]=32'h0000000A;
expected[22]=32'h0000000B;
expected[23]=32'h0000000C;
expected[24]=32'h00000006;
expected[25]=32'h00000000;
expected[26]=32'h00000148;
expected[27]=32'h00001070;
expected[28]=32'h0000014C;
expected[29]=32'h00000154;
expected[30]=32'hDEADBEEF;
expected[31]=32'h00000037;
errors=0;
reset=1;
#12 reset=0;
#1000; //88 instructions need less than 100 cycles (10ns each)
for(i=0;i<32;i=i+1) begin
if(uut.u_rf.q[i]===expected[i]) $display("PASS x%0d = %h",i,uut.u_rf.q[i]);
else begin $display("FAIL x%0d = %h expected %h",i,uut.u_rf.q[i],expected[i]); errors=errors+1; end
end
if(uut.pc===32'h0000015C) $display("PASS pc = %h (halt loop)",uut.pc);
else begin $display("FAIL pc = %h expected 0000015c",uut.pc); errors=errors+1; end
if(uut.u_dmem.mem[4]===32'hDEADAAEF && uut.u_dmem.mem[5]===32'h0123AAEF) $display("PASS memory");
else begin $display("FAIL memory mem[4]=%h mem[5]=%h",uut.u_dmem.mem[4],uut.u_dmem.mem[5]); errors=errors+1; end
$display("--- errors=%0d ---",errors);
$stop;
end
endmodule
