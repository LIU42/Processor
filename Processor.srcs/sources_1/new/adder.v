`timescale 1ns / 1ps

module adder(
    input  [31:0] op1,
    input  [31:0] op2,
    input         cin,
    output [31:0] out,
    output        cout
);
    
    assign {cout, out} = op1 + op2 + cin;
    
endmodule
