/**************************************
@ filename    : rom.v
@ author      : yhykkk
@ create time : 2025/01/22 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module rom(
    input                               ce                         ,
    input              [`Inst_Addr-1:0] addr                       ,
    output reg         [`Inst_Data-1:0] inst                        
    );
    
reg                    [`Inst_Data-1:0] inst_mem [`Num_Inst_Mem-1:0]                           ;
    
    initial begin 
    $readmemh ("inst_load1.dat",inst_mem);
    $display("Instruction memory initialized.");
    end

    always@(*)begin
        if(ce == `Chip_Disable)begin
            inst = `Zero_Word;
        end else begin
            inst = inst_mem[addr[`Inst_Addr_Use+1:2]];
        end
    end
endmodule
