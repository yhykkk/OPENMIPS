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
reg                    [`Reg-1:0]       arithmetic_out             ;
reg                    [`Reg-1:0]       HI                         ;
reg                    [`Reg-1:0]       LO                         ;
reg                    [`Reg_Double-1:0]mul_out                    ;//mul result

wire                                    ov_sum                     ;//save result for overflow
wire                                    reg1_eq_reg2               ;//op1 == op2
wire                                    reg1_lt_reg2               ;//op1 < op2
wire                   [`Reg-1:0]       reg2_i_mux                 ;//reg2补码
wire                   [`Reg-1:0]       reg1_i_not                 ;//reg1取反
wire                   [`Reg-1:0]       result_sum                 ;//add sum
wire                   [`Reg-1:0]       opdata1_mult               ;
wire                   [`Reg-1:0]       opdata2_mult               ;
wire                   [`Reg_Double-1:0]hilo_temp                  ;//multi result temp


//variable process 
//two's complement(补码可用于简化减法和比较操作)
assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP)||
                    (aluop_i == `EXE_SUBU_OP)||
                    (aluop_i == `EXE_SLT_OP)) ? (~reg2_i)+1 : reg2_i;

//turn all to sum
assign result_sum = reg1_i + reg2_i_mux;

//overflow types (2 conditions)
assign ov_sum = (((!reg1_i[31]) && (!reg2_i_mux[31])) && (result_sum[31])) ||
                (((reg1_i[31]) && (reg2_i_mux[31])) && (!result_sum[31]));

//num compare(2 conditions, signed compare 3 conditions)
// - +
// + + res(-)
// - - res(-)
assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP))?
                    (((reg1_i[31]) && (!reg2_i[31])) ||
                    ((!reg1_i[31]) && (!reg2_i[31]) && (result_sum[31])) ||
                    ((reg1_i[31]) && (reg2_i[31]) && (result_sum[31]))):
                    (reg1_i < reg2_i);
//reverse
assign reg1_i_not = ~reg1_i;

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
        end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP))begin  //write into hilo reg
            whilo_o = `Write_Enable;
            hi_o = mul_out[63:32];
            lo_o = mul_out[31:0];
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
        if(rst == `Rst_Enable)begin
            arithmetic_out = `Zero_Word;
        end else begin
            case(aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP:begin
                    arithmetic_out = reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:begin
                    arithmetic_out = result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP:begin
                    arithmetic_out = result_sum;
                end
                `EXE_CLZ_OP:begin
                    arithmetic_out = reg1_i[31] ? 0 : reg1_i[30]?1 :reg1_i[29]?2 :reg1_i[28]?3 :reg1_i[27]?4 :reg1_i[26]?5 :
                    reg1_i[25] ? 6 : reg1_i[24]?7 :reg1_i[23]?8 :reg1_i[22]?9 :reg1_i[21]?10:reg1_i[20]?11:
                    reg1_i[19] ? 12: reg1_i[18]?13:reg1_i[17]?14:reg1_i[16]?15:reg1_i[15]?16:reg1_i[14]?17:
                    reg1_i[13] ? 18: reg1_i[12]?19:reg1_i[11]?20:reg1_i[10]?21:reg1_i[9] ?22:reg1_i[8] ?23:
                    reg1_i[7]  ? 24: reg1_i[6] ?25:reg1_i[5] ?26:reg1_i[4] ?27:reg1_i[3] ?28:reg1_i[2] ?29:
                    reg1_i[1]  ? 30: reg1_i[0] ?31:32;
                end
                `EXE_CLO_OP:begin
                    arithmetic_out = reg1_i_not[31] ? 0 : reg1_i_not[30]?1 :reg1_i_not[29]?2 :reg1_i_not[28]?3 :reg1_i_not[27]?4 :reg1_i_not[26]?5 :
                    reg1_i_not[25] ? 6 : reg1_i_not[24]?7 :reg1_i_not[23]?8 :reg1_i_not[22]?9 :reg1_i_not[21]?10:reg1_i_not[20]?11:
                    reg1_i_not[19] ? 12: reg1_i_not[18]?13:reg1_i_not[17]?14:reg1_i_not[16]?15:reg1_i_not[15]?16:reg1_i_not[14]?17:
                    reg1_i_not[13] ? 18: reg1_i_not[12]?19:reg1_i_not[11]?20:reg1_i_not[10]?21:reg1_i_not[9] ?22:reg1_i_not[8] ?23:
                    reg1_i_not[7]  ? 24: reg1_i_not[6] ?25:reg1_i_not[5] ?26:reg1_i_not[4] ?27:reg1_i_not[3] ?28:reg1_i_not[2] ?29:
                    reg1_i_not[1]  ? 30: reg1_i_not[0] ?31:32;
                end
                default :begin
                    arithmetic_out = `Zero_Word;  
                end
            endcase
        end
    end
    
//multiply operation
assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) 
                        && (reg1_i[31]))? (~reg1_i+1):reg1_i;

assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)) 
                        && (reg2_i[31]))? (~reg2_i+1):reg2_i;

assign hilo_temp = opdata1_mult * opdata2_mult;

always@(*)begin
    if(rst == `Rst_Enable)begin
        mul_out = {`Zero_Word,`Zero_Word};
    end else if((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))begin    //signed multiply
        if(reg1_i^reg2_i)begin
            mul_out = ~hilo_temp+1;
        end else begin
            mul_out = hilo_temp;
        end
    end else begin
        mul_out = hilo_temp;                                                   //unsigned mult
    end
end


    always@(*)begin
        wd_o = wd_i;
        if((((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP)) ||
        (aluop_i == `EXE_SUB_OP)) && (ov_sum))begin
            wreg_o = `Write_Disable;
        end else begin
            wreg_o = wreg_i;
        end
        case(alusel_i)
            `EXE_RES_LOGIC:  begin
                wdata_o = logic_out;
            end
            `EXE_RES_SHIFT:  begin
                wdata_o = shift_out;
            end
            `EXE_RES_ARITHMETIC: begin
                wdata_o = arithmetic_out;
            end
            `EXE_RES_MOVE: begin
                wdata_o = move_out;
            end
            `EXE_RES_MUL: begin
                wdata_o = mul_out[31:0];
            end
            default:  begin
                wdata_o = `Zero_Word;
            end
        endcase
    end

endmodule
