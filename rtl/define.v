/**************************************
@ filename    : define.v
@ author      : yhykkk
@ create time : 2025/01/20
@ version     : v1.0.0
**************************************/

/***************** global defination ********************/
`define Rst_Enable    1'b0
`define Rst_Disable   1'b1

`define Chip_Enable   1'b1
`define Chip_Disable  1'b0

`define Write_Enable  1'b1
`define Write_Disable 1'b0

`define Read_Enable   1'b1
`define Read_Disable  1'b0

`define Alu_Op        8
`define Alu_Sel       3

`define Inst_Valid    1'b1
`define Inst_Invalid  1'b0

`define Zero_Word     32'b0

/***************** instruction defination ********************/

`define EXE_NOP_OP    8'b00000000
`define EXE_OR_OP     8'b00100101

`define EXE_RES_NOP   3'b000
`define EXE_RES_LOGIC 3'b001

`define EXE_ORI       6'b001101


/***************** instruction rom defination ********************/
`define Inst_Addr     32
`define Inst_Addr_Use 17                                            // instruct rom 's address width in use  [less than Inst_Addr]
`define Inst_Data     32
`define Reg_Addr      5                                             //bit width for the address
`define Reg           32
`define Reg_Num       32                                            //32 general register
`define Num_Inst_Mem  131072                                        //128kb
`define Reg_Zero      5'b00000                                      //register 0
`define No_Addr       32'b0
/***************** regfile defination ********************/