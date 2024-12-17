`timescale 1ns / 1ps

module alu(
    input  [11:0] ctrl,
    input  [31:0] src1,
    input  [31:0] src2,
    output [31:0] hi,
    output [31:0] lo,
    output [31:0] out
);
  
    wire [31:0] add_op1;
    wire [31:0] add_op2;
    wire [31:0] add_out;
    
    wire add_cin;
    wire add_cout;
    
    adder alu_adder(
        .op1  (add_op1),
        .op2  (add_op2),
        .cin  (add_cin),
        .out  (add_out),
        .cout (add_cout)
    );
    
    wire [31:0] mul_op1;
    wire [31:0] mul_op2;
    wire [31:0] mul_hi;
    wire [31:0] mul_lo;
    
    multiplier alu_multiplier(
        .op1 (mul_op1),
        .op2 (mul_op2),
        .hi  (mul_hi),
        .lo  (mul_lo)
    );
    
    wire [31:0] sll_out;
    wire [31:0] srl_out;
    wire [31:0] sra_out;
    
    shifter alu_shifter(
        .op1 (src2),
        .op2 (src1),
        .sll (sll_out),
        .srl (srl_out),
        .sra (sra_out)
    );
    
    wire op_add;
    wire op_sub;
    wire op_slt;
    wire op_and;
    wire op_or;
    wire op_xor;
    wire op_nor;
    wire op_sll;
    wire op_srl;
    wire op_sra;
    wire op_lui;
    wire op_mul;
    
    assign op_add = ctrl[0];
    assign op_sub = ctrl[1];
    assign op_slt = ctrl[2];
    assign op_and = ctrl[3];
    assign op_or  = ctrl[4];
    assign op_xor = ctrl[5];
    assign op_nor = ctrl[6];
    assign op_sll = ctrl[7];
    assign op_srl = ctrl[8];
    assign op_sra = ctrl[9];
    assign op_lui = ctrl[10];
    assign op_mul = ctrl[11];
    
    assign add_op1 = src1;
    assign add_op2 = (op_add) ? src2 : ~src2;
    assign add_cin = (op_add) ? 0    : 1;
    
    assign mul_op1 = src1;
    assign mul_op2 = src2;
    
    wire [31:0] nop_out;
    wire [31:0] slt_out;
    wire [31:0] and_out;
    wire [31:0] or_out;
    wire [31:0] xor_out;
    wire [31:0] nor_out;
    wire [31:0] lui_out;
    
    assign slt_out = {31'h00000000, add_out[31]};
    
    assign and_out = src1 & src2;
    assign or_out  = src1 | src2;
    assign xor_out = src1 ^ src2;
    assign nor_out = ~or_out;
    
    assign lui_out = {src2[15:0], 16'h0000};

    assign out = (op_add) ? add_out :
                 (op_sub) ? add_out :
                 (op_slt) ? slt_out :
                 (op_and) ? and_out :
                 (op_or)  ? or_out :
                 (op_xor) ? xor_out :
                 (op_nor) ? nor_out :
                 (op_sll) ? sll_out :
                 (op_srl) ? srl_out :
                 (op_sra) ? sra_out :
                 (op_lui) ? lui_out : src1;
                    
    assign hi = (op_mul) ? mul_hi : 32'h00000000;
    assign lo = (op_mul) ? mul_lo : 32'h00000000;
    
endmodule
