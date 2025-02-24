/**************************************
@ filename    : pc_reg.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module pc_reg(
    input                               rst                        ,
    input                               clk                        ,
    input              [   5:0]         stall                      ,//pause signal from ctrl
    input                               branch_flag_i              ,//wether branch
    input              [`Reg-1:0]       branch_target_addr_i       ,//target addr
    input                               flush                      ,
    input              [`Inst_Addr-1:0] new_pc                     ,//new pc from ctrl
    output reg         [`Inst_Addr-1:0] pc                         ,//address for reading
    output reg                          ce                          //order register enable
    );

always@(posedge clk)
    begin
        if(rst == `Rst_Enable)begin
            ce <= `Chip_Disable;
        end else begin
            ce <= `Chip_Enable;
        end
    end
    
always@(posedge clk)
    begin
        if(rst == `Rst_Enable)begin
            pc <= `Zero_Word;                                            //in case ce==1 but rst==0
        end else if(ce == `Chip_Disable)begin
            pc <= `Zero_Word;
        end else if(flush == `Flush)begin
            pc <= new_pc;
        end else if(stall[0] == `NoStop)begin
            if(branch_flag_i == `Branch)begin
                pc <= branch_target_addr_i;
            end else begin
                pc <= pc + 4'd4;
            end
        end
    end
endmodule
