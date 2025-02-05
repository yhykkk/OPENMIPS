/**************************************
@ filename    : hilo_reg.v
@ author      : yhykkk
@ create time : 2025/02/04
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module hilo_reg(
    input                               clk                        ,
    input                               rst                        ,
    input                               we                         ,
    input              [`Reg-1:0]       hi_i                       ,
    input              [`Reg-1:0]       lo_i                       ,
    output reg         [`Reg-1:0]       hi_o                       ,
    output reg         [`Reg-1:0]       lo_o                        
);

always@(posedge clk)begin
    if(rst == `Rst_Enable) begin
        hi_o <= `Zero_Word;
        lo_o <= `Zero_Word;
    end else if(we == `Write_Enable) begin
        hi_o <= hi_i;
        lo_o <= lo_i;
    end
end

endmodule