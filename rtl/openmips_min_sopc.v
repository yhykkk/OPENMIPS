/**************************************
 @ filename    : openmips_min_sopc.v
 @ author      : yhykkk
 @ create time : 2025/01/22
 @ version     : v1.0.0
 **************************************/
`include "define.v"
`timescale 1ns / 1ps

module openmips_min_sopc(
    input                               clk                        ,
    input                               rst                         
);
    
wire                   [`Inst_Addr-1:0] rom_addr                   ;
wire                                    rom_ce                     ;
wire                   [`Inst_Data-1:0] inst                       ;
wire                   [`Reg-1:0]       ram_addr                   ;
wire                   [`Reg-1:0]       ram_data                   ;
wire                                    ram_we                     ;
wire                   [   3:0]         ram_sel                    ;
wire                                    ram_ce                     ;
wire                   [`Reg-1:0]       ram_data_o                 ;

    
    //rom
    rom rom_inst0(
    .ce                                (rom_ce                    ),
    .addr                              (rom_addr                  ),
    .inst                              (inst                      ) 
    );
    //openmips
    OpenMIPS OpenMIPS_inst0(
    .rst                               (rst                       ),
    .clk                               (clk                       ),
    .rom_data_i                        (inst                      ),//instruction input
    .rom_addr_o                        (rom_addr                  ),//aimed instruction reg
    .rom_ce_o                          (rom_ce                    ),
    .ram_addr_o                        (ram_addr                  ),
    .ram_data_o                        (ram_data                  ),
    .ram_we_o                          (ram_we                    ),
    .ram_sel_o                         (ram_sel                   ),
    .ram_ce_o                          (ram_ce                    ),
    .ram_data_i                        (ram_data_o                ) 
    );
    
    ram ram_inst0(
    .clk                               (clk                       ),
    .ce                                (ram_ce                    ),
    .we                                (ram_we                    ),
    .addr                              (ram_addr                  ),
    .sel                               (ram_sel                   ),
    .data_i                            (ram_data                  ),
    .data_o                            (ram_data_o                ) 
    );
    
    
endmodule
