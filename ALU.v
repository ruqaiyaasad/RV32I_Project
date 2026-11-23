module half_adder(a,b,c,s);
input a,b;
output c,s;
and func(c,a,b);
xor func2(s,a,b);
endmodule
module full_adder(a,b,cin,carry_f,sum_f);
input a,b,cin;
output carry_f,sum_f;
wire sum1,cout1,cout2;
half_adder u1(a,b,cout1,sum1);
half_adder u2(sum1,cin,cout2,sum_f);
or u3(carry_f,cout1,cout2);
endmodule
module bit_alu(input a,input b,input cin,input b_inv,input [3:0]sel_line,output result,output cout);
wire Sum,And,Or,Xor,b_c,cout_s;
wire add_sub,and_sel,or_sel,xor_sel;
wire result_add,result_and,result_or_sel,result_xor_sel;
assign add_sub=(sel_line==4'b0000)||(sel_line==4'b0001);
assign xor_sel=(sel_line==4'b0101);
assign or_sel=(sel_line==4'b1000);
assign and_sel=(sel_line==4'b1001);
//0000->add, 0001->sub, 0101->xor, 1000->or, 1001->and (Table 3.8)
xor u1(b_c,b,b_inv);
full_adder u2(a,b_c,cin,cout_s,Sum);
and u3(result_add,add_sub,Sum);
//and
and u4(And,a,b);
and u5(result_and,and_sel,And);
//or
or u6(Or,a,b);
and u7(result_or_sel,or_sel,Or);
//xor
xor u8(Xor,a,b);
and u9(result_xor_sel,xor_sel,Xor);
//final result
or u10(result,result_add,result_and,result_or_sel,result_xor_sel);
and u11(cout,add_sub,cout_s);
endmodule
module n32_bit_alu #(parameter N=32)
(input [N-1:0]a,input [N-1:0]b,input [3:0]sel_line,
output reg [N-1:0]result,output cf,output sf,output zf,output of);
wire [N:0]c;
wire [N-1:0]bit_result;
wire b_inv;
assign b_inv=(sel_line==4'b0001);
assign c[0]=b_inv;
genvar i;
generate
for(i=0;i<N;i=i+1) begin
bit_alu u(a[i],b[i],c[i],b_inv,sel_line,bit_result[i],c[i+1]);
end
endgenerate
always @(*) begin
case(sel_line)
4'b0000,4'b0001,4'b0101,4'b1000,4'b1001: result=bit_result; //add,sub,xor,or,and (gate level)
4'b0010: result=a<<b[4:0]; //sll
4'b0011: result={{(N-1){1'b0}},($signed(a)<$signed(b))}; //slt
4'b0100: result={{(N-1){1'b0}},(a<b)}; //sltu
4'b0110: result=a>>b[4:0]; //srl
4'b0111: result=$signed(a)>>>b[4:0]; //sra
4'b1010: result=b; //bsel (lui)
default: result={N{1'b0}};
endcase
end
assign sf=result[N-1];
assign zf=(result=={N{1'b0}});
assign cf=((sel_line==4'b0000)||(sel_line==4'b0001))?c[N]:1'b0;
assign of=((sel_line==4'b0000)||(sel_line==4'b0001))?(c[N-1]^c[N]):1'b0;
endmodule
`timescale 1ns/1ps
module tb_alu;
reg [31:0] a,b;
reg [3:0] sel;
wire [31:0] result;
wire cf,sf,zf,of;
integer errors;
n32_bit_alu uut(a,b,sel,result,cf,sf,zf,of);
task check(input [63:0] name,input [3:0] s,input [31:0] x,input [31:0] y,input [31:0] exp);
begin
sel=s;a=x;b=y;
#10;
if(result===exp) $display("PASS %0s a=%h b=%h result=%h",name,a,b,result);
else begin $display("FAIL %0s a=%h b=%h result=%h expected=%h",name,a,b,result,exp); errors=errors+1; end
end
endtask
task flags(input [63:0] name,input e_cf,input e_sf,input e_zf,input e_of);
begin
if(cf===e_cf && sf===e_sf && zf===e_zf && of===e_of) $display("PASS %0s flags cf=%b sf=%b zf=%b of=%b",name,cf,sf,zf,of);
else begin $display("FAIL %0s flags cf=%b sf=%b zf=%b of=%b expected cf=%b sf=%b zf=%b of=%b",name,cf,sf,zf,of,e_cf,e_sf,e_zf,e_of); errors=errors+1; end
end
endtask
initial begin
errors=0;
//table 6-1
check("ADD",4'b0000,32'h00000003,32'h00000003,32'h00000006);
check("ADD",4'b0000,32'hFFFFFFFD,32'h00000007,32'h00000004);
check("SUB",4'b0001,32'hFFFFFFFC,32'h00000001,32'hFFFFFFFB);
check("SUB",4'b0001,32'h00000007,32'h00000007,32'h00000000);
flags("SUB 7-7",1'b1,1'b0,1'b1,1'b0);
check("SLL",4'b0010,32'h00000001,32'h00000004,32'h00000010);
check("SLT",4'b0011,32'hFFFFFFFF,32'h00000001,32'h00000001);
check("SLTU",4'b0100,32'hFFFFFFFF,32'h00000001,32'h00000000);
check("XOR",4'b0101,32'hAAAAAAAA,32'hFFFF0000,32'h5555AAAA);
check("SRL",4'b0110,32'h80000000,32'h00000004,32'h08000000);
check("SRA",4'b0111,32'h80000000,32'h00000004,32'hF8000000);
check("OR",4'b1000,32'h0000F0F0,32'h00000F0F,32'h0000FFFF);
check("AND",4'b1001,32'hFFFF00FF,32'h0F0F0F0F,32'h0F0F000F);
check("BSEL",4'b1010,32'h12345678,32'hABCDE000,32'hABCDE000);
//extra: flags
check("ADDovf",4'b0000,32'h7FFFFFFF,32'h00000001,32'h80000000);
flags("ADDovf",1'b0,1'b1,1'b0,1'b1);
check("ADDcry",4'b0000,32'hFFFFFFFF,32'h00000001,32'h00000000);
flags("ADDcry",1'b1,1'b0,1'b1,1'b0);
//extra: shift amount uses only b[4:0]
check("SLL32",4'b0010,32'h00000001,32'h00000020,32'h00000001);
$display("--- ALU done, errors=%0d ---",errors);
$stop;
end
endmodule