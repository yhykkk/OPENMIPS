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
    //signal for hi/lo in web & mem
    input              [`Reg-1:0]       hi_i                       ,
    input              [`Reg-1:0]       lo_i                       ,
    input                               mem_whilo_i                ,
    input              [`Reg-1:0]       mem_hi_i                   ,
    input              [`Reg-1:0]       mem_lo_i                   ,
    input                               wb_whilo_i                 ,
    input              [`Reg-1:0]       wb_hi_i                    ,
    input              [`Reg-1:0]       wb_lo_i                    ,

    output reg         [`Reg_Addr-1:0]  wd_o                       ,
    output reg                          wreg_o                     ,
    output reg         [`Reg-1:0]       wdata_o                    ,
    //write for hi/lo in ex
    output reg                          whilo_o                    ,
    output reg         [`Reg-1:0]       hi_o                       ,
    output reg         [`Reg-1:0]       lo_o                        
    );
    
reg                    [`Reg-1:0]       logic_out                  ;
reg                    [`Reg-1:0]       shift_out                  ;
reg                    [`Reg-1:0]       move_out                   ;
reg                    [`Reg-1:0]       HI                         ;
reg                    [`Reg-1:0]       LO                         ;
    
    always@(*)begin
        if(rst == `Rst_Enable) begin
            {HI , LO} = {`Zero_Word,`Zero_Word};
        end else if(mem_whilo_i == `Write_Enable) begin
            {HI , LO} = {mem_hi_i,mem_lo_i};
        end else if(wb_whilo_i == `Write_Enable) begin
            {HI , LO} = {wb_hi_i,wb_lo_i};
        end else begin
            {HI , LO} = {hi_i , lo_i};
        end
    end

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
        if(rst==`Rst_Enable)begin
            move_out = `Zero_Word;
        end else begin
            case(aluop_i)
                `EXE_MFHI_OP: begin
                    move_out = HI;
                end
                `EXE_MFLO_OP: begin
                    move_out = LO;
                end
                `EXE_MOVZ_OP: begin
                    move_out = reg1_i;
                end
                `EXE_MOVN_OP: begin
                    move_out = reg1_i;
                end
                default begin
                    move_out = `Zero_Word;
                end            
            endcase
        end
    end

    always@(*)begin
        if(rst == `Rst_Enable)begin
            whilo_o = `Write_Disable;
            hi_o = `Zero_Word;
            lo_o = `Zero_Word;
        end else if(aluop_i == `EXE_MTHI_OP)begin
            whilo_o = `Write_Enable;
            hi_o = reg1_i;
            lo_o = LO;
        end else if(aluop_i == `EXE_MTLO_OP)begin
            whilo_o = `Write_Enable;
            hi_o = HI;
            lo_o = reg1_i;
        end else begin
            whilo_o = `Write_Disable;
            hi_o = `Zero_Word;
            lo_o = `Zero_Word;
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
            `EXE_RES_MOVE: begin
                wdata_o = move_out;
            end
            default:  begin
                wdata_o = `Zero_Word;
            end
        endcase
    end

endmodule
