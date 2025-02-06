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
    output reg         [   5:0]         stall                       
);

always@(*)begin
    if(rst == `Rst_Enable)begin
        stall = 6'b0;
    end else if(stallreq_from_ex == `Stop)begin
        stall = 6'b001111;                                          //ex: (mem,web 0) other pause
    end else if(stallreq_from_id == `Stop)begin
        stall = 6'b000111;                                          //id: (ex,mem,web 0) other pause
    end else begin
        stall = 6'b0;
    end 
end

endmodule