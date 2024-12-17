`timescale 1ns / 1ps

module multiplier(
    input  [31:0] op1,
    input  [31:0] op2,
    output [31:0] hi,
    output [31:0] lo
);

    assign {hi, lo} = $signed(op1) * $signed(op2);
    
endmodule
