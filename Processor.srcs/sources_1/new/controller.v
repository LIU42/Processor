`timescale 1ns / 1ps

module controller(
    input  [31:0] inst,
    output [11:0] alu_ctrl,
    output        alu_c1,
    output        alu_c2,
    output [2:0]  hi_ctrl,
    output [2:0]  lo_ctrl,
    output [2:0]  mem_ren,
    output [2:0]  mem_wen,
    output        wb_en,
    output [4:0]  wb_addr,
    output [8:0]  jump_ctrl
);
    
    wire [5:0]  inst_op;
    wire [4:0]  inst_rs;
    wire [4:0]  inst_rt;
    wire [4:0]  inst_rd;
    wire [4:0]  inst_sa;
    wire [5:0]  inst_fn;
    
    assign inst_op = inst[31:26];
    assign inst_rs = inst[25:21];
    assign inst_rt = inst[20:16];
    assign inst_rd = inst[15:11];
    assign inst_sa = inst[10:6];
    assign inst_fn = inst[5:0];
    
    wire inst_nop;
    wire inst_add;
    wire inst_addi;
    wire inst_and;
    wire inst_andi;
    wire inst_beq;
    wire inst_bgez;
    wire inst_bgtz;
    wire inst_blez;
    wire inst_bltz;
    wire inst_bne;
    wire inst_j;
    wire inst_jal;
    wire inst_jr;
    wire inst_lb;
    wire inst_lh;
    wire inst_lui;
    wire inst_lw;
    wire inst_mfhi;
    wire inst_mflo;
    wire inst_mthi;
    wire inst_mtlo;
    wire inst_mult;
    wire inst_nor;
    wire inst_or;
    wire inst_ori;
    wire inst_sb;
    wire inst_sh;
    wire inst_sll;
    wire inst_sllv;
    wire inst_slt;
    wire inst_slti;
    wire inst_sra;
    wire inst_srav;
    wire inst_srl;
    wire inst_srlv;
    wire inst_sub;
    wire inst_sw;
    wire inst_xor;
    wire inst_xori;
    
    assign inst_nop  = (inst == 32'h00000000);
    assign inst_add  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100000);
    assign inst_addi = (inst_op == 6'b001000);
    assign inst_and  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100100);
    assign inst_andi = (inst_op == 6'b001100);
    assign inst_beq  = (inst_op == 6'b000100);
    assign inst_bgez = (inst_op == 6'b000001 & inst_rt == 5'b00001);
    assign inst_bgtz = (inst_op == 6'b000111 & inst_rt == 5'b00000);
    assign inst_blez = (inst_op == 6'b000110 & inst_rt == 5'b00000);
    assign inst_bltz = (inst_op == 6'b000001 & inst_rt == 5'b00000);
    assign inst_bne  = (inst_op == 6'b000101);
    assign inst_j    = (inst_op == 6'b000010);
    assign inst_jal  = (inst_op == 6'b000011);
    assign inst_jr   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b001000);
    assign inst_lb   = (inst_op == 6'b100000);
    assign inst_lh   = (inst_op == 6'b100001);
    assign inst_lui  = (inst_op == 6'b001111);
    assign inst_lw   = (inst_op == 6'b100011);
    assign inst_mfhi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b010000);
    assign inst_mflo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b010010);
    assign inst_mthi = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b010001);
    assign inst_mtlo = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b010011);
    assign inst_mult = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b011000);
    assign inst_nor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100111);
    assign inst_or   = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100101);
    assign inst_ori  = (inst_op == 6'b001101);
    assign inst_sb   = (inst_op == 6'b101000);
    assign inst_sh   = (inst_op == 6'b101001);
    assign inst_sll  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fn == 6'b100111);
    assign inst_sllv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b000100);
    assign inst_slt  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b101010);
    assign inst_slti = (inst_op == 6'b001010);
    assign inst_sra  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fn == 6'b000011);
    assign inst_srav = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b000111);
    assign inst_srl  = (inst_op == 6'b000000 & inst_rs == 5'b00000 & inst_fn == 6'b000010);
    assign inst_srlv = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b000110);
    assign inst_sub  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100010);
    assign inst_sw   = (inst_op == 6'b101011);
    assign inst_xor  = (inst_op == 6'b000000 & inst_sa == 5'b00000 & inst_fn == 6'b100110);
    assign inst_xori = (inst_op == 6'b001110);
    
    wire inst_b;
    wire inst_l;
    wire inst_s;
    
    assign inst_b = (inst_beq | inst_bne | inst_bgez | inst_bgtz | inst_blez | inst_bltz);
    assign inst_l = (inst_lb  | inst_lh  | inst_lw);
    assign inst_s = (inst_sb  | inst_sh  | inst_sw);

    assign alu_ctrl[0]  = (inst_add | inst_addi | inst_l | inst_s);
    assign alu_ctrl[1]  = (inst_sub);
    assign alu_ctrl[2]  = (inst_slt | inst_slti);
    assign alu_ctrl[3]  = (inst_and | inst_andi);
    assign alu_ctrl[4]  = (inst_or  | inst_ori);
    assign alu_ctrl[5]  = (inst_xor | inst_xori);
    assign alu_ctrl[6]  = (inst_nor);
    assign alu_ctrl[7]  = (inst_sll | inst_sllv);
    assign alu_ctrl[8]  = (inst_srl | inst_srlv);
    assign alu_ctrl[9]  = (inst_sra | inst_srav);
    assign alu_ctrl[10] = (inst_lui);
    assign alu_ctrl[11] = (inst_mult);
    
    assign alu_c1 = (inst_sll  | inst_srl  | inst_sra);
    assign alu_c2 = (inst_addi | inst_andi | inst_slti | inst_ori | inst_xori | inst_b | inst_l | inst_s);    
    
    assign hi_ctrl[0] = inst_mfhi;
    assign hi_ctrl[1] = inst_mthi;
    assign hi_ctrl[2] = inst_mult;
    assign lo_ctrl[0] = inst_mflo;
    assign lo_ctrl[1] = inst_mtlo;
    assign lo_ctrl[2] = inst_mult;         

    assign mem_ren[0] = inst_lb;
    assign mem_ren[1] = inst_lh;
    assign mem_ren[2] = inst_lw;
    assign mem_wen[0] = inst_sb;
    assign mem_wen[1] = inst_sh;
    assign mem_wen[2] = inst_sw;
    
    assign wb_en = ~(inst_b | inst_s | inst_nop | inst_mthi | inst_mtlo | inst_mult | inst_j | inst_jr);
    
    assign jump_ctrl[0] = inst_beq;
    assign jump_ctrl[1] = inst_bgez;
    assign jump_ctrl[2] = inst_bgtz;
    assign jump_ctrl[3] = inst_blez;
    assign jump_ctrl[4] = inst_bltz;
    assign jump_ctrl[5] = inst_bne;
    assign jump_ctrl[6] = inst_j;
    assign jump_ctrl[7] = inst_jal;
    assign jump_ctrl[8] = inst_jr;
    
    assign wb_addr = (inst_jal) ? 5'b11111 : (alu_c2) ? inst_rt : inst_rd;
    
endmodule
