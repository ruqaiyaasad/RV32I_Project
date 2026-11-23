module branch_comp(input [31:0] a,input [31:0] b,input br_un,output br_eq,output br_lt);
assign br_eq=(a==b);
assign br_lt=br_un?(a<b):($signed(a)<$signed(b));
endmodule
`timescale 1ns/1ps
module tb_branch_comp;
reg [31:0] a,b;
reg br_un;
wire br_eq,br_lt;
integer errors;
branch_comp uut(a,b,br_un,br_eq,br_lt);
task check(input [31:0] x,input [31:0] y,input u,input e_eq,input e_lt);
begin
a=x;b=y;br_un=u;
#10;
if(br_eq===e_eq && br_lt===e_lt) $display("PASS a=%h b=%h un=%b eq=%b lt=%b",a,b,br_un,br_eq,br_lt);
else begin $display("FAIL a=%h b=%h un=%b eq=%b lt=%b expected eq=%b lt=%b",a,b,br_un,br_eq,br_lt,e_eq,e_lt); errors=errors+1; end
end
endtask
initial begin
errors=0;
//table 6.5
check(32'h00000005,32'h00000005,1'b0,1'b1,1'b0);
check(32'hFFFFFFFF,32'h00000001,1'b0,1'b0,1'b1);
check(32'hFFFFFFFF,32'h00000001,1'b1,1'b0,1'b0);
check(32'h00000002,32'h00000009,1'b0,1'b0,1'b1);
//extra
check(32'h00000005,32'h00000005,1'b1,1'b1,1'b0);
check(32'h80000000,32'h00000001,1'b0,1'b0,1'b1);
check(32'h80000000,32'h00000001,1'b1,1'b0,1'b0);
check(32'h00000009,32'h00000002,1'b0,1'b0,1'b0);
$display("--- BRANCH COMP done, errors=%0d ---",errors);
$stop;
end
endmodule