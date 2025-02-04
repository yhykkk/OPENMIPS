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
reg                    [`Reg-1:0]       shift_out                  ;
    
    always@(*)begin
        if(rst==`Rst_Enable)begin
            logic_out = `Zero_Word;
        end else begin
            case(aluop_i)
                `EXE_OR_OP: begin                                   //or
                    logic_out = reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin                                  //and
                    logic_out = reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin                                  //nor
                    logic_out = ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin                                  //xor
                    logic_out = reg1_i ^ reg2_i;
                end
                default : begin
                    logic_out = `Zero_Word;
                end
            endcase
        end
    end

    always@(*)begin
        if(rst==`Rst_Enable)begin
            shift_out = `Zero_Word;
        end else begin
            case(aluop_i)
                `EXE_SLL_OP: begin                                   //sll
                    shift_out = reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin                                   //srl
                    shift_out = reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin                                   //srl
                    shift_out = ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                end
                default : begin
                    shift_out = `Zero_Word;
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
            `EXE_RES_SHIFT:  begin
                wdata_o = shift_out;
            end
            default:  begin
                wdata_o = `Zero_Word;
            end
        endcase
    end
endmodule
