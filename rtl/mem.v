/**************************************
@ filename    : mem.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module mem(
    input                               rst                        ,
    input              [`Reg_Addr-1:0]  wd_i                       ,
    input                               wreg_i                     ,
    input              [`Reg-1:0]       wdata_i                    ,
    input              [`Reg-1:0]       hi_i                       ,
    input              [`Reg-1:0]       lo_i                       ,
    input                               whilo_i                    ,
    input              [`Alu_Op-1:0]    aluop_i                    ,
    input              [`Reg-1:0]       mem_addr_i                 ,
    input              [`Reg-1:0]       reg2_i                     ,
    input              [`Reg-1:0]       mem_data_i                 ,//data from ram
    input                               llbit_i                    ,
    input                               wb_llbit_we_i              ,
    input                               wb_llbit_value_i           ,
    input                               cp0_reg_we_i               ,
    input              [   4:0]         cp0_reg_write_addr_i       ,
    input              [`Reg-1:0]       cp0_reg_data_i             ,
    input              [  31:0]         excepttype_i               ,
    input              [`Reg-1:0]       current_inst_addr_i        ,
    input                               is_in_delayslot_i          ,
    input              [`Reg-1:0]       cp0_status_i               ,
    input              [`Reg-1:0]       cp0_cause_i                ,
    input              [`Reg-1:0]       cp0_epc_i                  ,
    input                               wb_cp0_reg_we              ,
    input              [   4:0]         wb_cp0_reg_write_addr      ,
    input              [`Reg-1:0]       wb_cp0_reg_write_data      ,
    output reg         [`Reg_Addr-1:0]  wd_o                       ,
    output reg                          wreg_o                     ,
    output reg         [`Reg-1:0]       wdata_o                    ,
    output reg         [`Reg-1:0]       hi_o                       ,
    output reg         [`Reg-1:0]       lo_o                       ,
    output reg                          whilo_o                    ,
    output reg         [`Reg-1:0]       mem_addr_o                 ,//data store addr
    output                              mem_we_o                   ,//read,write enable for ram
    output reg         [   3:0]         mem_sel_o                  ,//choose the valid dat
    output reg         [`Reg-1:0]       mem_data_o                 ,//data write
    output reg                          mem_ce_o                   ,
    output reg                          llbit_we_o                 ,
    output reg                          llbit_value_o              ,
    output reg                          cp0_reg_we_o               ,
    output reg         [   4:0]         cp0_reg_write_addr_o       ,
    output reg         [`Reg-1:0]       cp0_reg_data_o             ,
    output reg         [  31:0]         excepttype_o               ,
    output             [`Reg-1:0]       current_inst_addr_o        ,
    output                              is_in_delayslot_o          ,
    output             [`Reg-1:0]       cp0_epc_o                   
    );
    
wire                   [`Reg-1:0]       zero32                     ;
reg                                     llbit                      ;
reg                    [`Reg-1:0]       cp0_status                 ;
reg                    [`Reg-1:0]       cp0_cause                  ;
reg                    [`Reg-1:0]       cp0_epc                    ;
reg                                     mem_we                     ;

assign is_in_delayslot_o = is_in_delayslot_i;
assign current_inst_addr_o = current_inst_addr_i;
assign cp0_epc_o = cp0_epc;
assign zero32 = `Zero_Word;

    always@(*)begin
        if(rst==`Rst_Enable)begin
            llbit = 1'b0;
        end else if(wb_llbit_we_i==`Write_Enable)begin              //data forward in wb
            llbit = wb_llbit_value_i;
        end else begin
            llbit = llbit_i;
        end
    end

    always@(*)begin
        if(rst==`Rst_Enable)begin
            cp0_status = `Zero_Word;
        end else if((wb_cp0_reg_we == `Write_Enable)&&(wb_cp0_reg_write_addr == `CP0_REG_STATUS))begin
            cp0_status = wb_cp0_reg_write_data; 
        end else begin
            cp0_status = cp0_status_i;
        end
    end

    always@(*)begin
        if(rst==`Rst_Enable)begin
            cp0_epc = `Zero_Word;
        end else if((wb_cp0_reg_we == `Write_Enable)&&(wb_cp0_reg_write_addr == `CP0_REG_EPC))begin
            cp0_epc = wb_cp0_reg_write_data; 
        end else begin
            cp0_epc = cp0_epc_i;
        end
    end

    always@(*)begin
        if(rst==`Rst_Enable)begin
            cp0_cause = `Zero_Word;
        end else if((wb_cp0_reg_we == `Write_Enable)&&(wb_cp0_reg_write_addr == `CP0_REG_CAUSE))begin
            cp0_cause[9:8] = wb_cp0_reg_write_data[9:8];
            cp0_cause[22] = wb_cp0_reg_write_data[22];
            cp0_cause[23] = wb_cp0_reg_write_data[23];
        end else begin
            cp0_cause = cp0_cause_i;
        end
    end

    always@(*)begin
        if(rst==`Rst_Enable)begin
            excepttype_o = `Zero_Word;
        end else begin
            excepttype_o = `Zero_Word;
            if(current_inst_addr_i != `Zero_Word)begin
                if(((cp0_cause[15:8] & cp0_status[15:8])!=8'b0)&&(cp0_status[1]==1'b0)&&(cp0_status[0]==1'b1))begin
                    excepttype_o = 32'h00000001;   //interrupt
                end else if(excepttype_i[8] == 1'b1)begin
                    excepttype_o = 32'h00000008;   //syscall
                end else if(excepttype_i[9] == 1'b1)begin
                    excepttype_o = 32'h0000000a;   //inst_invalid
                end else if(excepttype_i[10] == 1'b1)begin
                    excepttype_o = 32'h0000000d;   //trap
                end else if(excepttype_i[11] == 1'b1)begin
                    excepttype_o = 32'h0000000c;   //ov
                end else if(excepttype_i[12] == 1'b1)begin
                    excepttype_o = 32'h0000000e;   //eret
                end 
            end
        end
    end

assign mem_we_o = mem_we & (~(|excepttype_o));

    always@(*)begin
        if(rst==`Rst_Enable)begin
            wd_o = `Reg_Zero;
            wreg_o = `Write_Disable;
            wdata_o = `Zero_Word;
            hi_o = `Zero_Word;
            lo_o = `Zero_Word;
            whilo_o = `Write_Disable;
            mem_addr_o = `Zero_Word;
            mem_we = `Write_Disable;
            mem_sel_o = 4'b0000;
            mem_data_o = `Zero_Word;
            mem_ce_o = `Chip_Disable;
            llbit_we_o = `Write_Disable;
            llbit_value_o = 1'b0;
            cp0_reg_data_o = `Zero_Word;
            cp0_reg_we_o = `Write_Disable;
            cp0_reg_write_addr_o = 5'b0;
        end else begin
            wd_o = wd_i;
            wreg_o = wreg_i;
            wdata_o = wdata_i;
            hi_o = hi_i;
            lo_o = lo_i;
            whilo_o = whilo_i;
            mem_addr_o = `Zero_Word;
            mem_we = `Write_Disable;
            mem_sel_o = 4'b0000;
            mem_data_o = `Zero_Word;
            mem_ce_o = `Chip_Disable;
            llbit_we_o = `Write_Disable;
            llbit_value_o = 1'b0;
            cp0_reg_data_o = cp0_reg_data_i;
            cp0_reg_we_o = cp0_reg_we_i;
            cp0_reg_write_addr_o = cp0_reg_write_addr_i;
            case(aluop_i)
                `EXE_LB_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            wdata_o = {{24{mem_data_i[31]}},mem_data_i[31:24]};
                            mem_sel_o = 4'b1000;
                        end
                        2'b01: begin
                            wdata_o = {{24{mem_data_i[23]}},mem_data_i[23:16]};
                            mem_sel_o = 4'b0100;
                        end
                        2'b10: begin
                            wdata_o = {{24{mem_data_i[15]}},mem_data_i[15:8]};
                            mem_sel_o = 4'b0010;
                        end
                        2'b11: begin
                            wdata_o = {{24{mem_data_i[7]}},mem_data_i[7:0]};
                            mem_sel_o = 4'b0001;
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LBU_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            wdata_o = {24'b0,mem_data_i[31:24]};
                            mem_sel_o = 4'b1000;
                        end
                        2'b01: begin
                            wdata_o = {24'b0,mem_data_i[23:16]};
                            mem_sel_o = 4'b0100;
                        end
                        2'b10: begin
                            wdata_o = {24'b0,mem_data_i[15:8]};
                            mem_sel_o = 4'b0010;
                        end
                        2'b11: begin
                            wdata_o = {24'b0,mem_data_i[7:0]};
                            mem_sel_o = 4'b0001;
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LH_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            wdata_o = {{16{mem_data_i[31]}},mem_data_i[31:16]};
                            mem_sel_o = 4'b1100;
                        end
                        2'b10: begin
                            wdata_o = {{16{mem_data_i[15]}},mem_data_i[15:0]};
                            mem_sel_o = 4'b0011;
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LHU_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            wdata_o = {16'b0,mem_data_i[31:16]};
                            mem_sel_o = 4'b1100;
                        end
                        2'b10: begin
                            wdata_o = {16'b0,mem_data_i[15:0]};
                            mem_sel_o = 4'b0011;
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LW_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    wdata_o = mem_data_i;
                    mem_sel_o = 4'b1111;
                end
                `EXE_LWL_OP: begin
                    mem_addr_o = {mem_addr_i[31:2], 2'b00};
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    mem_sel_o = 4'b1111;
                    case(mem_addr_i[1:0])                                //n 
                        2'b00: begin
                            wdata_o = mem_data_i[31:0];                  //4(byte)-n
                        end
                        2'b01: begin
                            wdata_o = {mem_data_i[23:0],reg2_i[7:0]};
                        end
                        2'b10: begin
                            wdata_o = {mem_data_i[15:0],reg2_i[15:0]};
                        end
                        2'b11: begin
                            wdata_o = {mem_data_i[7:0],reg2_i[23:0]};
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LWR_OP: begin
                    mem_addr_o = {mem_addr_i[31:2], 2'b00};
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    mem_sel_o = 4'b1111;
                    case(mem_addr_i[1:0])                                //n 
                        2'b00: begin
                            wdata_o = {reg2_i[31:8],mem_data_i[31:24]};                  //4(byte)-n
                        end
                        2'b01: begin
                            wdata_o = {reg2_i[31:16],mem_data_i[31:16]};
                        end
                        2'b10: begin
                            wdata_o = {reg2_i[31:24],mem_data_i[31:8]};
                        end
                        2'b11: begin
                            wdata_o = mem_data_i;
                        end
                        default: begin
                            wdata_o = `Zero_Word;
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_SB_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Enable;
                    mem_ce_o = `Chip_Enable;
                    mem_data_o = {4{reg2_i[7:0]}};
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            mem_sel_o = 4'b1000;
                        end
                        2'b01: begin
                            mem_sel_o = 4'b0100;
                        end
                        2'b10: begin
                            mem_sel_o = 4'b0010;
                        end
                        2'b11: begin
                            mem_sel_o = 4'b0001;
                        end
                        default: begin
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_SH_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Enable;
                    mem_ce_o = `Chip_Enable;
                    mem_data_o = {2{reg2_i[15:0]}};
                    case(mem_addr_i[1:0])                                //decide the sel
                        2'b00: begin
                            mem_sel_o = 4'b1100;
                        end
                        2'b10: begin
                            mem_sel_o = 4'b0011;
                        end
                        default: begin
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_SW_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Enable;
                    mem_ce_o = `Chip_Enable;
                    mem_data_o = reg2_i;
                    mem_sel_o = 4'b1111;
                end
                `EXE_SWL_OP: begin
                    mem_addr_o = {mem_addr_i[31:2], 2'b00};
                    mem_we = `Write_Enable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                
                        2'b00: begin
                            mem_sel_o = 4'b1111;
                            mem_data_o = reg2_i;                  
                        end
                        2'b01: begin
                            mem_sel_o = 4'b0111;
                            mem_data_o = {zero32[7:0],reg2_i[31:8]};
                        end
                        2'b10: begin
                            mem_sel_o = 4'b0011;
                            mem_data_o = {zero32[15:0],reg2_i[31:16]};
                        end
                        2'b11: begin
                            mem_sel_o = 4'b0001;
                            mem_data_o = {zero32[23:0],reg2_i[31:24]};
                        end
                        default: begin
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_SWR_OP: begin
                    mem_addr_o = {mem_addr_i[31:2], 2'b00};
                    mem_we = `Write_Enable;
                    mem_ce_o = `Chip_Enable;
                    case(mem_addr_i[1:0])                                
                        2'b00: begin
                            mem_sel_o = 4'b1000;
                            mem_data_o = {reg2_i[7:0],zero32[23:0]};                  
                        end
                        2'b01: begin
                            mem_sel_o = 4'b1100;
                            mem_data_o = {reg2_i[15:0],zero32[15:0]};
                        end
                        2'b10: begin
                            mem_sel_o = 4'b1110;
                            mem_data_o = {reg2_i[23:0],zero32[7:0]};
                        end
                        2'b11: begin
                            mem_sel_o = 4'b1111;
                            mem_data_o = reg2_i;
                        end
                        default: begin
                            mem_sel_o = 4'b0000;
                        end
                    endcase
                end
                `EXE_LL_OP: begin
                    mem_addr_o = mem_addr_i;
                    mem_we = `Write_Disable;
                    mem_ce_o = `Chip_Enable;
                    wdata_o = mem_data_i;
                    mem_sel_o = 4'b1111;
                    llbit_we_o = `Write_Enable;
                    llbit_value_o = 1'b1;
                end
                `EXE_SC_OP: begin
                    if(llbit_i == 1'b1)begin
                        mem_addr_o = mem_addr_i;
                        llbit_we_o = `Write_Enable;
                        llbit_value_o = 1'b0;
                        mem_we = `Write_Enable;
                        mem_ce_o = `Chip_Enable;
                        mem_sel_o = 4'b1111;
                        wdata_o = 32'b1;                            //set rt as 1
                        mem_data_o = reg2_i;
                    end else begin
                        wdata_o = 32'b0;
                    end
                end
                default :begin
                end
            endcase
        end
    end
endmodule
