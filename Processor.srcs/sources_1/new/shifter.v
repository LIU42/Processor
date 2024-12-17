`timescale 1ns / 1ps

module shifter(
    input  [31:0] op1,
    input  [31:0] op2,
    output [31:0] sll,
    output [31:0] srl,
    output [31:0] sra
);

    assign sll = op1 << op2[4:0];
    assign srl = op2 >> op2[4:0];
    
    assign sra = $signed(op1) >>> op2[4:0];

endmodule
