module riscv_top(input clk,input reset);
wire [31:0] pc,pc_plus4,inst,imm,data_a,data_b,alu_a,alu_b,alu_out,mem_out,wb_data;
wire pc_sel,reg_wen,br_un,br_eq,br_lt,a_sel,b_sel,mem_rw;
wire [2:0] imm_sel;
wire [3:0] alu_sel;
wire [1:0] wb_sel;
wire cf,sf,zf,of;
p_c u_pc(clk,reset,pc_sel,alu_out,pc,pc_plus4);
instruction_memory u_imem(pc,inst);
control_unit u_ctrl(inst,br_eq,br_lt,pc_sel,imm_sel,reg_wen,br_un,a_sel,b_sel,alu_sel,mem_rw,wb_sel);
register_file_32x32 u_rf(clk,reset,reg_wen,inst[11:7],inst[19:15],inst[24:20],wb_data,data_a,data_b);
imm_gen u_imm(inst,imm_sel,imm);
branch_comp u_bc(data_a,data_b,br_un,br_eq,br_lt);
assign alu_a=a_sel?pc:data_a;
assign alu_b=b_sel?imm:data_b;
n32_bit_alu u_alu(alu_a,alu_b,alu_sel,alu_out,cf,sf,zf,of);
data_memory u_dmem(.i_clk(clk),.i_we(mem_rw),.i_funct3(inst[14:12]),.i_data(data_b),.i_addr(alu_out),.o_data(mem_out));
assign wb_data=(wb_sel==2'b00)?mem_out:(wb_sel==2'b01)?alu_out:pc_plus4;
endmodule
