/**************************************
@ filename    : wishbone_bus_if.v
@ author      : yhykkk
@ create time : 2025/02/23 
@ version     : v1.1.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module wishbone_bus_if(
    input                               clk                        ,
    input                               rst                        ,
    //ctrl
    input              [   5:0]         stall_i                    ,
    input                               flush_i                    ,
    //cpu
    input                               cpu_ce_i                   ,//instr enable
    input              [`Reg-1:0]       cpu_data_i                 ,//fixed 32 bit
    input              [`Inst_Addr-1:0] cpu_addr_i                 ,
    input                               cpu_we_i                   ,//instr write only
    input              [   3:0]         cpu_sel_i                  ,
    output reg         [`Reg-1:0]       cpu_data_o                 ,
    //wishbone
    input              [`Reg-1:0]       wishbone_data_i            ,
    input                               wishbone_ack_i             ,
    output reg         [`Inst_Addr-1:0] wishbone_addr_o            ,
    output reg         [`Reg-1:0]       wishbone_data_o            ,
    output reg                          wishbone_cyc_o             ,
    output reg                          wishbone_stb_o             ,
    output reg                          wishbone_we_o              ,
    output reg         [   3:0]         wishbone_sel_o             ,
    
    output reg stall_req
);

reg                    [   1:0]         wishbone_state             ;//00:idle, 01:busy, 11:stall
reg                    [`Reg-1:0]       rd_buf                     ;//store data

always@(posedge clk)begin
    if(rst == `Rst_Enable)begin
        wishbone_state <= `WB_IDLE;
        wishbone_addr_o <= `Zero_Word;
        wishbone_data_o <= `Zero_Word;
        wishbone_we_o <= `Write_Disable;
        wishbone_sel_o <= 4'b0000;
        wishbone_cyc_o <= 1'b0;
        wishbone_stb_o <= 1'b0;
        rd_buf <= `Zero_Word;
    end else begin
        case(wishbone_state)
            `WB_IDLE:begin
                if(cpu_ce_i == `Chip_Enable && flush_i == `NotFlush)begin
                    wishbone_stb_o <= 1'b1;
                    wishbone_cyc_o <= 1'b1;
                    wishbone_addr_o <= cpu_addr_i;
                    wishbone_data_o <= cpu_data_i;
                    wishbone_we_o <= cpu_we_i;
                    wishbone_sel_o <= cpu_sel_i;
                    wishbone_state <= `WB_BUSY;
                    rd_buf <= `Zero_Word;
                end
            end
            `WB_BUSY:begin
                if(wishbone_ack_i == 1'b1)begin
                    wishbone_stb_o <= 1'b0;
                    wishbone_cyc_o <= 1'b0;
                    wishbone_addr_o <= `Zero_Word;
                    wishbone_data_o <= `Zero_Word;
                    wishbone_we_o <= `Write_Disable;
                    wishbone_sel_o <= 4'b0000;
                    wishbone_state <= `WB_IDLE;
                    if(cpu_we_i == `Write_Disable)begin
                        rd_buf <= wishbone_data_i;
                    end
                    if(stall_i != 6'b000000)begin
                        wishbone_state <= `WB_WAIT_FOR_STALL;
                    end
                end else if(flush_i == `Flush)begin
                    wishbone_stb_o <= 1'b0;
                    wishbone_cyc_o <= 1'b0;
                    wishbone_addr_o <= `Zero_Word;
                    wishbone_data_o <= `Zero_Word;
                    wishbone_we_o <= `Write_Disable;
                    wishbone_sel_o <= 4'b0000;
                    wishbone_state <= `WB_IDLE;
                    rd_buf <= `Zero_Word;
                end
            end
            `WB_WAIT_FOR_STALL:begin
                if(stall_i == 6'b000000)begin
                    wishbone_state <= `WB_IDLE;
                end
            end
            default : begin
            end       
        endcase
    end
end
endmodule