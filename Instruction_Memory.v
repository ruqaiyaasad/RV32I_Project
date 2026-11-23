module instruction_memory(input [31:0] address,output reg[31:0]instruction);
reg [31:0] memory [0:1023];
integer i;
initial begin
for(i=0;i<1024;i=i+1)
memory[i]=32'h00000013; //nop (addi x0,x0,0)
$readmemh("program.hex",memory);
end
always @(*)begin
instruction = memory[address[11:2]];
end
endmodule
