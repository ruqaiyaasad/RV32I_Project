module control_unit(input [31:0] inst,input br_eq,input br_lt,
output reg pc_sel,output reg [2:0] imm_sel,output reg reg_wen,output br_un,
output reg a_sel,output reg b_sel,output reg [3:0] alu_sel,output reg mem_rw,output reg [1:0] wb_sel);
wire [6:0] opcode=inst[6:0];
wire [2:0] funct3=inst[14:12];
wire funct7_5=inst[30];
localparam R_TYPE=7'b0110011,I_TYPE=7'b0010011,LOAD=7'b0000011,STORE=7'b0100011,
BRANCH=7'b1100011,JAL=7'b1101111,JALR=7'b1100111,LUI=7'b0110111,AUIPC=7'b0010111;
//blt/bge (100,101) signed, bltu/bgeu (110,111) unsigned
assign br_un=(opcode==BRANCH)&funct3[1];
//alu operation for r-type and i-type (inst[30] only matters for sub on r-type, and sra/srai)
reg [3:0] alu_op;
always @(*) begin
case(funct3)
3'b000: alu_op=(opcode==R_TYPE&&funct7_5)?4'b0001:4'b0000; //sub / add,addi
3'b001: alu_op=4'b0010; //sll
3'b010: alu_op=4'b0011; //slt
3'b011: alu_op=4'b0100; //sltu
3'b100: alu_op=4'b0101; //xor
3'b101: alu_op=funct7_5?4'b0111:4'b0110; //sra / srl
3'b110: alu_op=4'b1000; //or
3'b111: alu_op=4'b1001; //and
default: alu_op=4'b0000;
endcase
end
always @(*) begin
//defaults (safe nop)
pc_sel=1'b0;imm_sel=3'b000;reg_wen=1'b0;a_sel=1'b0;b_sel=1'b1;
alu_sel=4'b0000;mem_rw=1'b0;wb_sel=2'b01;
case(opcode)
R_TYPE: begin reg_wen=1'b1;b_sel=1'b0;alu_sel=alu_op; end
I_TYPE: begin reg_wen=1'b1;alu_sel=alu_op; end
LOAD: begin reg_wen=1'b1;wb_sel=2'b00; end
STORE: begin imm_sel=3'b001;mem_rw=1'b1; end
BRANCH: begin
imm_sel=3'b010;a_sel=1'b1;
case(funct3)
3'b000: pc_sel=br_eq;
3'b001: pc_sel=~br_eq;
3'b100: pc_sel=br_lt;
3'b101: pc_sel=~br_lt;
3'b110: pc_sel=br_lt;
3'b111: pc_sel=~br_lt;
default: pc_sel=1'b0;
endcase
end
JAL: begin pc_sel=1'b1;imm_sel=3'b100;reg_wen=1'b1;a_sel=1'b1;wb_sel=2'b10; end
JALR: begin pc_sel=1'b1;reg_wen=1'b1;wb_sel=2'b10; end
LUI: begin imm_sel=3'b011;reg_wen=1'b1;alu_sel=4'b1010; end
AUIPC: begin imm_sel=3'b011;reg_wen=1'b1;a_sel=1'b1; end
default: ;
endcase
end
endmodule
