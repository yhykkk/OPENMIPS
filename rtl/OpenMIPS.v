/**************************************
@ filename    : OpenMIPS.v
@ author      : yhykkk
@ create time : 2025/01/21 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps


module OpenMIPS(
    input                               rst                        ,
    input                               clk                        ,
    input              [`Reg-1:0]       rom_data_i                 ,//instruction input
    input              [`Reg-1:0]       ram_data_i                 ,
    output             [`Reg-1:0]       rom_addr_o                 ,//aimed instruction reg        
    output                              rom_ce_o                   ,
    output             [`Reg-1:0]       ram_addr_o                 ,
    output             [`Reg-1:0]       ram_data_o                 ,
    output                              ram_we_o                   ,
    output             [   3:0]         ram_sel_o                  ,
    output                              ram_ce_o                    
    );

//write data pushing ahead
wire                   [`Reg-1:0]       id_reg1_data               ;
wire                   [`Reg-1:0]       id_reg2_data               ;
wire                                    id_re1                     ;
wire                                    id_re2                     ;
wire                   [`Reg_Addr-1:0]  id_reg1_addr               ;
wire                   [`Reg_Addr-1:0]  id_reg2_addr               ;
wire                   [`Alu_Op-1:0]    id_aluop                   ;
wire                   [`Alu_Sel-1:0]   id_alusel                  ;
wire                   [`Reg-1:0]       id_reg1_o                  ;
wire                   [`Reg-1:0]       id_reg2_o                  ;
wire                   [`Reg_Addr-1:0]  id_wd_o                    ;
wire                                    id_wreg_o                  ;
wire                   [`Reg_Addr-1:0]  ex_wd_o                    ;
wire                                    ex_wreg_o                  ;
wire                   [`Reg-1:0]       ex_wdata_o                 ;
wire                   [`Reg_Addr-1:0]  mem_wd_o                   ;
wire                                    mem_wreg_o                 ;
wire                   [`Reg-1:0]       mem_wdata_o                ;
// hilo data pushing ahead
wire                   [`Reg-1:0]       hi_o                       ;
wire                   [`Reg-1:0]       lo_o                       ;
wire                                    mem_whilo                  ;
wire                   [`Reg-1:0]       mem_hi                     ;
wire                   [`Reg-1:0]       mem_lo                     ;
wire                                    wb_whilo                   ;
wire                   [`Reg-1:0]       wb_hi                      ;
wire                   [`Reg-1:0]       wb_lo                      ;
wire                                    ex_whilo                   ;
wire                   [`Reg-1:0]       ex_hi                      ;
wire                   [`Reg-1:0]       ex_lo                      ;
wire                                    mem_whilo_i                ;
wire                   [`Reg-1:0]       mem_hi_i                   ;
wire                   [`Reg-1:0]       mem_lo_i                   ;
//stall signal
wire                                    stallreq_from_id           ;
wire                                    stallreq_from_ex           ;
wire                   [   5:0]         stall                      ;
wire                   [`Reg_Double-1:0]hilo_ex                    ;
wire                   [   1:0]         cnt_ex                     ;
wire                   [`Reg_Double-1:0]hilo_mem                   ;
wire                   [   1:0]         cnt_mem                    ;
//div signal
wire                   [`Reg_Double-1:0]div_result                 ;
wire                                    div_ready                  ;
wire                   [   1:0]         cnt                        ;
wire                   [`Reg-1:0]       div_opdata1                ;
wire                   [`Reg-1:0]       div_opdata2                ;
wire                                    div_start                  ;
wire                                    signed_div                 ;
wire                                    is_in_delayslot            ;
wire                                    branch_flag                ;
wire                                    id_is_in_delayslot         ;
wire                                    next_inst_in_delayslot     ;
wire                   [`Inst_Addr-1:0] branch_target_addr         ;
wire                   [`Inst_Addr-1:0] id_link_addr               ;
wire                   [`Inst_Addr-1:0] ex_link_addr               ;
wire                                    ex_is_in_delayslot         ;

wire                   [`Inst_Data-1:0] inst_id                    ;
wire                   [`Inst_Addr-1:0] inst_ex                    ;
wire                   [`Alu_Op-1:0]    aluop_ex                   ;
wire                   [`Reg-1:0]       mem_addr                   ;
wire                   [`Reg-1:0]       ex_reg2_o                  ;
wire                   [`Alu_Op-1:0]    mem_aluop                  ;
wire                   [`Reg-1:0]       mem_mem_addr               ;
wire                   [`Reg-1:0]       mem_reg2                   ;
//ll sc
wire                                    wb_llbit_value             ;
wire                                    wb_llbit_we                ;
wire                                    llbit_o                    ;
wire                                    mem_llbit_we               ;
wire                                    mem_llbit_value            ;

    
    //pc
wire                   [`Inst_Addr-1:0] pc                         ;
    pc_reg pc_reg_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .pc                                (pc                        ),//address for reading
    .ce                                (rom_ce_o                  ),//order register enable
    .stall                             (stall                     ),
    .branch_flag_i                     (branch_flag               ),
    .branch_target_addr_i              (branch_target_addr        ) 
    );

    assign rom_addr_o = pc;
    
    //if_id
wire                   [`Inst_Addr-1:0] id_pc                      ;
wire                   [`Inst_Data-1:0] id_inst                    ;
    if_id if_id_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .if_pc                             (pc                        ),//address for instr
    .if_inst                           (rom_data_i                ),//instr
    .id_pc                             (id_pc                     ),//output address for instr
    .id_inst                           (id_inst                   ),//output instr
    .stall                             (stall                     ) 
    );
    
    //id
    ID ID_inst0(
    .rst                               (rst                       ),
    .pc_i                              (id_pc                     ),//address for decoder
    .inst_i                            (id_inst                   ),//instruction for decoder
    .reg1_data_i                       (id_reg1_data              ),//data read in regfile
    .reg2_data_i                       (id_reg2_data              ),
    .ex_wreg_i                         (ex_wreg_o                 ),
    .ex_wd_i                           (ex_wd_o                   ),
    .ex_wdata_i                        (ex_wdata_o                ),
    .mem_wreg_i                        (mem_wreg_o                ),
    .mem_wd_i                          (mem_wd_o                  ),
    .mem_wdata_i                       (mem_wdata_o               ),
    .reg1_read_o                       (id_re1                    ),//read enable for regfile
    .reg2_read_o                       (id_re2                    ),
    .reg1_addr_o                       (id_reg1_addr              ),//read address for regfile
    .reg2_addr_o                       (id_reg2_addr              ),
    .aluop_o                           (id_aluop                  ),//operational subclass
    .alusel_o                          (id_alusel                 ),//operational class
    .reg1_o                            (id_reg1_o                 ),//Դ������
    .reg2_o                            (id_reg2_o                 ),
    .wd_o                              (id_wd_o                   ),//address for aimed register
    .wreg_o                            (id_wreg_o                 ),//write enable for aimed register
    .stallreq                          (stallreq_from_id          ),
    .is_in_delayslot_i                 (is_in_delayslot           ),
    .branch_flag_o                     (branch_flag               ),
    .is_in_delayslot_o                 (id_is_in_delayslot        ),
    .next_inst_in_delayslot_o          (next_inst_in_delayslot    ),
    .branch_target_addr_o              (branch_target_addr        ),
    .link_addr_o                       (id_link_addr              ),
    .inst_o                            (inst_id                   ) 
    );
    
    //regfile
wire                   [`Reg_Addr-1:0]  wb_wd                      ;
wire                                    wb_wreg                    ;
wire                   [`Reg-1:0]       wb_wdata                   ;
    regfile regfile_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    //write register
    .waddr                             (wb_wd                     ),//write register
    .wdata                             (wb_wdata                  ),//write data
    .we                                (wb_wreg                   ),//data_en
    //read register
    .raddr1                            (id_reg1_addr              ),//reading addr
    .re1                               (id_re1                    ),
    .raddr2                            (id_reg2_addr              ),
    .re2                               (id_re2                    ),
    //data output
    .rdata1                            (id_reg1_data              ),
    .rdata2                            (id_reg2_data              ) 
    );
    
    //id_ex
wire                   [`Alu_Sel-1:0]   ex_alusel                  ;
wire                   [`Alu_Op-1:0]    ex_aluop                   ;
wire                   [`Reg-1:0]       ex_reg1_i                  ;
wire                   [`Reg-1:0]       ex_reg2_i                  ;
wire                   [`Reg_Addr-1:0]  ex_wd_i                    ;
wire                                    ex_wreg_i                  ;
    id_ex id_ex_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .id_alusel                         (id_alusel                 ),
    .id_aluop                          (id_aluop                  ),
    .id_reg1                           (id_reg1_o                 ),
    .id_reg2                           (id_reg2_o                 ),
    .id_wd                             (id_wd_o                   ),
    .id_wreg                           (id_wreg_o                 ),
    .ex_alusel                         (ex_alusel                 ),
    .ex_aluop                          (ex_aluop                  ),
    .ex_reg1                           (ex_reg1_i                 ),
    .ex_reg2                           (ex_reg2_i                 ),
    .ex_wd                             (ex_wd_i                   ),
    .ex_wreg                           (ex_wreg_i                 ),
    .stall                             (stall                     ),
    .id_link_addr                      (id_link_addr              ),
    .id_is_in_delayslot                (id_is_in_delayslot        ),
    .next_inst_in_delayslot_i          (next_inst_in_delayslot    ),
    .is_in_delayslot_o                 (is_in_delayslot           ),
    .ex_link_addr                      (ex_link_addr              ),
    .ex_is_in_delayslot                (ex_is_in_delayslot        ),
    .id_inst                           (inst_id                   ),
    .ex_inst                           (inst_ex                   ) 
    );
    
    //ex
    ex ex_inst0(
    .rst                               (rst                       ),
    .alusel_i                          (ex_alusel                 ),
    .aluop_i                           (ex_aluop                  ),
    .reg1_i                            (ex_reg1_i                 ),
    .reg2_i                            (ex_reg2_i                 ),
    .wd_i                              (ex_wd_i                   ),
    .wreg_i                            (ex_wreg_i                 ),
    .wd_o                              (ex_wd_o                   ),
    .wreg_o                            (ex_wreg_o                 ),
    .wdata_o                           (ex_wdata_o                ),
    .hi_i                              (hi_o                      ),
    .lo_i                              (lo_o                      ),
    .mem_whilo_i                       (mem_whilo                 ),
    .mem_hi_i                          (mem_hi                    ),
    .mem_lo_i                          (mem_lo                    ),
    .wb_whilo_i                        (wb_whilo                  ),
    .wb_hi_i                           (wb_hi                     ),
    .wb_lo_i                           (wb_lo                     ),
    .whilo_o                           (ex_whilo                  ),
    .hi_o                              (ex_hi                     ),
    .lo_o                              (ex_lo                     ),
    .stallreq                          (stallreq_from_ex          ),
    .cnt_i                             (cnt_mem                   ),
    .hilo_temp_i                       (hilo_mem                  ),
    .cnt_o                             (cnt_ex                    ),
    .hilo_temp_o                       (hilo_ex                   ),
    .div_result_i                      (div_result                ),
    .div_ready_i                       (div_ready                 ),
    .div_opdata1_o                     (div_opdata1               ),
    .div_opdata2_o                     (div_opdata2               ),
    .div_start_o                       (div_start                 ),
    .signed_div_o                      (signed_div                ),
    .link_addr_i                       (ex_link_addr              ),
    .is_in_delayslot_i                 (ex_is_in_delayslot        ),
    .inst_i                            (inst_ex                   ),
    .aluop_o                           (aluop_ex                  ),
    .mem_addr_o                        (mem_addr                  ),
    .reg2_o                            (ex_reg2_o                 ) 
    );
    
    //ex_mem
wire                   [`Reg_Addr-1:0]  mem_wd_i                   ;
wire                                    mem_wreg_i                 ;
wire                   [`Reg-1:0]       mem_wdata_i                ;
    ex_mem ex_mem_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .ex_wd                             (ex_wd_o                   ),
    .ex_wreg                           (ex_wreg_o                 ),
    .ex_wdata                          (ex_wdata_o                ),
    .mem_wd                            (mem_wd_i                  ),
    .mem_wreg                          (mem_wreg_i                ),
    .mem_wdata                         (mem_wdata_i               ),
    .ex_hi                             (ex_hi                     ),
    .ex_lo                             (ex_lo                     ),
    .ex_whilo                          (ex_whilo                  ),
    .mem_hi                            (mem_hi_i                  ),
    .mem_lo                            (mem_lo_i                  ),
    .mem_whilo                         (mem_whilo_i               ),
    .stall                             (stall                     ),
    .cnt_i                             (cnt_ex                    ),
    .hilo_i                            (hilo_ex                   ),
    .cnt_o                             (cnt_mem                   ),
    .hilo_o                            (hilo_mem                  ),
    .ex_aluop                          (aluop_ex                  ),
    .ex_mem_addr                       (mem_addr                  ),
    .ex_reg2                           (ex_reg2_o                 ),
    .mem_aluop                         (mem_aluop                 ),
    .mem_mem_addr                      (mem_mem_addr              ),
    .mem_reg2                          (mem_reg2                  ) 
    );
    
    //mem
    mem mem_inst0(
    .rst                               (rst                       ),
    .wd_i                              (mem_wd_i                  ),
    .wreg_i                            (mem_wreg_i                ),
    .wdata_i                           (mem_wdata_i               ),
    .wd_o                              (mem_wd_o                  ),
    .wreg_o                            (mem_wreg_o                ),
    .wdata_o                           (mem_wdata_o               ),
    .hi_i                              (mem_hi_i                  ),
    .lo_i                              (mem_lo_i                  ),
    .whilo_i                           (mem_whilo_i               ),
    .hi_o                              (mem_hi                    ),
    .lo_o                              (mem_lo                    ),
    .whilo_o                           (mem_whilo                 ),
    .mem_data_i                        (ram_data_i                ),
    .mem_addr_o                        (ram_addr_o                ),
    .mem_we_o                          (ram_we_o                  ),
    .mem_sel_o                         (ram_sel_o                 ),
    .mem_data_o                        (ram_data_o                ),
    .mem_ce_o                          (ram_ce_o                  ),
    .aluop_i                           (mem_aluop                 ),
    .reg2_i                            (mem_reg2                  ),
    .mem_addr_i                        (mem_mem_addr              ),
    .llbit_i                           (llbit_o                   ),
    .wb_llbit_we_i                     (wb_llbit_we               ),
    .wb_llbit_value_i                  (wb_llbit_value            ),
    .llbit_we_o                        (mem_llbit_we              ),
    .llbit_value_o                     (mem_llbit_value           ) 
    );
    
    //mem_wb
    mem_wb mem_wb_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .mem_wd                            (mem_wd_o                  ),
    .mem_wreg                          (mem_wreg_o                ),
    .mem_wdata                         (mem_wdata_o               ),
    .wb_wd                             (wb_wd                     ),
    .wb_wreg                           (wb_wreg                   ),
    .wb_wdata                          (wb_wdata                  ),
    .mem_hi                            (mem_hi                    ),
    .mem_lo                            (mem_lo                    ),
    .mem_whilo                         (mem_whilo                 ),
    .wb_hi                             (wb_hi                     ),
    .wb_lo                             (wb_lo                     ),
    .wb_whilo                          (wb_whilo                  ),
    .stall                             (stall                     ),
    .mem_llbit_we                      (mem_llbit_we              ),
    .mem_llbit_value                   (mem_llbit_value           ),
    .wb_llbit_we                       (wb_llbit_we               ),
    .wb_llbit_value                    (wb_llbit_value            ) 
    );

    hilo_reg hilo_reg_inst0(
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .we                                (wb_whilo                  ),
    .hi_i                              (wb_hi                     ),
    .lo_i                              (wb_lo                     ),
    .hi_o                              (hi_o                      ),
    .lo_o                              (lo_o                      ) 
    );

    ctrl ctrl_inst0(
    .rst                               (rst                       ),
    .stallreq_from_id                  (stallreq_from_id          ),
    .stallreq_from_ex                  (stallreq_from_ex          ),
    .stall                             (stall                     ) 
    );

    div div_inst0(
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .signed_div_i                      (signed_div                ),
    .opdata1_i                         (div_opdata1               ),
    .opdata2_i                         (div_opdata2               ),
    .start_i                           (div_start                 ),
    .annul_i                           (1'b0                      ),
    .result_o                          (div_result                ),
    .ready_o                           (div_ready                 ) 
    );
    
    llbit llbit_inst0(
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .llbit_i                           (wb_llbit_value            ),
    .we                                (wb_llbit_we               ),
    .llbit_o                           (llbit_o                   ) 
    );
    
    
    
endmodule
