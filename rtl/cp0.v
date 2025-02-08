/**************************************
@ filename    : cp0.v
@ author      : yhykkk
@ create time : 2025/02/08 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module cp0(
    input                               rst                        ,
    input                               clk                        ,
    input                               we_i                       ,//wether modify cp0
    input              [   4:0]         w_addr_i                   ,
    input              [   4:0]         r_addr_i                   ,
    input              [`Reg-1:0]       data_i                     ,
    input              [   5:0]         int_i                     ,//6 interupt inst
    output reg         [`Reg-1:0]       data_o                     ,
    output reg         [`Reg-1:0]       count_o                    ,//value for count reg
    output reg         [`Reg-1:0]       compare_o                  ,//value for compare reg
    output reg         [`Reg-1:0]       status_o                   ,//value for status reg
    output reg         [`Reg-1:0]       cause_o                    ,//value for cause reg
    output reg         [`Reg-1:0]       epc_o                      ,//value for epc reg
    output reg         [`Reg-1:0]       config_o                   ,//value for config reg
    output reg         [`Reg-1:0]       prid_o                     ,//value for prid reg
    output reg                          timer_int_o                 //timer interrupt
);

    always@(posedge clk)begin
        if(rst == `Rst_Enable)begin
            count_o <= `Zero_Word;
            compare_o <= `Zero_Word;
            status_o <= {4'b0001,28'b0}; //cu 4'b0001 cp0 exists
            cause_o <= `Zero_Word;
            epc_o <= `Zero_Word;
            config_o <= {16'b0,1'b1,15'b0};
            prid_o <= 32'b00000000010011000000000100000010;
            timer_int_o <= `InterruptNotAssert;
        end else begin
            count_o <= count_o + 1;
            cause_o[15:10] <= int_i; //save interrupt status

            if(compare_o != `Zero_Word && count_o == compare_o)begin
                timer_int_o <= `InterruptAssert;
            end

            if(we_i == `Write_Enable)begin
                case(w_addr_i)
                    `CP0_REG_COUNT: begin
                        count_o <= data_i;
                    end
                    `CP0_REG_COMPARE: begin
                        compare_o <= data_i;
                    end
                    `CP0_REG_STATUS: begin
                        status_o <= data_i;
                    end
                    `CP0_REG_EPC: begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE: begin          //IP[1:0],IV,WP write only
                        cause_o[9:8] <= data_i[9:8];
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end
                endcase
            end
        end    
    end

    always@(*) begin
        if(rst == `Rst_Enable)begin
            data_o <= `Zero_Word;
        end else begin
            case(r_addr_i)
                `CP0_REG_COUNT: begin
                    data_o <= count_o;
                end
                `CP0_REG_COMPARE: begin
                    data_o <= compare_o;
                end
                `CP0_REG_STATUS: begin
                    data_o <= status_o;
                end
               `CP0_REG_EPC: begin
                    data_o <= epc_o;
               end
                `CP0_REG_CAUSE: begin
                    data_o <= cause_o;
                end
                `CP0_REG_CONFIG: begin
                    data_o <= config_o;
                end
                `CP0_REG_PRID: begin
                    data_o <= prid_o;
                end
                default: begin
                data_o <= `Zero_Word;
                end
            endcase
        end
    end

endmodule