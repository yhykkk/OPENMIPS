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
    input              [   5:0]         stall                      ,//pause signal from ctrl
    input                               mem_llbit_we               ,
    input                               mem_llbit_value            ,
    input                               mem_cp0_reg_we             ,
    input              [   4:0]         mem_cp0_reg_write_addr     ,
    input              [`Reg-1:0]       mem_cp0_reg_data           ,
    input                               flush                      ,
    output reg         [`Reg_Addr-1:0]  wb_wd                      ,
    output reg                          wb_wreg                    ,
    output reg         [`Reg-1:0]       wb_wdata                   ,
    output reg         [`Reg-1:0]       wb_hi                      ,
    output reg         [`Reg-1:0]       wb_lo                      ,
    output reg                          wb_whilo                   ,
    output reg                          wb_llbit_we                ,
    output reg                          wb_llbit_value             ,
    output reg                          wb_cp0_reg_we              ,
    output reg         [   4:0]         wb_cp0_reg_write_addr      ,
    output reg         [`Reg-1:0]       wb_cp0_reg_data             
    );
    
    always@(posedge clk)begin
        if(rst==`Rst_Enable)begin
            wb_wd <= `Reg_Zero;
            wb_wreg <= `Write_Disable;
            wb_wdata <= `Zero_Word;
            wb_hi <= `Zero_Word;
            wb_lo <= `Zero_Word;
            wb_whilo <= `Write_Disable;
            wb_llbit_we <= `Write_Disable;
            wb_llbit_value <= 1'b0;
            wb_cp0_reg_we <= `Write_Disable;
            wb_cp0_reg_write_addr <= 5'b0;
            wb_cp0_reg_data <= `Zero_Word;
        end else if(flush == `Flush)begin
            wb_wd <= `Reg_Zero;
            wb_wreg <= `Write_Disable;
            wb_wdata <= `Zero_Word;
            wb_hi <= `Zero_Word;
            wb_lo <= `Zero_Word;
            wb_whilo <= `Write_Disable;
            wb_llbit_we <= `Write_Disable;
            wb_llbit_value <= 1'b0;
            wb_cp0_reg_we <= `Write_Disable;
            wb_cp0_reg_write_addr <= 5'b0;
            wb_cp0_reg_data <= `Zero_Word;
        end else if(stall[4] == `Stop && stall[5] == `NoStop)begin
            wb_wd <= `Reg_Zero;
            wb_wreg <= `Write_Disable;
            wb_wdata <= `Zero_Word;
            wb_hi <= `Zero_Word;
            wb_lo <= `Zero_Word;
            wb_whilo <= `Write_Disable;
            wb_llbit_we <= `Write_Disable;
            wb_llbit_value <= 1'b0;
            wb_cp0_reg_we <= `Write_Disable;
            wb_cp0_reg_write_addr <= 5'b0;
            wb_cp0_reg_data <= `Zero_Word;
        end else if(stall[4] == `NoStop)begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
            wb_llbit_we <= mem_llbit_we;
            wb_llbit_value <= mem_llbit_value;
            wb_cp0_reg_we <= mem_cp0_reg_we;
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
            wb_cp0_reg_data <= mem_cp0_reg_data;
        end
    end
endmodule
