/**************************************
@ filename    : mem_wb.v
@ author      : yhykkk
@ create time : 2025/01/20
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module mem_wb(
    input                               rst                        ,
    input                               clk                        ,
    input              [`Reg_Addr-1:0]  mem_wd                     ,
    input                               mem_wreg                   ,
    input              [`Reg-1:0]       mem_wdata                  ,
    input              [`Reg-1:0]       mem_hi                     ,
    input              [`Reg-1:0]       mem_lo                     ,
    input                               mem_whilo                  ,
    output reg         [`Reg_Addr-1:0]  wb_wd                      ,
    output reg                          wb_wreg                    ,
    output reg         [`Reg-1:0]       wb_wdata                   ,
    output reg         [`Reg-1:0]       wb_hi                      ,
    output reg         [`Reg-1:0]       wb_lo                      ,
    output reg                          wb_whilo                    
    );
    
    always@(posedge clk)begin
        if(rst==`Rst_Enable)begin
            wb_wd <= `Reg_Zero;
            wb_wreg <= `Write_Disable;
            wb_wdata <= `Zero_Word;
            wb_hi <= `Zero_Word;
            wb_lo <= `Zero_Word;
            wb_whilo <= `Write_Disable;
        end else begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
        end
    end
endmodule
