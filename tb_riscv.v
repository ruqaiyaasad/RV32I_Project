`timescale 1ns/1ps
module tb_riscv_top;
reg clk,reset;
riscv_top uut(clk,reset);
initial clk=0;
always #5 clk=~clk;
always @(posedge clk) if(!reset) $display("t=%0t pc=%h inst=%h",$time,uut.pc,uut.inst);
initial begin
reset=1;
#12 reset=0;
#150;
$display("x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d x6=%0d x7=%0d dmem[0]=%0d",
uut.u_rf.q[1],uut.u_rf.q[2],uut.u_rf.q[3],uut.u_rf.q[4],uut.u_rf.q[5],uut.u_rf.q[6],uut.u_rf.q[7],uut.u_dmem.mem[0]);
if(uut.u_rf.q[1]===32'd5 && uut.u_rf.q[2]===32'd10 && uut.u_rf.q[3]===32'd15 && uut.u_rf.q[4]===32'd5 &&
uut.u_rf.q[5]===32'd0 && uut.u_rf.q[6]===32'd15 && uut.u_rf.q[7]===32'd15 && uut.u_dmem.mem[0]===32'd15)
$display("PASS");
else
$display("FAIL");
$stop;
end
endmodule