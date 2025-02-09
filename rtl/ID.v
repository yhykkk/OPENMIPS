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
    
    //write signal from ex stage
    input                               ex_wreg_i                  ,
    input              [`Reg_Addr-1:0]  ex_wd_i                    ,
    input              [`Reg-1:0]       ex_wdata_i                 ,

    //write signal from mem stage
    input                               mem_wreg_i                 ,
    input              [`Reg_Addr-1:0]  mem_wd_i                   ,
    input              [`Reg-1:0]       mem_wdata_i                ,

    input                               is_in_delayslot_i          ,//wether in delayslot inst
    input              [`Alu_Op-1:0]    ex_aluop_i                 ,

    output reg                          reg1_read_o                ,//read enable for regfile
    output reg                          reg2_read_o                ,
    output reg         [`Reg_Addr-1:0]  reg1_addr_o                ,//read address for regfile
    output reg         [`Reg_Addr-1:0]  reg2_addr_o                ,
    output reg         [`Alu_Op-1:0]    aluop_o                    ,//operational subclass
    output reg         [`Alu_Sel-1:0]   alusel_o                   ,//operational class
    output reg         [`Reg-1:0]       reg1_o                     ,//Դ������
    output reg         [`Reg-1:0]       reg2_o                     ,
    output reg         [`Reg_Addr-1:0]  wd_o                       ,//address for aimed register
    output reg                          wreg_o                     ,//write enable for aimed register

    output reg                          branch_flag_o              ,//detect branch inst
    output reg                          is_in_delayslot_o          ,//tell ex wether is delayslot inst
    output reg                          next_inst_in_delayslot_o   ,//detect branch inst then next is delayslot inst
    output reg         [`Inst_Addr-1:0] branch_target_addr_o       ,//output for branch addr
    output reg         [`Inst_Addr-1:0] link_addr_o                ,//save inst addr return
    output reg         [`Inst_Data-1:0] inst_o                     ,

    output                              stallreq                   ,
    output             [  31:0]         excepttype_o               ,
    output             [`Reg-1:0]       current_inst_addr_o         
    );
    
    //get code
wire                   [   5:0]         op                         ;
wire                   [   4:0]         op2                        ;
wire                   [   5:0]         op3                        ;
wire                   [   4:0]         op4                        ;
    
    assign op  = inst_i [31:26] ;                                   //指令码
    assign op2 = inst_i [10:6] ;
    assign op3 = inst_i [5:0] ;                                     //功能码
    assign op4 = inst_i [20:16] ;
    //save imm
reg                    [`Reg-1:0]       imm                        ;//immediate number
    //inst validity
reg                                     instvalid                  ;

wire                   [`Reg-1:0]       pc_plus_8                  ;
wire                   [`Reg-1:0]       pc_plus_4                  ;

wire                   [`Reg-1:0]       imm_sll2_signedext         ;

reg                                     stallreq_for_reg1_loadrelate;
reg                                     stallreq_for_reg2_loadrelate;

wire                                    pre_inst_is_load           ;

reg                                     excepttype_is_syscall      ;//syscall
reg                                     excepttype_is_eret         ;//eret

