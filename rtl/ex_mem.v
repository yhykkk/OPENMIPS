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
    input              [   5:0]         stall                      ,//pause signal from ctrl
    input              [`Reg_Double-1:0]hilo_i                     ,
    input              [   1:0]         cnt_i                      ,
    input              [`Alu_Op-1:0]    ex_aluop                   ,
    input              [`Reg-1:0]       ex_mem_addr                ,
    input              [`Reg-1:0]       ex_reg2                    ,
    input                               ex_cp0_reg_we              ,
    input              [   4:0]         ex_cp0_reg_write_addr      ,
    input              [`Reg-1:0]       ex_cp0_reg_data            ,
    input                               flush                      ,
    input              [`Reg-1:0]       ex_current_inst_addr       ,
    input              [  31:0]         ex_excepttype              ,
    input                               ex_is_in_delayslot         ,
    output reg         [`Reg_Addr-1:0]  mem_wd                     ,
    output reg                          mem_wreg                   ,
    output reg         [`Reg-1:0]       mem_wdata                  ,
    output reg         [`Reg-1:0]       mem_hi                     ,
    output reg         [`Reg-1:0]       mem_lo                     ,
    output reg                          mem_whilo                  ,
    output reg         [`Reg_Double-1:0]hilo_o                     ,
    output reg         [   1:0]         cnt_o                      ,
    output reg         [`Alu_Op-1:0]    mem_aluop                  ,
    output reg         [`Reg-1:0]       mem_mem_addr               ,
    output reg         [`Reg-1:0]       mem_reg2                   ,
    output reg                          mem_cp0_reg_we             ,
    output reg         [   4:0]         mem_cp0_reg_write_addr     ,
    output reg         [`Reg-1:0]       mem_cp0_reg_data           ,
    output reg         [  31:0]         mem_excepttype             ,
    output reg         [`Reg-1:0]       mem_current_inst_addr      ,
    output reg                          mem_is_in_delayslot          
    );
    
    always@(posedge clk)begin
        if(rst==`Rst_Enable)begin
            mem_wd <= `Reg_Zero;
            mem_wreg <= `Write_Disable;
            mem_wdata <= `Zero_Word;
            mem_hi <= `Zero_Word;
            mem_lo <= `Zero_Word;
            mem_whilo <= `Write_Disable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `Zero_Word;
            mem_reg2 <= `Zero_Word;
            mem_cp0_reg_we <= `Write_Disable;
            mem_cp0_reg_write_addr <= 5'b0;
            mem_cp0_reg_data <= `Zero_Word;
            mem_excepttype <= `Zero_Word;
            mem_current_inst_addr <= `Zero_Word;
            mem_is_in_delayslot <= `NotInDelaySlot;
        end else if(flush == `Flush)begin
            mem_wd <= `Reg_Zero;
            mem_wreg <= `Write_Disable;
            mem_wdata <= `Zero_Word;
            mem_hi <= `Zero_Word;
            mem_lo <= `Zero_Word;
            mem_whilo <= `Write_Disable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `Zero_Word;
            mem_reg2 <= `Zero_Word;
            mem_cp0_reg_we <= `Write_Disable;
            mem_cp0_reg_write_addr <= 5'b0;
            mem_cp0_reg_data <= `Zero_Word;
            mem_excepttype <= `Zero_Word;
            mem_current_inst_addr <= `Zero_Word;
            mem_is_in_delayslot <= `NotInDelaySlot;
        end else if(stall[3] == `Stop && stall[4] == `NoStop)begin
            mem_wd <= `Reg_Zero;
            mem_wreg <= `Write_Disable;
            mem_wdata <= `Zero_Word;
            mem_hi <= `Zero_Word;
            mem_lo <= `Zero_Word;
            mem_whilo <= `Write_Disable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `Zero_Word;
            mem_reg2 <= `Zero_Word;
            mem_cp0_reg_we <= `Write_Disable;
            mem_cp0_reg_write_addr <= 5'b0;
            mem_cp0_reg_data <= `Zero_Word;
            mem_excepttype <= `Zero_Word;
            mem_current_inst_addr <= `Zero_Word;
            mem_is_in_delayslot <= `NotInDelaySlot;
        end else if(stall[3] == `NoStop)begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
            mem_cp0_reg_we <= ex_cp0_reg_we;
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
            mem_cp0_reg_data <= ex_cp0_reg_data;
            mem_excepttype <= ex_excepttype;
            mem_current_inst_addr <= ex_current_inst_addr;
            mem_is_in_delayslot <= ex_is_in_delayslot;
        end
    end

    always@(posedge clk)begin
        if(rst==`Rst_Enable)begin
            hilo_o <= {2{`Zero_Word}};
            cnt_o <= 2'b0;
        end else if(stall[3] == `Stop && stall[4] == `NoStop)begin
            hilo_o <= hilo_i;
            cnt_o <= cnt_i;
        end else if(stall[3] == `NoStop)begin
            hilo_o <= {2{`Zero_Word}};
            cnt_o <= 2'b0;
        end else begin
            hilo_o <= hilo_i;
            cnt_o <= cnt_i;
        end
    end
endmodule
