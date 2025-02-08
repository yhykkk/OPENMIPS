/**************************************
@ filename    : llbit.v
@ author      : yhykkk
@ create time : 2025/02/08 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module llbit(
    input                               clk                        ,
    input                               rst                        ,

    input                               flush                      ,//1 for flush

    input                               llbit_i                    ,
    input                               we                         ,
    output reg                          llbit_o                     
);

    always@(posedge clk)begin
        if(rst == `Rst_Enable)begin
            llbit_o <= 1'b0;
        end else if(flush == 1'b1)begin                             //when flush, clear llbit
            llbit_o <= 1'b0;
        end else if(we == `Write_Enable)begin
            llbit_o <= llbit_i;
        end
    end

endmodule