/**************************************
@ filename    : ex.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module ex(
    input                               rst                        ,
    input              [`Alu_Sel-1:0]   alusel_i                   ,
    input              [`Alu_Op-1:0]    aluop_i                    ,
    input              [`Reg-1:0]       reg1_i                     ,
    input              [`Reg-1:0]       reg2_i                     ,
    input              [`Reg_Addr-1:0]  wd_i                       ,
    input                               wreg_i                     ,
    output reg         [`Reg_Addr-1:0]  wd_o                       ,
    output reg                          wreg_o                     ,
    output reg         [`Reg-1:0]       wdata_o                     
    );
    
reg                    [`Reg-1:0]       logic_out                  ;
    
    always@(*)begin
        if(rst==`Rst_Enable)begin
            logic_out = `Zero_Word;
        end else begin
            case(aluop_i)
                `EXE_OR_OP: begin                                   //ori
                    logic_out = reg1_i | reg2_i;
                end
                default : begin
                    logic_out = `Zero_Word;
                end
            endcase
        end
    end
    
    always@(*)begin
        wd_o = wd_i;
        wreg_o = wreg_i;
        case(alusel_i)
            `EXE_RES_LOGIC:  begin
                wdata_o = logic_out;
            end
            default:  begin
                wdata_o = `Zero_Word;
            end
        endcase
    end
endmodule
