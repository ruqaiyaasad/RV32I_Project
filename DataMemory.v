module data_memory (
input wire i_clk, // clock
input wire i_we, // write enable (1 = write)
input wire [2:0] i_funct3, // 000 byte, 001 half, 010 word, 100 byte unsigned, 101 half unsigned
input wire [31:0] i_data, // data to be written (Reg[rs2])
input wire [31:0] i_addr, // BYTE address (ALU result), word index = addr[11:2]
output reg [31:0] o_data // data read from memory
);
// 1) MEMORY ARRAY: 1024 locations, each 32 bits wide
reg [31:0] mem [0:1023];
// 2) Note: simulation never shows 'x'
integer i;
initial begin
for(i=0;i<1024;i=i+1) begin
mem[i]=32'b0;
end
end
wire [9:0] word_addr = i_addr[11:2];
wire [1:0] byte_off = i_addr[1:0];
wire [31:0] word = mem[word_addr];
// 3) WRITE: merge the byte/half/word into the old word, then write on the clock edge
reg [31:0] w_data;
always @(*) begin
w_data = word;
case(i_funct3[1:0])
2'b00: begin //sb
case(byte_off)
2'b00: w_data[7:0]=i_data[7:0];
2'b01: w_data[15:8]=i_data[7:0];
2'b10: w_data[23:16]=i_data[7:0];
2'b11: w_data[31:24]=i_data[7:0];
endcase
end
2'b01: begin //sh
if(byte_off[1]) w_data[31:16]=i_data[15:0];
else w_data[15:0]=i_data[15:0];
end
default: w_data=i_data; //sw
endcase
end
always @(posedge i_clk) begin
if (i_we) begin
mem[word_addr] <= w_data;
end
end
// 4) READ PORT: Style A - asynchronous read (single-cycle processor needs data in the same cycle)
// Style B (synchronous read) would need an extra cycle, so it is not used
wire [7:0] rbyte = word[8*byte_off +: 8];
wire [15:0] rhalf = word[16*byte_off[1] +: 16];
always @(*) begin
case(i_funct3)
3'b000: o_data={{24{rbyte[7]}},rbyte}; //lb
3'b001: o_data={{16{rhalf[15]}},rhalf}; //lh
3'b100: o_data={24'b0,rbyte}; //lbu
3'b101: o_data={16'b0,rhalf}; //lhu
default: o_data=word; //lw
endcase
end
endmodule
`timescale 1ns/1ps
module tb_dmem;
reg clk,we;
reg [2:0] f3;
reg [31:0] wdata,addr;
wire [31:0] rdata;
integer errors;
data_memory uut(.i_clk(clk),.i_we(we),.i_funct3(f3),.i_data(wdata),.i_addr(addr),.o_data(rdata));
initial clk=0;
always #5 clk=~clk;
task store(input [31:0] ad,input [31:0] d,input [2:0] f);
begin
@(negedge clk);
addr=ad;wdata=d;f3=f;we=1'b1;
@(posedge clk);
#1 we=1'b0;
end
endtask
task load_check(input [63:0] name,input [31:0] ad,input [2:0] f,input [31:0] exp);
begin
@(negedge clk);
addr=ad;f3=f;we=1'b0;
#1;
if(rdata===exp) $display("PASS %0s addr=%h result=%h",name,ad,rdata);
else begin $display("FAIL %0s addr=%h result=%h expected=%h",name,ad,rdata,exp); errors=errors+1; end
end
endtask
initial begin
errors=0;we=0;f3=0;wdata=0;addr=0;
#12;
//table 6-3
store(32'h00000014,32'hDEADBEEF,3'b010); //sw
load_check("LW",32'h00000014,3'b010,32'hDEADBEEF);
load_check("LB",32'h00000014,3'b000,32'hFFFFFFEF);
load_check("LBU",32'h00000014,3'b100,32'h000000EF);
load_check("LH",32'h00000014,3'b001,32'hFFFFBEEF);
store(32'h00000015,32'h000000AA,3'b000); //sb
load_check("LW",32'h00000014,3'b010,32'hDEADAAEF);
//extra: sh on upper half, byte loads from other offsets
store(32'h00000016,32'h00001234,3'b001); //sh
load_check("LW",32'h00000014,3'b010,32'h1234AAEF);
load_check("LHU",32'h00000016,3'b101,32'h00001234);
load_check("LBU",32'h00000015,3'b100,32'h000000AA);
load_check("LB",32'h00000015,3'b000,32'hFFFFFFAA);
load_check("LB",32'h00000017,3'b000,32'h00000012);
//extra: write must not disturb neighbouring word
load_check("LW",32'h00000010,3'b010,32'h00000000);
load_check("LW",32'h00000018,3'b010,32'h00000000);
$display("--- DMEM done, errors=%0d ---",errors);
$stop;
end
endmodule