assign excepttype_o = {19'b0,excepttype_is_eret,2'b0,instvalid,excepttype_is_syscall,8'b0};

assign current_inst_addr_o = pc_i;

assign pre_inst_is_load = ((ex_aluop_i == `EXE_LB_OP) ||
                          (ex_aluop_i == `EXE_LBU_OP) ||
                          (ex_aluop_i == `EXE_LH_OP) ||
                          (ex_aluop_i == `EXE_LHU_OP) ||
                          (ex_aluop_i == `EXE_LW_OP) ||
                          (ex_aluop_i == `EXE_LWR_OP) ||
                          (ex_aluop_i == `EXE_LWL_OP) ||
                          (ex_aluop_i == `EXE_LL_OP) ||
                          (ex_aluop_i == `EXE_SC_OP)) ? 1'b1 : 1'b0;

always@(*) begin
    stallreq_for_reg1_loadrelate = `NoStop;
    if(rst == `Rst_Enable)begin
    end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg1_addr_o && reg1_read_o == 1'b1)begin
        stallreq_for_reg1_loadrelate = `Stop;
    end
end

always@(*) begin
    stallreq_for_reg2_loadrelate = `NoStop;
    if(rst == `Rst_Enable)begin
    end else if(pre_inst_is_load == 1'b1 && ex_wd_i == reg2_addr_o && reg2_read_o == 1'b1)begin
        stallreq_for_reg2_loadrelate = `Stop;
    end
end

assign stallreq = (stallreq_for_reg1_loadrelate == `Stop || stallreq_for_reg2_loadrelate == `Stop) ;

assign pc_plus_8 = pc_i + 8; //save the second inst
assign pc_plus_4 = pc_i + 4; //save the following inst

assign imm_sll2_signedext = { {14{inst_i[15]}}, inst_i[15:0], 2'b00};

    always@(*)begin
        inst_o = inst_i;
    end

    always@(*)begin
        if(rst == `Rst_Enable)begin
            is_in_delayslot_o = `NotInDelaySlot;
        end else begin
            is_in_delayslot_o = is_in_delayslot_i;
        end
    end

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
            link_addr_o = `Zero_Word;
            branch_target_addr_o = `Zero_Word;
            branch_flag_o = `NotBranch;
            next_inst_in_delayslot_o = `NotInDelaySlot;
            excepttype_is_syscall = `False;
            excepttype_is_eret = `False;
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
            link_addr_o = `Zero_Word;
            branch_target_addr_o = `Zero_Word;
            branch_flag_o = `NotBranch;
            next_inst_in_delayslot_o = `NotInDelaySlot;
            excepttype_is_syscall = `False;
            excepttype_is_eret = `False;
            case(op)
                `EXE_SPECIAL_INST: begin
                    case(op2) 
                        5'b00000 : begin
                            case(op3)
                                `EXE_OR : begin
                                    aluop_o = `EXE_OR_OP;
                                    alusel_o = `EXE_RES_LOGIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_AND : begin
                                    aluop_o = `EXE_AND_OP;
                                    alusel_o = `EXE_RES_LOGIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_XOR : begin
                                    aluop_o = `EXE_XOR_OP;
                                    alusel_o = `EXE_RES_LOGIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_NOR : begin
                                    aluop_o = `EXE_NOR_OP;
                                    alusel_o = `EXE_RES_LOGIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SLLV : begin
                                    aluop_o = `EXE_SLL_OP;
                                    alusel_o = `EXE_RES_SHIFT;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SRLV : begin
                                    aluop_o = `EXE_SRL_OP;
                                    alusel_o = `EXE_RES_SHIFT;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SRAV : begin
                                    aluop_o = `EXE_SRA_OP;
                                    alusel_o = `EXE_RES_SHIFT;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SYNC : begin
                                    aluop_o = `EXE_NOP_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Disable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MFHI : begin
                                    aluop_o = `EXE_MFHI_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Disable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MFLO : begin
                                    aluop_o = `EXE_MFLO_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Disable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MTHI : begin
                                    aluop_o = `EXE_MTHI_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MTLO : begin
                                    aluop_o = `EXE_MTLO_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MOVN : begin
                                    aluop_o = `EXE_MOVN_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                    if(reg2_o != `Zero_Word) begin
                                        wreg_o = `Write_Enable;
                                    end else begin
                                        wreg_o = `Write_Disable;
                                    end
                                end
                                `EXE_MOVZ : begin
                                    aluop_o = `EXE_MOVZ_OP;
                                    alusel_o = `EXE_RES_MOVE;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                    if(reg2_o == `Zero_Word) begin
                                        wreg_o = `Write_Enable;
                                    end else begin
                                        wreg_o = `Write_Disable;
                                    end
                                end
                                `EXE_SLT : begin                   //slt,rd,rs,rt
                                    aluop_o = `EXE_SLT_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SLTU : begin                   //sltu,rd,rs,rt
                                    aluop_o = `EXE_SLTU_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_ADD : begin                   //add,rd,rs,rt(overfolow unsaved)
                                    aluop_o = `EXE_ADD_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_ADDU : begin                   //addu,rd,rs,rt(overfolow not checked)
                                    aluop_o = `EXE_ADDU_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SUB : begin                   //sub,rd,rs,rt(overfolow unsaved)
                                    aluop_o = `EXE_SUB_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_SUBU : begin                   //subu,rd,rs,rt(overfolow not checked)
                                    aluop_o = `EXE_SUBU_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Enable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MULT : begin                   //mult,rs,rt {hi,lo} = rs*rt
                                    aluop_o = `EXE_MULT_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Disable;        //result into hi/lo
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_MULTU : begin                   //multu,rs,rt {hi,lo} = rs*rt
                                    aluop_o = `EXE_MULTU_OP;
                                    alusel_o = `EXE_RES_ARITHMETIC;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_DIV : begin                   //div,rs,rt 
                                    aluop_o = `EXE_DIV_OP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_DIVU : begin                  //divu,rs,rt 
                                    aluop_o = `EXE_DIVU_OP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;
                                end
                                `EXE_JR : begin                  //jr,rs  
                                    aluop_o = `EXE_JR_OP;        //pc <= rs
                                    wreg_o = `Write_Disable;
                                    alusel_o = `EXE_RES_JUMP_BRANCH;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;
                                    link_addr_o = `Zero_Word;
                                    branch_target_addr_o = reg1_o;
                                    branch_flag_o = `Branch;
                                    next_inst_in_delayslot_o = `InDelaySlot;
                                end
                                 `EXE_JALR : begin                  //jalr,rs or jalr,rd,rs
                                    aluop_o = `EXE_JALR_OP;         //pc <= rs
                                    wreg_o = `Write_Enable;
                                    alusel_o = `EXE_RES_JUMP_BRANCH;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Disable;
                                    wd_o = inst_i[15:11];
                                    instvalid = `Inst_Valid;
                                    link_addr_o = pc_plus_8;
                                    branch_target_addr_o = reg1_o;
                                    branch_flag_o = `Branch;
                                    next_inst_in_delayslot_o = `InDelaySlot;
                                end  
                                `EXE_TEQ : begin                   //teq,rs,rt 
                                    aluop_o = `EXE_TEQ_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end 
                                `EXE_TGE : begin                   //tge,rs,rt 
                                    aluop_o = `EXE_TGE_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end                            
                                `EXE_TGEU : begin                  //tgeu,rs,rt 
                                    aluop_o = `EXE_TGEU_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end  
                                `EXE_TLT : begin                   //tlt,rs,rt 
                                    aluop_o = `EXE_TLT_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end  
                                `EXE_TLTU : begin                  //tltu,rs,rt 
                                    aluop_o = `EXE_TLTU_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end  
                                `EXE_TNE : begin                   //tne,rs,rt 
                                    aluop_o = `EXE_TNE_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Enable;
                                    reg2_read_o = `Read_Enable;
                                    instvalid = `Inst_Valid;  
                                end 
                                `EXE_SYSCALL : begin               //syscall
                                    aluop_o = `EXE_SYSCALL_OP;
                                    alusel_o = `EXE_RES_NOP;
                                    wreg_o = `Write_Disable;
                                    reg1_read_o = `Read_Disable;
                                    reg2_read_o = `Read_Disable;
                                    instvalid = `Inst_Valid;  
                                    excepttype_is_syscall = `True;
                                end 
                                default : begin
                                end
                            endcase
                        end
                        default : begin
                        end     
                    endcase
                end
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
                 `EXE_ANDI: begin
                    aluop_o  = `EXE_AND_OP;
                    alusel_o = `EXE_RES_LOGIC;
                    wreg_o   = `Write_Enable;         //andi need to write into the aimed register
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {16'b0,inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_XORI: begin
                    aluop_o  = `EXE_XOR_OP;
                    alusel_o = `EXE_RES_LOGIC;
                    wreg_o   = `Write_Enable;         //xori need to write into the aimed register
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {16'b0,inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_LUI: begin
                    aluop_o  = `EXE_OR_OP;
                    alusel_o = `EXE_RES_LOGIC;
                    wreg_o   = `Write_Enable;         //lui need to write into the aimed register
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {inst_i[15:0],16'b0};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_PREF: begin
                    aluop_o  = `EXE_NOP_OP;
                    alusel_o = `EXE_RES_NOP;
                    wreg_o   = `Write_Disable;         //pref do not need to write into the aimed register
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Disable;
                    imm = {16'b0,inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_SLTI: begin                      //slti rt,rs,imm
                    aluop_o  = `EXE_SLT_OP;
                    alusel_o = `EXE_RES_ARITHMETIC;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {{16{inst_i[15]}},inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_SLTIU: begin                      //sltiu rt,rs,imm
                    aluop_o  = `EXE_SLTU_OP;            //区别仅为进行无符号比较
                    alusel_o = `EXE_RES_ARITHMETIC;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {{16{inst_i[15]}},inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_ADDI: begin                      //addi rt,rs,imm
                    aluop_o  = `EXE_ADDI_OP;           
                    alusel_o = `EXE_RES_ARITHMETIC;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {{16{inst_i[15]}},inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                 `EXE_ADDIU: begin                      //addiu rt,rs,imm
                    aluop_o  = `EXE_ADDIU_OP;           //区别为不进行overflow检测
                    alusel_o = `EXE_RES_ARITHMETIC;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    imm = {{16{inst_i[15]}},inst_i[15:0]};
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_J : begin                        //j target 
                    aluop_o = `EXE_J_OP;              
                    wreg_o = `Write_Disable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    link_addr_o = `Zero_Word;
                    branch_target_addr_o = {pc_plus_4[31:28] , inst_i[25:0] , 2'b00};
                    branch_flag_o = `Branch;
                    next_inst_in_delayslot_o = `InDelaySlot;
                end
                `EXE_JAL : begin                        //jal target 
                    aluop_o = `EXE_JAL_OP;              
                    wreg_o = `Write_Enable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = 5'b11111;
                    link_addr_o = pc_plus_8;
                    branch_target_addr_o = {pc_plus_4[31:28] , inst_i[25:0] , 2'b00};
                    branch_flag_o = `Branch;
                    next_inst_in_delayslot_o = `InDelaySlot;
                end
                `EXE_BEQ : begin                        //beq rs,rt,offset 
                    aluop_o = `EXE_BEQ_OP;              
                    wreg_o = `Write_Disable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                    link_addr_o = `Zero_Word;
                    if(reg1_o == reg2_o)begin
                        branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o = `Branch;
                        next_inst_in_delayslot_o = `InDelaySlot;    
                    end
                end
                `EXE_BGTZ : begin                        //bgtz rs,offset 
                    aluop_o = `EXE_BGTZ_OP;              //rs > 0
                    wreg_o = `Write_Disable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    link_addr_o = `Zero_Word;
                    if(reg1_o[31] == 1'b0 && reg1_o != `Zero_Word)begin
                        branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o = `Branch;
                        next_inst_in_delayslot_o = `InDelaySlot;    
                    end
                end
                `EXE_BLEZ : begin                        //blez rs,offset 
                    aluop_o = `EXE_BLEZ_OP;              //rs <= 0
                    wreg_o = `Write_Disable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    link_addr_o = `Zero_Word;
                    if(reg1_o[31] == 1'b1 || reg1_o == `Zero_Word)begin
                        branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o = `Branch;
                        next_inst_in_delayslot_o = `InDelaySlot;    
                    end
                end
                `EXE_BNE : begin                        //bne rs,rt,offset 
                    aluop_o = `EXE_BNE_OP;              //rs != rt
                    wreg_o = `Write_Disable;
                    alusel_o = `EXE_RES_JUMP_BRANCH;
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                    link_addr_o = `Zero_Word;
                    if(reg1_o != reg2_o)begin
                        branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                        branch_flag_o = `Branch;
                        next_inst_in_delayslot_o = `InDelaySlot;    
                    end
                end
                `EXE_LB: begin                          //lb,rs,offset(base)
                    aluop_o  = `EXE_LB_OP;              //load byte
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LBU: begin                         //lbu,rt,offset(base)
                    aluop_o  = `EXE_LBU_OP;             //load byte
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LH: begin                         //lh,rt,offset(base)
                    aluop_o  = `EXE_LH_OP;             //load half word(ADDR_LO==0)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LHU: begin                        //lhu,rt,offset(base)
                    aluop_o  = `EXE_LHU_OP;             //load half word(ADDR_LO==0)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LW: begin                         //lw,rt,offset(base)
                    aluop_o  = `EXE_LW_OP;             //load word(ADDR_LO==00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LWL: begin                        //lwl,rt,offset(base)
                    aluop_o  = `EXE_LWL_OP;            //load (ADDR_LO==00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_LWR: begin                        //lwr,rt,offset(base)
                    aluop_o  = `EXE_LWR_OP;            //load (ADDR_LO==00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_SB: begin                         //sb,rt,offset(base)
                    aluop_o  = `EXE_SB_OP;             //store rt byte
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Disable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                end
                `EXE_SH: begin                         //sb,rt,offset(base)
                    aluop_o  = `EXE_SH_OP;             //store rt half word(addr=0)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Disable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                end
                `EXE_SW: begin                         //sw,rt,offset(base)
                    aluop_o  = `EXE_SW_OP;             //store rt word(addr=00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Disable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                end
                `EXE_SWL: begin                         //swl,rt,offset(base)
                    aluop_o  = `EXE_SWL_OP;             //store rt word(addr=00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Disable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                end
                `EXE_SWR: begin                         //swr,rt,offset(base)
                    aluop_o  = `EXE_SWR_OP;             //store rt word(addr=00)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Disable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;
                    instvalid = `Inst_Valid;
                end
                `EXE_LL: begin
                    aluop_o  = `EXE_LL_OP;              //ll,rt,offset(base)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Disable;
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_SC: begin
                    aluop_o  = `EXE_SC_OP;              //sc,rt,offset(base)
                    alusel_o = `EXE_RES_LOAD_STORE;
                    wreg_o   = `Write_Enable;         
                    reg1_read_o = `Read_Enable;
                    reg2_read_o = `Read_Enable;         //rt(the value to be stored)
                    instvalid = `Inst_Valid;
                    wd_o = inst_i[20:16];
                end
                `EXE_REGIMM_INST: begin
                    case(op4)
                       `EXE_BGEZ : begin                          //bgez rs, offset 
                            aluop_o = `EXE_BGEZ_OP;               //rs >= 0
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            link_addr_o = `Zero_Word;
                            if(reg1_o[31] == 1'b0)begin
                                branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;    
                            end
                        end
                        `EXE_BGEZAL : begin                         //bgezal rs, offset 
                            aluop_o = `EXE_BGEZAL_OP;               //rs >= 0
                            wreg_o = `Write_Enable;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            link_addr_o = pc_plus_8;
                            wd_o = 5'b11111;
                            if(reg1_o[31] == 1'b0)begin
                                branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;    
                            end
                        end  
                       `EXE_BLTZ : begin                          //bltz rs, offset 
                            aluop_o = `EXE_BLTZ_OP;               //rs <= 0
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            link_addr_o = `Zero_Word;
                            if(reg1_o[31] == 1'b1)begin
                                branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;    
                            end
                        end
                        `EXE_BLTZAL : begin                       //bltzal rs, offset 
                            aluop_o = `EXE_BLTZAL_OP;             //rs <= 0
                            wreg_o = `Write_Enable;
                            alusel_o = `EXE_RES_JUMP_BRANCH;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            link_addr_o = pc_plus_8;
                            wd_o = 5'b11111;
                            if(reg1_o[31] == 1'b1)begin
                                branch_target_addr_o = pc_plus_4 + imm_sll2_signedext;
                                branch_flag_o = `Branch;
                                next_inst_in_delayslot_o = `InDelaySlot;    
                            end
                        end
                        `EXE_TEQI : begin                          //teqi rs, imm 
                            aluop_o = `EXE_TEQI_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        `EXE_TGEI : begin                          //tgei rs, imm 
                            aluop_o = `EXE_TGEI_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        `EXE_TGEIU : begin                         //tgeiu rs, imm 
                            aluop_o = `EXE_TGEIU_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        `EXE_TLTI : begin                         //tlti rs, imm 
                            aluop_o = `EXE_TLTI_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        `EXE_TLTIU : begin                        //tltiu rs, imm 
                            aluop_o = `EXE_TLTIU_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        `EXE_TNEI : begin                         //tnei rs, imm 
                            aluop_o = `EXE_TNEI_OP;                
                            wreg_o = `Write_Disable;
                            alusel_o = `EXE_RES_NOP;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                            imm = {{16{inst_i[15]}},inst_i[15:0]};
                        end
                        default :begin
                        end
                    endcase
                end
                `EXE_SPECIAL2_INST: begin
                    case(op3) 
                       `EXE_CLZ : begin                   //clz,rd,rs (count 0)
                            aluop_o = `EXE_CLZ_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            wreg_o = `Write_Enable;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_CLO : begin                   //clo,rd,rs (count 1)
                            aluop_o = `EXE_CLO_OP;
                            alusel_o = `EXE_RES_ARITHMETIC;
                            wreg_o = `Write_Enable;
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Disable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_MUL : begin                   //mul rd,rs,rt
                            aluop_o = `EXE_MUL_OP;
                            alusel_o = `EXE_RES_MUL;
                            wreg_o = `Write_Enable;        //write into general reg
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Enable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_MADD : begin                   //madd rs,rt
                            aluop_o = `EXE_MADD_OP;         //hilo += rs*rt
                            alusel_o = `EXE_RES_MUL;
                            wreg_o = `Write_Disable;        
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Enable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_MADDU : begin                  //maddu rs,rt
                            aluop_o = `EXE_MADDU_OP;        //hilo += rs*rt(unsigned)
                            alusel_o = `EXE_RES_MUL;
                            wreg_o = `Write_Disable;        
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Enable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_MSUB : begin                  //msub rs,rt
                            aluop_o = `EXE_MSUB_OP;        //hilo -= rs*rt
                            alusel_o = `EXE_RES_MUL;
                            wreg_o = `Write_Disable;        
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Enable;
                            instvalid = `Inst_Valid;
                        end
                        `EXE_MSUBU : begin                  //msubu rs,rt
                            aluop_o = `EXE_MSUBU_OP;        //hilo -= rs*rt(unsigned)
                            alusel_o = `EXE_RES_MUL;
                            wreg_o = `Write_Disable;        
                            reg1_read_o = `Read_Enable;
                            reg2_read_o = `Read_Enable;
                            instvalid = `Inst_Valid;
                        end
                        default : begin  
                        end        
                    endcase //end special2
                end
                default begin
                end
            endcase //case op
            if(inst_i[31:21] == 11'b0) begin
                if(op3 == `EXE_SLL)begin
                    aluop_o = `EXE_SLL_OP;
                    alusel_o = `EXE_RES_SHIFT;
                    wreg_o = `Write_Enable;
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Enable;
                    imm [4:0] = inst_i[10:6];
                    wd_o = inst_i[15:11];  
                    instvalid = `Inst_Valid;
                end else if (op3 == `EXE_SRL) begin
                    aluop_o = `EXE_SRL_OP;
                    alusel_o = `EXE_RES_SHIFT;
                    wreg_o = `Write_Enable;
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Enable;
                    imm [4:0] = inst_i[10:6];
                    wd_o = inst_i[15:11];  
                    instvalid = `Inst_Valid;
                end else if (op3 == `EXE_SRA) begin
                    aluop_o = `EXE_SRA_OP;
                    alusel_o = `EXE_RES_SHIFT;
                    wreg_o = `Write_Enable;
                    reg1_read_o = `Read_Disable;
                    reg2_read_o = `Read_Enable;
                    imm [4:0] = inst_i[10:6];
                    wd_o = inst_i[15:11];  
                    instvalid = `Inst_Valid;
                end
            end
            if(inst_i[31:21] == 11'b01000000000 && inst_i[10:0] == 11'b0) begin
                aluop_o = `EXE_MFC0_OP;
                alusel_o = `EXE_RES_MOVE;
                wreg_o = `Write_Enable;
                reg1_read_o = `Read_Disable;
                reg2_read_o = `Read_Disable;
                wd_o = inst_i[20:16];  
                instvalid = `Inst_Valid;
            end else if(inst_i[31:21] == 11'b01000000100 && inst_i[10:0] == 11'b0) begin
                aluop_o = `EXE_MTC0_OP;
                alusel_o = `EXE_RES_MOVE;
                wreg_o = `Write_Disable;
                reg1_read_o = `Read_Enable;
                reg2_read_o = `Read_Disable;
                reg1_addr_o = inst_i[20:16];  
                instvalid = `Inst_Valid;
            end
            if(inst_i == `EXE_ERET)begin
                aluop_o = `EXE_ERET_OP;                
                wreg_o = `Write_Disable;
                alusel_o = `EXE_RES_NOP;
                reg1_read_o = `Read_Disable;
                reg2_read_o = `Read_Disable;
                instvalid = `Inst_Valid;
                excepttype_is_eret = `True;
            end    
        end
    end
    
    always@(*)
        begin
            if(rst==`Rst_Enable)begin
                reg1_o = 32'b0;
            end else if((ex_wreg_i == `Write_Enable) && (reg1_read_o == `Read_Enable) && (ex_wd_i == reg1_addr_o))begin      //read directly from write in ex(RAW conflict1)
                reg1_o = ex_wdata_i;
            end else if((mem_wreg_i == `Write_Enable) && (reg1_read_o == `Read_Enable) && (mem_wd_i == reg1_addr_o))begin    //read directly from write in mem(RAW conflict2)
                reg1_o = mem_wdata_i;
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
            end else if((ex_wreg_i == `Write_Enable) && (reg2_read_o == `Read_Enable) && (ex_wd_i == reg2_addr_o))begin      //read directly from write in ex(RAW conflict1)
                reg2_o = ex_wdata_i;
            end else if((mem_wreg_i == `Write_Enable) && (reg2_read_o == `Read_Enable) && (mem_wd_i == reg2_addr_o))begin    //read directly from write in mem(RAW conflict2)
                reg2_o = mem_wdata_i;
            end else if(reg2_read_o == `Read_Enable)begin
                reg2_o = reg2_data_i;
            end else if(reg2_read_o == `Read_Disable)begin
                reg2_o = imm;
            end else begin
                reg2_o = 32'b0;
            end
        end
endmodule
