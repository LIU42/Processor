`timescale 1ns / 1ps

module dataram(
    input         clk,
    input  [2:0]  ren,
    input  [2:0]  wen,
    input  [11:0] addr,
    input  [11:0] addr_tb,
    input  [31:0] wdata,
    output        rerr,
    output        werr,
    output [31:0] rdata,
    output [31:0] rdata_tb
);

    wire mem0_wen;
    wire mem1_wen;
    wire mem2_wen;
    wire mem3_wen;
    
    wire [7:0] mem0_wdata;
    wire [7:0] mem1_wdata;
    wire [7:0] mem2_wdata;
    wire [7:0] mem3_wdata;
    
    wire [7:0] mem0_rdata;
    wire [7:0] mem1_rdata;
    wire [7:0] mem2_rdata;
    wire [7:0] mem3_rdata;
    
    wire [7:0] mem0_rdata_tb;
    wire [7:0] mem1_rdata_tb;
    wire [7:0] mem2_rdata_tb;
    wire [7:0] mem3_rdata_tb;

    dataram8 mem0(
        .clk  (~clk),
        .a    (addr[11:2]),
        .dpra (addr_tb[11:2]),
        .we   (mem0_wen),
        .d    (mem0_wdata),
        .spo  (mem0_rdata),
        .dpo  (mem0_rdata_tb)
    );
    
    dataram8 mem1(
        .clk  (~clk),
        .a    (addr[11:2]),
        .dpra (addr_tb[11:2]),
        .we   (mem1_wen),
        .d    (mem1_wdata),
        .spo  (mem1_rdata),
        .dpo  (mem1_rdata_tb)
    );
    
    dataram8 mem2(
        .clk  (~clk),
        .a    (addr[11:2]),
        .dpra (addr_tb[11:2]),
        .we   (mem2_wen),
        .d    (mem2_wdata),
        .spo  (mem2_rdata),
        .dpo  (mem2_rdata_tb)
    );
    
    dataram8 mem3(
        .clk  (~clk),
        .a    (addr[11:2]),
        .dpra (addr_tb[11:2]),
        .we   (mem3_wen),
        .d    (mem3_wdata),
        .spo  (mem3_rdata),
        .dpo  (mem3_rdata_tb)
    );
    
    wire rw;
    wire rh;
    wire rb;
    wire sw;
    wire sh;
    wire sb;
    
    assign rw = ren[2];
    assign rh = ren[1];
    assign rb = ren[0];
    assign sw = wen[2];
    assign sh = wen[1];
    assign sb = wen[0];
    
    assign rerr = (rw & addr[1:0] != 2'b00) | (rh && addr[0] != 1'b0);
    assign werr = (sw & addr[1:0] != 2'b00) | (rh && addr[0] != 1'b0);
    
    assign mem0_wen = sw | (sh & addr[1:0] == 2'b00) | (sb & addr[1:0] == 2'b00);
    assign mem1_wen = sw | (sh & addr[1:0] == 2'b00) | (sb & addr[1:0] == 2'b01);
    assign mem2_wen = sw | (sh & addr[1:0] == 2'b10) | (sb & addr[1:0] == 2'b10);
    assign mem3_wen = sw | (sh & addr[1:0] == 2'b10) | (sb & addr[1:0] == 2'b11);
    
    wire [7:0] wdata0;
    wire [7:0] wdata1;
    wire [7:0] wdata2;
    wire [7:0] wdata3;
    
    assign wdata0 = wdata[7:0];
    assign wdata1 = wdata[15:8];
    assign wdata2 = wdata[23:16];
    assign wdata3 = wdata[31:24];
    
    assign mem0_wdata = (sb) ? wdata0 : (sh) ? wdata0 : wdata0;
    assign mem1_wdata = (sb) ? wdata0 : (sh) ? wdata1 : wdata1;
    assign mem2_wdata = (sb) ? wdata0 : (sh) ? wdata0 : wdata2;
    assign mem3_wdata = (sb) ? wdata0 : (sh) ? wdata1 : wdata3;
    
    assign rdata_tb = {mem3_rdata_tb[7:0], mem2_rdata_tb[7:0], mem1_rdata_tb[7:0], mem0_rdata_tb[7:0]};
    
    wire [7:0] rdata_w0;
    wire [7:0] rdata_w1;
    wire [7:0] rdata_w2;
    wire [7:0] rdata_w3;
    wire [7:0] rdata_h0;
    wire [7:0] rdata_h1;
    wire [7:0] rdata_b0;
    
    assign rdata_w0 = mem0_rdata;
    assign rdata_w1 = mem1_rdata;
    assign rdata_w2 = mem2_rdata;
    assign rdata_w3 = mem3_rdata;
    
    assign rdata_h0 = (addr[1:0] == 2'b00) ? mem0_rdata :
                      (addr[1:0] == 2'b10) ? mem2_rdata : 8'b00000000;
     
    assign rdata_h1 = (addr[1:0] == 2'b00) ? mem1_rdata :
                      (addr[1:0] == 2'b10) ? mem3_rdata : 8'b00000000;
                      
    assign rdata_b0 = (addr[1:0] == 2'b00) ? mem0_rdata :
                      (addr[1:0] == 2'b01) ? mem1_rdata :
                      (addr[1:0] == 2'b10) ? mem2_rdata :
                      (addr[1:0] == 2'b11) ? mem3_rdata : 8'b00000000;
                      
    wire [7:0] rdata0;
    wire [7:0] rdata1;
    wire [7:0] rdata2;
    wire [7:0] rdata3;
    
    assign rdata3 = (rw) ? rdata_w3 : 8'b00000000;
    assign rdata2 = (rw) ? rdata_w2 : 8'b00000000;
    assign rdata1 = (rw) ? rdata_w1 :
                    (rh) ? rdata_h1 : 8'b00000000;
    assign rdata0 = (rw) ? rdata_w0 :
                    (rh) ? rdata_h0 :
                    (rb) ? rdata_b0 : 8'b00000000;
                    
    assign rdata = {rdata3[7:0], rdata2[7:0], rdata1[7:0], rdata0[7:0]};

endmodule
