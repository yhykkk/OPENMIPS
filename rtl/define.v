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
`define Read_Disable  1'b0                                          //此处Disable有时也指从reg0读取

`define Alu_Op        8
`define Alu_Sel       3

`define Inst_Valid    1'b1
`define Inst_Invalid  1'b0

`define Zero_Word     32'b0

/***************** instruction defination ********************/

`define EXE_NOP_OP    8'b00000000
`define EXE_AND_OP    8'b00100100
`define EXE_OR_OP     8'b00100101
`define EXE_XOR_OP    8'b00100110
`define EXE_NOR_OP    8'b00100111
`define EXE_ANDI_OP   8'b00001100
`define EXE_ORI_OP    8'b00001101
`define EXE_XORI_OP   8'b00001110
`define EXE_LUI_OP    8'b00001111

`define EXE_SLL_OP    8'b01000000
`define EXE_SLLV_OP   8'b00000100
`define EXE_SRL_OP    8'b01000010
`define EXE_SRLV_OP   8'b00000110
`define EXE_SRA_OP    8'b00000011
`define EXE_SRAV_OP   8'b00000111

`define EXE_SYNC_OP   8'b01001111
`define EXE_PREF_OP   8'b00110011

`define EXE_MOVZ_OP   8'b01001010           
`define EXE_MOVN_OP   8'b01001011           
`define EXE_MFHI_OP   8'b00010000           
`define EXE_MTHI_OP   8'b00010001           
`define EXE_MFLO_OP   8'b00010010           
`define EXE_MTLO_OP   8'b00010011           

`define EXE_RES_NOP             3'b000
`define EXE_RES_LOGIC           3'b001
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MOVE            3'b011
`define EXE_RES_ARITHMETIC      3'b100
`define EXE_RES_MUL             3'b101
`define EXE_RES_LOAD_STORE      3'b110
`define EXE_RES_JUMP_BRANCH     3'b111

`define EXE_ORI       6'b001101
`define EXE_AND       6'b100100
`define EXE_OR        6'b100101
`define EXE_XOR       6'b100110
`define EXE_NOR       6'b100111
`define EXE_ANDI      6'b001100
`define EXE_ORI       6'b001101
`define EXE_XORI      6'b001110
`define EXE_LUI       6'b001111

`define EXE_SLL       6'b000000
`define EXE_SLLV      6'b000100
`define EXE_SRL       6'b000010
`define EXE_SRLV      6'b000110
`define EXE_SRA       6'b000011
`define EXE_SRAV      6'b000111

`define EXE_SYNC      6'b001111
`define EXE_PREF      6'b110011
`define EXE_SPECIAL_INST      6'b000000

`define EXE_MOVZ       6'b001010
`define EXE_MOVN       6'b001011
`define EXE_MFHI       6'b010000
`define EXE_MTHI       6'b010001
`define EXE_MFLO       6'b010010
`define EXE_MTLO       6'b010011



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