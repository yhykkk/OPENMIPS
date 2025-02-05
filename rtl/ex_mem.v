/**************************************
@ filename    : ex_mem.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module ex_mem(
    input                               rst                        ,
    input                               clk                        ,
    input              [`Reg_Addr-1:0]  ex_wd                      ,
    input                               ex_wreg                    ,
    input              [`Reg-1:0]       ex_wdata                   ,
    input              [`Reg-1:0]       ex_hi                      ,
    input              [`Reg-1:0]       ex_lo                      ,
    input                               ex_whilo                   ,
    output reg         [`Reg_Addr-1:0]  mem_wd                     ,
    output reg                          mem_wreg                   ,
    output reg         [`Reg-1:0]       mem_wdata                  ,
    output reg         [`Reg-1:0]       mem_hi                     ,
    output reg         [`Reg-1:0]       mem_lo                     ,
    output reg                          mem_whilo                   
    );
    
    always@(posedge clk)begin
        if(rst==`Rst_Enable)begin
            mem_wd <= `Reg_Zero;
            mem_wreg <= `Write_Disable;
            mem_wdata <= `Zero_Word;
            mem_hi <= `Zero_Word;
            mem_lo <= `Zero_Word;
            mem_whilo <= `Write_Disable;
        end else begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
        end
    end
endmodule
