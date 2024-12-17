`timescale 1ns / 1ps

module cpu(
    input         clk,
    input         rst,
    input  [4:0]  rf_raddr1_tb,
    input  [4:0]  rf_raddr2_tb,
    input  [11:0] mem_addr_tb,
    output [31:0] pc_tb,
    output [31:0] ir_tb,
    output [31:0] hi_tb,
    output [31:0] lo_tb,
    output [31:0] rf_rdata1_tb,
    output [31:0] rf_rdata2_tb,
    output [31:0] mem_rdata_tb
);
    
    wire [31:0] inst_addr;
    wire [31:0] inst_data;
    
    instrom cpu_instrom(
        .a   (inst_addr[11:2]),
        .spo (inst_data[31:0])
    );
    
    wire [31:0] id_inst;
    wire [11:0] id_alu_ctrl;
    wire        id_alu_c1;
    wire        id_alu_c2;
    wire [2:0]  id_hi_ctrl;
    wire [2:0]  id_lo_ctrl;
    wire [2:0]  id_mem_ren;
    wire [2:0]  id_mem_wen;
    wire        id_wb_en;
    wire [4:0]  id_wb_addr;
    wire [8:0]  id_jump_ctrl;
    
    controller cpu_controller(
        .inst      (id_inst),
        .alu_ctrl  (id_alu_ctrl),
        .alu_c1    (id_alu_c1),
        .alu_c2    (id_alu_c2),
        .hi_ctrl   (id_hi_ctrl),
        .lo_ctrl   (id_lo_ctrl),
        .mem_ren   (id_mem_ren),
        .mem_wen   (id_mem_wen),
        .wb_en     (id_wb_en),
        .wb_addr   (id_wb_addr),
        .jump_ctrl (id_jump_ctrl)
    );
    
    wire [11:0] alu_ctrl;
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;
    wire [31:0] alu_hi;
    wire [31:0] alu_lo;
    wire [31:0] alu_out;
    
    alu cpu_alu(
        .ctrl (alu_ctrl),
        .src1 (alu_src1),
        .src2 (alu_src2),
        .hi   (alu_hi),
        .lo   (alu_lo),
        .out  (alu_out)
    );

    wire        rf_wen;
    wire [4:0]  rf_raddr1;
    wire [4:0]  rf_raddr2;
    wire [4:0]  rf_waddr;
    wire [31:0] rf_rdata1;
    wire [31:0] rf_rdata2;
    wire [31:0] rf_wdata;
    
    regfile cpu_regfile(
        .clk       (clk),
        .wen       (rf_wen),
        .raddr1    (rf_raddr1),
        .raddr2    (rf_raddr2),
        .waddr     (rf_waddr),
        .raddr1_tb (rf_raddr1_tb),
        .raddr2_tb (rf_raddr2_tb),
        .rdata1    (rf_rdata1),
        .rdata2    (rf_rdata2),
        .wdata     (rf_wdata),
        .rdata1_tb (rf_rdata1_tb),
        .rdata2_tb (rf_rdata2_tb)
    );
    
    wire [2:0]  mem_ren;
    wire [2:0]  mem_wen;
    wire [11:0] mem_addr;
    wire        mem_rerr;
    wire        mem_werr;
    wire [31:0] mem_rdata;
    wire [31:0] mem_wdata;
    wire [31:0] mem_out;
    
    dataram cpu_dataram(
        .clk      (clk),
        .ren      (mem_ren),
        .wen      (mem_wen),
        .addr     (mem_addr),
        .addr_tb  (mem_addr_tb),
        .rerr     (mem_rerr),
        .werr     (mem_werr),
        .rdata    (mem_rdata),
        .wdata    (mem_wdata),
        .rdata_tb (mem_rdata_tb)
    );
    
    reg [31:0] pc;
    reg [31:0] ir;
    reg [31:0] hi;
    reg [31:0] lo;
    
    assign inst_addr = pc;
    
    reg [2:0] hi_ctrl_reg;
    reg [2:0] lo_ctrl_reg;
    
    reg [23:0] alu_ctrl_reg;
    reg [31:0] alu_src1_reg;
    reg [31:0] alu_src2_reg;
    reg [31:0] alu_pass_reg;
    
    reg [11:0] mem_ctrl_reg;
    reg [31:0] mem_addr_reg;
    reg [31:0] mem_data_reg;
    
    reg [6:0]  wb_ctrl_reg;
    reg [31:0] wb_data_reg;
    
    reg [4:0] dest_addr_reg1;
    reg [4:0] dest_addr_reg2;
    
    assign pc_tb = pc;
    assign ir_tb = ir;
    assign hi_tb = hi;
    assign lo_tb = lo;
    
    wire jump_en;
    
    wire [31:0] next_pc;
    wire [31:0] jump_pc;
 
    assign next_pc = pc + 4;
    
    always @(posedge clk) begin
        if (rst) begin
            pc <= 0;
            ir <= 0;
        end
        else begin
            if (jump_en) begin
                pc <= jump_pc;
            end
            else begin
                pc <= next_pc;
            end
            ir <= inst_data;
        end
    end

    assign id_inst = ir;
    
    wire [15:0] inst_imm16;
    wire [25:0] inst_imm26;
    
    assign inst_imm16 = id_inst[15:0];
    assign inst_imm26 = id_inst[25:0];
    
    wire [4:0] rs_addr;
    wire [4:0] rt_addr;
    
    assign rs_addr = id_inst[25:21];
    assign rt_addr = id_inst[20:16];
    
    wire jump_beq;
    wire jump_bgez;
    wire jump_bgtz;
    wire jump_blez;
    wire jump_bltz;
    wire jump_bne;
    wire jump_j;
    wire jump_jal;
    wire jump_jr;
    wire jump_b;
    
    assign jump_beq  = id_jump_ctrl[0];
    assign jump_bgez = id_jump_ctrl[1];
    assign jump_bgtz = id_jump_ctrl[2];
    assign jump_blez = id_jump_ctrl[3];
    assign jump_bltz = id_jump_ctrl[4];
    assign jump_bne  = id_jump_ctrl[5];
    assign jump_j    = id_jump_ctrl[6];
    assign jump_jal  = id_jump_ctrl[7];
    assign jump_jr   = id_jump_ctrl[8];
    
    assign jump_b = (jump_beq | jump_bgez | jump_bgtz | jump_blez | jump_bltz | jump_bne);
    
    wire rs_used;
    wire rt_used;
    
    assign rs_used = (~id_alu_c1 | jump_jr  | jump_b);
    assign rt_used = (~id_alu_c2 | jump_beq | jump_bne);
          
    wire rs_conflict1;
    wire rt_conflict1;
    wire rs_conflict2;
    wire rt_conflict2;
    
    assign rs_conflict1 = (rs_used & rs_addr != 5'b00000 & rs_addr == dest_addr_reg1);
    assign rt_conflict1 = (rt_used & rt_addr != 5'b00000 & rt_addr == dest_addr_reg1);
    assign rs_conflict2 = (rs_used & rs_addr != 5'b00000 & rs_addr == dest_addr_reg2);
    assign rt_conflict2 = (rt_used & rt_addr != 5'b00000 & rt_addr == dest_addr_reg2);
                          
    wire [4:0] inst_dest_addr;
                             
    assign inst_dest_addr = (id_wb_en) ? id_wb_addr : 5'b00000;
    
    wire [31:0] rs_data;
    wire [31:0] rt_data;
    wire [31:0] sa_data;
    
    assign rf_raddr1 = rs_addr;
    assign rf_raddr2 = rt_addr;
    
    assign rs_data = (rs_conflict2) ? alu_out : (rs_conflict1) ? mem_out : rf_rdata1;
    assign rt_data = (rt_conflict2) ? alu_out : (rt_conflict1) ? mem_out : rf_rdata2;
    
    assign sa_data = {27'h0000000, id_inst[10:6]};
    
    wire is_equ;
    wire is_ltz;
    wire is_gtz;
    
    assign is_equ = (rs_data == rt_data);
    assign is_ltz = (rs_data < 0);
    assign is_gtz = (rs_data > 0);
  
    assign jump_en = (jump_j)              |
                     (jump_jal)            |
                     (jump_jr)             |
                     (jump_beq  &  is_equ) |
                     (jump_bgez & ~is_ltz) |
                     (jump_bgtz &  is_gtz) |
                     (jump_blez & ~is_gtz) |
                     (jump_bltz &  is_ltz) |
                     (jump_bne  & ~is_equ);
                      
    wire [31:0] ext_addr26;
    wire [31:0] ext_addr16;
    wire [31:0] ext_data16;
    
    assign ext_addr26 = {pc[31:28], inst_imm26[25:0], 2'b00};
    
    assign ext_addr16 = {{14{inst_imm16[15]}}, inst_imm16[15:0], 2'b00};
    assign ext_data16 = {{16{inst_imm16[15]}}, inst_imm16[15:0]};
                      
    assign jump_pc = (jump_jr)  ? rs_data :
                     (jump_j)   ? ext_addr26 :
                     (jump_jal) ? ext_addr26 :
                     (jump_b)   ? ext_addr16 + pc : 32'h00000000;
                     
    wire id_mfhi;
    wire id_mflo;
    
    assign id_mfhi = id_hi_ctrl[0];
    assign id_mflo = id_lo_ctrl[0];

    wire [31:0] id_op1;
    wire [31:0] id_op2;
    
    assign id_op1 = (jump_jal)  ? next_pc :
                    (id_mfhi)   ? hi :
                    (id_mflo)   ? lo :
                    (id_alu_c1) ? sa_data : rs_data;
                         
    assign id_op2 = (id_alu_c2) ? ext_data16 : rt_data;

    always @(posedge clk) begin
        if (rst) begin
            dest_addr_reg1 <= 0;
            dest_addr_reg2 <= 0;
        end
        else begin
            dest_addr_reg1 <= dest_addr_reg2;
            dest_addr_reg2 <= inst_dest_addr;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            hi_ctrl_reg <= 0;
            lo_ctrl_reg <= 0;
            
            alu_ctrl_reg <= 0;
            alu_src1_reg <= 0;
            alu_src2_reg <= 0;
            alu_pass_reg <= 0;
        end
        else begin
            hi_ctrl_reg <= id_hi_ctrl;
            lo_ctrl_reg <= id_lo_ctrl;
            
            alu_ctrl_reg <= {id_wb_addr[5:0], id_wb_en, id_mem_wen[2:0], id_mem_ren[2:0], id_alu_ctrl[11:0]};
            alu_src1_reg <= id_op1;
            alu_src2_reg <= id_op2;
            alu_pass_reg <= rt_data;
        end
    end
    
    assign alu_ctrl = alu_ctrl_reg;
    assign alu_src1 = alu_src1_reg;
    assign alu_src2 = alu_src2_reg;
    
    wire hi_mthi;
    wire hi_mult;
    wire lo_mtlo;
    wire lo_mult;
    
    assign hi_mthi = hi_ctrl_reg[1];
    assign hi_mult = hi_ctrl_reg[2];
    assign lo_mtlo = lo_ctrl_reg[1];
    assign lo_mult = lo_ctrl_reg[2];
    
    always @(negedge clk) begin
        if (hi_mthi) begin
            hi <= alu_out;
        end
        if (hi_mult) begin
            hi <= alu_hi;
        end
        if (lo_mtlo) begin
            lo <= alu_out;
        end
        if (lo_mult) begin
            lo <= alu_lo;
        end
    end
    
    always @(posedge clk) begin
        if (rst) begin
            mem_ctrl_reg <= 0;
            mem_addr_reg <= 0;
            mem_data_reg <= 0;
        end
        else begin
            mem_ctrl_reg <= alu_ctrl_reg[23:12];
            mem_addr_reg <= alu_out;
            mem_data_reg <= alu_pass_reg;
        end
    end
    
    assign mem_ren = mem_ctrl_reg[2:0];
    assign mem_wen = mem_ctrl_reg[5:3];
    
    assign mem_addr  = mem_addr_reg[11:0];
    assign mem_wdata = mem_data_reg[31:0];
    
    assign mem_out = (mem_ren == 3'b000) ? mem_addr_reg : mem_rdata;
    
    always @(posedge clk) begin
        if (rst) begin
            wb_ctrl_reg <= 0;
            wb_data_reg <= 0;
        end
        else begin
            wb_ctrl_reg <= mem_ctrl_reg[11:6];
            wb_data_reg <= mem_out;
        end
    end
    
    assign rf_wen   = wb_ctrl_reg[0];
    assign rf_waddr = wb_ctrl_reg[5:1];
    assign rf_wdata = wb_data_reg;
    
endmodule
