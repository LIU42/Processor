`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst;
    
    reg [4:0]  rf_raddr1_tb;
    reg [4:0]  rf_raddr2_tb;
    reg [11:0] mem_addr_tb;
    
    wire [31:0] pc_tb;
    wire [31:0] ir_tb;
    wire [31:0] hi_tb;
    wire [31:0] lo_tb;
    
    wire [31:0] rf_rdata1_tb;
    wire [31:0] rf_rdata2_tb;
    wire [31:0] mem_rdata_tb;
    
    cpu test_cpu(
        .clk          (clk),
        .rst          (rst),
        .rf_raddr1_tb (rf_raddr1_tb),
        .rf_raddr2_tb (rf_raddr2_tb),
        .mem_addr_tb  (mem_addr_tb),
        .pc_tb        (pc_tb),
        .ir_tb        (ir_tb),
        .hi_tb        (hi_tb),
        .lo_tb        (lo_tb),
        .rf_rdata1_tb (rf_rdata1_tb),
        .rf_rdata2_tb (rf_rdata2_tb),
        .mem_rdata_tb (mem_rdata_tb)
    );

    initial begin
        clk = 1'b1;
        rst = 1'b1;
        #10
        rst = 1'b0;
    end

    initial begin
        rf_raddr1_tb = 5'd5;
        rf_raddr2_tb = 5'd6;
        mem_addr_tb  = 12'h000;
        
        #2950
        rf_raddr1_tb = 5'd11;
        rf_raddr2_tb = 5'd11;
        mem_addr_tb  = 12'h000;
        
        #10
        rf_raddr1_tb = 5'd12;
        rf_raddr2_tb = 5'd12;
        mem_addr_tb  = 12'h004;
        
        #10
        rf_raddr1_tb = 5'd13;
        rf_raddr2_tb = 5'd13;
        mem_addr_tb  = 12'h008;
        
        #10
        rf_raddr1_tb = 5'd14;
        rf_raddr2_tb = 5'd14;
        mem_addr_tb  = 12'h00C;
        
        #10
        rf_raddr1_tb = 5'd15;
        rf_raddr2_tb = 5'd15;
        mem_addr_tb  = 12'h010;
    end
    
    always #5 clk = ~clk;

endmodule
