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
    .rom_ce_o                          (rom_ce                    ) 
    );
    
endmodule
