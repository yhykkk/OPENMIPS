/**************************************
@ filename    : ctrl.v
@ author      : yhykkk
@ create time : 2025/02/06 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

//pause request is usseful for those insts with more than 1 clk
module ctrl(
    input                               rst                        ,
    input                               stallreq_from_id           ,//pause request from id
    input                               stallreq_from_ex           ,//pause request from ex
    input                               stallreq_from_if           ,//pause request from wb_if
    input                               stallreq_from_mem          ,//pause request from wb_mem
    input              [`Reg-1:0]       cp0_epc_i                  ,
    input              [  31:0]         excepttype_i               ,
    output reg         [   5:0]         stall                      ,
    output reg                          flush                      ,
    output reg         [`Inst_Addr-1:0] new_pc                      
);

always@(*)begin
    if(rst == `Rst_Enable)begin
        stall = 6'b0;
        flush = 1'b0;
        new_pc = `Zero_Word;
    end else if(excepttype_i !=`Zero_Word)begin
        flush = 1'b1;
        stall = 6'b0;
        case(excepttype_i)
            32'h00000001:begin
                new_pc = 32'h00000020;
            end
            32'h00000008:begin
                new_pc = 32'h00000040;
            end
            32'h0000000a:begin
                new_pc = 32'h00000040;
            end
            32'h0000000d:begin
                new_pc = 32'h00000040;
            end
            32'h0000000e:begin
                new_pc = cp0_epc_i;
            end
            default :begin
            end    
        endcase
    end else if(stallreq_from_mem == `Stop)begin
        flush = 1'b0;
        stall = 6'b011111; 
    end else if(stallreq_from_ex == `Stop)begin
        flush = 1'b0;
        stall = 6'b001111;                                          //ex: (mem,web 0) other pause
    end else if(stallreq_from_id == `Stop)begin
        flush = 1'b0;
        stall = 6'b000111;                                          //id: (ex,mem,web 0) other pause
    end else if(stallreq_from_if == `Stop)begin
        flush = 1'b0;
        stall = 6'b000111;                                          //if: 000111: for delayslot must not be seen as none(in if stall)
    end else begin
        stall = 6'b0;
        flush = 1'b0;
        new_pc = `Zero_Word;
    end 
end

endmodule