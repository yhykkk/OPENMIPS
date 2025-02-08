/**************************************
@ filename    : ram.v
@ author      : yhykkk
@ create time : 2025/02/07
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module ram(
    input                               clk                        ,
    input                               ce                         ,
    input                               we                         ,
    input              [`Inst_Addr-1:0] addr                       ,
    input              [   3:0]         sel                        ,
    input              [`Reg-1:0]       data_i                     ,
    output reg         [`Reg-1:0]       data_o                      
);

reg                    [`Byte_Width-1:0] data_mem0 [`Num_Inst_Mem-1:0]                           ;
reg                    [`Byte_Width-1:0] data_mem1 [`Num_Inst_Mem-1:0]                           ;
reg                    [`Byte_Width-1:0] data_mem2 [`Num_Inst_Mem-1:0]                           ;
reg                    [`Byte_Width-1:0] data_mem3 [`Num_Inst_Mem-1:0]                           ;

    always@(posedge clk)begin
        if(ce == `Chip_Disable)begin
        end else if(we == `Write_Enable)begin
            if(sel[3] == 1'b1)begin
                data_mem3[addr[`Inst_Addr_Use+1:2]] <= data_i[31:24];
            end if(sel[2] == 1'b1)begin
                data_mem2[addr[`Inst_Addr_Use+1:2]] <= data_i[23:16];
            end if(sel[1] == 1'b1)begin
                data_mem1[addr[`Inst_Addr_Use+1:2]] <= data_i[15:8];
            end if(sel[0] == 1'b1)begin
                data_mem0[addr[`Inst_Addr_Use+1:2]] <= data_i[7:0];
            end
        end
    end

    always@(*)begin
        if(ce == `Chip_Disable)begin
            data_o = `Zero_Word;
        end else if(we == `Write_Disable)begin
            data_o = {(data_mem3[addr[`Inst_Addr_Use+1:2]]),
                    (data_mem2[addr[`Inst_Addr_Use+1:2]]),
                    (data_mem1[addr[`Inst_Addr_Use+1:2]]),
                    (data_mem0[addr[`Inst_Addr_Use+1:2]])};
        end else begin
            data_o = `Zero_Word;
        end
    end

endmodule