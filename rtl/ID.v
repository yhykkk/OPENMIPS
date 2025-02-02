/**************************************
@ filename    : ID.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module ID(
    input                               rst                        ,
    input              [`Inst_Addr-1:0] pc_i                       ,//address for decoder
    input              [`Inst_Data-1:0] inst_i                     ,//instruction for decoder
    input              [`Reg-1:0]       reg1_data_i                ,//data read in regfile
    input              [`Reg-1:0]       reg2_data_i                ,
    output reg                          reg1_read_o                ,//read enable for regfile
    output reg                          reg2_read_o                ,
    output reg         [`Reg_Addr-1:0]  reg1_addr_o                ,//read address for regfile
    output reg         [`Reg_Addr-1:0]  reg2_addr_o                ,
    output reg         [`Alu_Op-1:0]    aluop_o                    ,//operational subclass
    output reg         [`Alu_Sel-1:0]   alusel_o                   ,//operational class
    output reg         [`Reg-1:0]       reg1_o                     ,//Դ������
    output reg         [`Reg-1:0]       reg2_o                     ,
    output reg         [`Reg_Addr-1:0]  wd_o                       ,//address for aimed register
    output reg                          wreg_o                      //write enable for aimed register
    );
    
    //get code
wire                   [   5:0]         op                         ;
wire                   [   4:0]         op2                        ;
wire                   [   5:0]         op3                        ;
wire                   [   4:0]         op4                        ;
    
    assign op  = inst_i [31:26] ;
    assign op2 = inst_i [10:6] ;
    assign op3 = inst_i [5:0] ;
    assign op4 = inst_i [20:16] ;
    //save imm
reg                    [`Reg-1:0]       imm                        ;//immediate number
    //inst validity
reg                                     instvalid                  ;
    
    //decoding
    always@(*)begin
        if(rst == `Rst_Enable)begin
            reg1_read_o = `Read_Disable;
            reg2_read_o = `Read_Disable;
            reg1_addr_o = `Reg_Zero;
            reg2_addr_o = `Reg_Zero;
            aluop_o     = `EXE_NOP_OP;
            alusel_o    = `EXE_RES_NOP;
            wd_o        = `Reg_Zero;
            wreg_o      = `Write_Disable;
            imm         = `Zero_Word;
            instvalid   = `Inst_Valid;
        end else begin
            reg1_read_o = `Read_Disable;
            reg2_read_o = `Read_Disable;
            reg1_addr_o = inst_i[25:21];    //reg1 in regfile rs
            reg2_addr_o = inst_i[20:16];    //reg2 in regfile rt
            aluop_o     = `EXE_NOP_OP;
            alusel_o    = `EXE_RES_NOP;
            wd_o        = inst_i[15:11];     //rd
            wreg_o      = `Write_Disable;
            imm         = `Zero_Word;
            instvalid   = `Inst_Valid;
        
            case(op)
                `EXE_ORI: begin
                    aluop_o  = `EXE_OR_OP;
                    alusel_o = `EXE_RES_LOGIC;
                    wreg_o   = `Write_Enable;         //ori need to write into the aimed register
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {16'b0,inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
            endcase
        end
        
    end
    
    always@(*)
        begin
            if(rst==`Rst_Enable)begin
                reg1_o = 32'b0;
            end else if(reg1_read_o == `Read_Enable)begin
                reg1_o = reg1_data_i;                         //from register
            end else if(reg1_read_o == `Read_Disable)begin
                reg1_o = imm;                                 //from immediate num
            end else begin        
                reg1_o = 32'b0;
            end
        end
        
    always@(*)
        begin
            if(rst==`Rst_Enable)begin
                reg2_o = 32'b0;
            end else if(reg2_read_o == `Read_Enable)begin
                reg2_o = reg1_data_i;
            end else if(reg2_read_o == `Read_Disable)begin
                reg2_o = imm;
            end else begin
                reg2_o = 32'b0;
            end
        end
endmodule
