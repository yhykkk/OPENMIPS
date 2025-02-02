`timescale 1ns / 1ps



module openmips_min_sop_tb();

reg                                     CLOCK_50                   ;
reg                                     rst                        ;
 
 initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end
    
 initial begin
    rst = 1'b0;
    #195 rst = ~rst;
    #1000;
    $stop;
 end
    
 openmips_min_sopc openmips_min_sopc_inst0(
    .clk(CLOCK_50),
    .rst(rst)
    );
endmodule
