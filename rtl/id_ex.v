/**************************************
@ filename    : id_ex.v
@ author      : yhykkk
@ create time : 2025/01/21
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps
module id_ex(
    input                               rst                        ,
    input                               clk                        ,
    input              [`Alu_Sel-1:0]   id_alusel                  ,
    input              [`Alu_Op-1:0]    id_aluop                   ,
    input              [`Reg-1:0]       id_reg1                    ,
    input              [`Reg-1:0]       id_reg2                    ,
    input              [`Reg_Addr-1:0]  id_wd                      ,
    input                               id_wreg                    ,
    input              [   5:0]         stall                      ,//pause signal from ctrl
    input              [`Reg-1:0]       id_link_addr               ,//save inst
    input                               id_is_in_delayslot         ,
    input                               next_inst_in_delayslot_i   ,
    input              [`Inst_Addr-1:0] id_inst                    ,
    input                               flush                      ,
    input              [`Reg-1:0]       id_current_inst_addr       ,
    input              [  31:0]         id_excepttype              ,
    output reg         [`Alu_Sel-1:0]   ex_alusel                  ,
    output reg         [`Alu_Op-1:0]    ex_aluop                   ,
    output reg         [`Reg-1:0]       ex_reg1                    ,
    output reg         [`Reg-1:0]       ex_reg2                    ,
    output reg         [`Reg_Addr-1:0]  ex_wd                      ,
    output reg                          ex_wreg                    ,
    output reg         [`Reg-1:0]       ex_link_addr               ,
    output reg                          ex_is_in_delayslot         ,
    output reg                          is_in_delayslot_o          ,
    output reg         [`Inst_Addr-1:0] ex_inst                    ,
    output reg         [  31:0]         ex_excepttype              ,
    output reg         [`Reg-1:0]       ex_current_inst_addr        
        );
        
        always@(posedge clk)
            begin
                if(rst==`Rst_Enable)begin
                    ex_alusel <= `EXE_RES_NOP;
                    ex_aluop  <= `EXE_NOP_OP;
                    ex_reg1   <= `Zero_Word;
                    ex_reg2   <= `Zero_Word;
                    ex_wd     <= `Reg_Zero;
                    ex_wreg   <= `Write_Disable;
                    ex_link_addr <= `Zero_Word;
                    ex_is_in_delayslot <= `NotInDelaySlot;
                    is_in_delayslot_o <= `NotInDelaySlot;
                    ex_inst <= `Zero_Word;
                    ex_excepttype <= `Zero_Word;
                    ex_current_inst_addr <= `Zero_Word;
                end else if(flush == `Flush)begin
                    ex_alusel <= `EXE_RES_NOP;
                    ex_aluop  <= `EXE_NOP_OP;
                    ex_reg1   <= `Zero_Word;
                    ex_reg2   <= `Zero_Word;
                    ex_wd     <= `Reg_Zero;
                    ex_wreg   <= `Write_Disable;
                    ex_link_addr <= `Zero_Word;
                    ex_is_in_delayslot <= `NotInDelaySlot;
                    is_in_delayslot_o <= `NotInDelaySlot;
                    ex_inst <= `Zero_Word;
                    ex_excepttype <= `Zero_Word;
                    ex_current_inst_addr <= `Zero_Word;
                end else if(stall[2] == `Stop && stall[3] == `NoStop)begin
                    ex_alusel <= `EXE_RES_NOP;
                    ex_aluop  <= `EXE_NOP_OP;
                    ex_reg1   <= `Zero_Word;
                    ex_reg2   <= `Zero_Word;
                    ex_wd     <= `Reg_Zero;
                    ex_wreg   <= `Write_Disable;
                    ex_link_addr <= `Zero_Word;
                    ex_is_in_delayslot <= `NotInDelaySlot;
                    is_in_delayslot_o <= `NotInDelaySlot;
                    ex_inst <= `Zero_Word;
                    ex_excepttype <= `Zero_Word;
                    ex_current_inst_addr <= `Zero_Word;
                end else if(stall[2] == `NoStop)begin
                    ex_alusel <= id_alusel;
                    ex_aluop  <= id_aluop;
                    ex_reg1   <= id_reg1;
                    ex_reg2   <= id_reg2;
                    ex_wd     <= id_wd;
                    ex_wreg   <= id_wreg;
                    ex_link_addr <= id_link_addr;
                    ex_is_in_delayslot <= id_is_in_delayslot;
                    is_in_delayslot_o <= next_inst_in_delayslot_i;
                    ex_inst <= id_inst;
                    ex_excepttype <= id_excepttype;
                    ex_current_inst_addr <= id_current_inst_addr;
                end
            end
endmodule
