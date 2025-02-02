/**************************************
@ filename    : regfile.v
@ author      : yhykkk
@ create time : 2025/01/20 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module regfile(
    input                               rst                        ,
    input                               clk                        ,
    //write register
    input              [`Reg_Addr-1:0]  waddr                      ,//write register
    input              [`Reg-1:0]       wdata                      ,//write data
    input                               we                         ,//data_en
    //read register
    input              [`Reg_Addr-1:0]  raddr1                     ,//reading addr
    input                               re1                        ,
    input              [`Reg_Addr-1:0]  raddr2                     ,
    input                               re2                        ,
    //data output
    output reg         [`Reg-1:0]       rdata1                     ,
    output reg         [`Reg-1:0]       rdata2                      
    );
    
    //32 register
reg                    [`Reg-1:0] regs [`Reg_Num-1:0]                           ;
    //writing operation
    always@(posedge clk)
        begin
            if(rst == `Rst_Disable)begin
                if((we == `Write_Enable)&&(waddr != `Reg_Zero))begin
                    regs[waddr] <= wdata;                        
                end
            end    
        end
     //reading operation  
     always@(*)
        begin
            if(rst == `Rst_Enable)begin
                rdata1 = 32'b0;
            end else if(raddr1 == `Reg_Zero)begin
                rdata1 = 32'b0;
            end else if((we == `Write_Enable)&&(raddr1==waddr)&&(re1==`Read_Enable))begin     
                rdata1 = wdata;                                                                     //use the new written data（RAW conflict with write and read at the same time）
            end else if((re1==`Read_Enable))begin
                rdata1 = regs[raddr1];
            end else
                rdata1 = `Zero_Word;
        end 
           
           always@(*)
        begin
            if(rst == `Rst_Enable)begin
                rdata2 = 32'b0;
            end else if(raddr2 == `Reg_Zero)begin
                rdata2 = 32'b0;
            end else if((we == `Write_Enable)&&(raddr2==waddr)&&(re2==`Read_Enable))begin
                rdata2 = wdata;
            end else if((re2==`Read_Enable))begin
                rdata2 = regs[raddr2];
            end else
                rdata2 = `Zero_Word;
        end 
endmodule
