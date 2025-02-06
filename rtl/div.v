/**************************************
@ filename    : div.v
@ author      : yhykkk
@ create time : 2025/02/06 
@ version     : v1.0.0
**************************************/
`include "define.v"
`timescale 1ns / 1ps

module div(
    input                               clk                        ,
    input                               rst                        ,
    input                               signed_div_i               ,//whether signed op
    input              [`Reg-1:0]       opdata1_i                  ,
    input              [`Reg-1:0]       opdata2_i                  ,
    input                               start_i                    ,//signal to start div
    input                               annul_i                    ,//signal to cancel div
    output reg         [`Reg_Double-1:0]result_o                   ,
    output reg                          ready_o                     //wether finished
);

wire                   [`Reg:0]         div_temp                   ;
reg                    [   5:0]         cnt                        ;//rounds record
reg                    [`Reg_Double:0]  dividend                   ;
reg                    [   1:0]         state                      ;//state machine
reg                    [`Reg-1:0]       divisor                    ;
reg                    [`Reg-1:0]       temp_op1                   ;
reg                    [`Reg-1:0]       temp_op2                   ;

assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};          //minuend - n


always@(*)begin
    if(state == `DivFree && start_i == `DivStart && annul_i == 1'b0 && opdata2_i != `Zero_Word)begin
       if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1)begin //div second's coding
            temp_op1 = ~opdata1_i + 1;
        end else begin
            temp_op1 = opdata1_i;
        end

        if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1)begin //divider second's coding
            temp_op2 = ~opdata2_i + 1;
        end else begin
            temp_op2 = opdata2_i;
        end 
    end
end


always@(posedge clk)begin
    if(rst == `Rst_Enable)begin
        state <= `DivFree;
        ready_o <= `DivResultNotReady;
        result_o <= {2{`Zero_Word}};
    end else begin
        case(state)
            `DivFree: begin
                if(start_i == `DivStart && annul_i == 1'b0)begin
                    if(opdata2_i == `Zero_Word)begin
                        state <= `DivByZero;
                    end else begin
                        state <= `DivOn;
                        cnt <= 'b0;
                        dividend <= {2{`Zero_Word}};
                        dividend [32:1] <= temp_op1;                           //dividened store the op1
                        divisor <= temp_op2; 
                    end
                end else begin
                    ready_o <= `DivResultNotReady;                             //donot start
                    result_o <= {2{`Zero_Word}};
                end
            end
            `DivByZero: begin
                dividend <= {2{`Zero_Word}};
                state <= `DivEnd;
            end
            `DivOn: begin
                if(annul_i == 1'b0)begin
                    if(cnt != 6'd32)begin                                       //div process not finished
                        if(div_temp[32] == 1'b1)begin
                            dividend <= {dividend[63:0] , 1'b0};
                        end else begin
                            dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                        end
                        cnt <= cnt + 1'b1;
                    end else begin
                        if((signed_div_i == 1'b1) &&                             //商
                        ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1))begin
                            dividend[31:0] <= ~dividend[31:0] + 1'b1;
                        end
                        if((signed_div_i == 1'b1) &&                             //余数
                        ((opdata1_i[31] ^ dividend[64]) == 1'b1))begin
                            dividend[64:33] <= ~dividend[64:33] + 1'b1;
                        end
                        state <= `DivEnd;
                        cnt <= 6'b0;
                    end
                end else begin
                    state <= `DivFree;
                end
            end
            `DivEnd:begin
                result_o <= {dividend[64:33] ,dividend[31:0]};
                ready_o <= `DivResultReady;
                if (start_i == `DivStop)begin
                    state <= `DivFree;
                    ready_o <= `DivResultNotReady;
                    result_o <= {2{`Zero_Word}};
                end
            end
        endcase
    end
end
endmodule