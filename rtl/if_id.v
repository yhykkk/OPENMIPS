/**************************************
@ filename    : if_id.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module if_id(
    input                               rst                        ,
    input                               clk                        ,
    input              [`Inst_Addr-1:0] if_pc                      ,//address for instr
    input              [`Inst_Data-1:0] if_inst                    ,//instr
    input              [   5:0]         stall                      ,//pause signal from ctrl
    output reg         [`Inst_Addr-1:0] id_pc                      ,//output address for instr
    output reg         [`Inst_Data-1:0] id_inst                     //output instr
    );
    
always@(posedge clk)
    begin
        if(rst == `Rst_Enable)begin
           id_pc <= `No_Addr; 
           id_inst <= `Zero_Word;
        end else if(stall[1] == `Stop && stall[2] == `NoStop)begin
           id_pc <= `Zero_Word; 
           id_inst <= `Zero_Word; 
        end else if(stall[1] == `NoStop)begin
           id_pc <= if_pc; 
           id_inst <= if_inst; 
        end
    end 
endmodule
