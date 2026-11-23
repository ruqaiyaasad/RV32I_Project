// RV32I Register File
// 32 registers x 32 bits, two asynchronous read ports,
// one synchronous write port. x0 is hardwired to zero.

module decoder_5to32(
    output reg [31:0] out,
    input wire en,
    input wire [4:0] wr
);
    always @(*) begin
        out = 32'b0;
        if (en && (wr != 5'd0))
            out = 32'b1 << wr;
    end
endmodule

// 32-bit register component (kept for the Lab 09 register design).
module register_32bit(
    output reg [31:0] out,
    input wire [31:0] in,
    input wire load,
    input wire clk,
    input wire rst
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            out <= 32'b0;
        else if (load)
            out <= in;
    end
endmodule

module register_file_32x32(
    input wire clk,
    input wire rst,
    input wire we,
    input wire [4:0] rd,
    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [31:0] wdata,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2
);
    wire [31:0] dec_out;
    // Declared as reg so the testbench can inspect uut.u_rf.q[index].
    reg [31:0] q [0:31];
    integer i;

    decoder_5to32 u1(dec_out, we, rd);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                q[i] <= 32'b0;
        end
        else begin
            for (i = 1; i < 32; i = i + 1) begin
                if (dec_out[i])
                    q[i] <= wdata;
            end
            q[0] <= 32'b0;
        end
    end

    assign rdata1 = (rs1 == 5'd0) ? 32'b0 : q[rs1];
    assign rdata2 = (rs2 == 5'd0) ? 32'b0 : q[rs2];
endmodule
