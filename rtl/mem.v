/**************************************
@ filename    : mem.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module mem(
    input                               rst                        ,
    input              [`Reg_Addr-1:0]  wd_i                       ,
    input                               wreg_i                     ,
    input              [`Reg-1:0]       wdata_i                    ,
    input              [`Reg-1:0]       hi_i                       ,
    input              [`Reg-1:0]       lo_i                       ,
    input                               whilo_i                    ,
    output reg         [`Reg_Addr-1:0]  wd_o                       ,
    output reg                          wreg_o                     ,
    output reg         [`Reg-1:0]       wdata_o                    ,
    output reg         [`Reg-1:0]       hi_o                       ,
    output reg         [`Reg-1:0]       lo_o                       ,
    output reg                          whilo_o                     
    );
    
    always@(*)begin
        if(rst==`Rst_Enable)begin
            wd_o = `Reg_Zero;
            wreg_o = `Write_Disable;
            wdata_o = `Zero_Word;
            hi_o = `Zero_Word;
            lo_o = `Zero_Word;
            whilo_o = `Write_Disable;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            hi_o = hi_i;
            lo_o = lo_i;
            whilo_o = whilo_i;
        end
    end
endmodule
