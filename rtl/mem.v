/**************************************
@ filename    : mem.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module mem(
    input                             rst          ,
    input         [`Reg_Addr-1:0]     wd_i         ,
    input                             wreg_i       ,
    input         [`Reg-1:0]          wdata_i      ,
    output reg   [`Reg_Addr-1:0]      wd_o        ,
    output reg                        wreg_o      ,
    output reg   [`Reg-1:0]           wdata_o
    );
    
    always@(*)begin
        if(rst==`Rst_Enable)begin
            wd_o = `Reg_Zero;
            wreg_o = `Write_Disable;
            wdata_o = `Zero_Word;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
        end
    end
endmodule
