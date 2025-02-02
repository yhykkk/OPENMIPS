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
    output reg         [`Alu_Sel-1:0]   ex_alusel                  ,
    output reg         [`Alu_Op-1:0]    ex_aluop                   ,
    output reg         [`Reg-1:0]       ex_reg1                    ,
    output reg         [`Reg-1:0]       ex_reg2                    ,
    output reg         [`Reg_Addr-1:0]  ex_wd                      ,
    output reg                          ex_wreg                     
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
                end else begin
                    ex_alusel <= id_alusel;
                    ex_aluop  <= id_aluop;
                    ex_reg1   <= id_reg1;
                    ex_reg2   <= id_reg2;
                    ex_wd     <= id_wd;
                    ex_wreg   <= id_wreg;
                end
            end
endmodule
