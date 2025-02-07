/**************************************
@ filename    : define.v
@ author      : yhykkk
@ create time : 2025/01/20
@ version     : v1.0.0
**************************************/

/***************** global defination ********************/
`define Rst_Enable     1'b0
`define Rst_Disable    1'b1

`define Chip_Enable    1'b1
`define Chip_Disable   1'b0

`define Write_Enable   1'b1
`define Write_Disable 1'b0

`define Read_Enable   1'b1
`define Read_Disable   1'b0                                          //此处Disable有时也指从reg0读取

`define Alu_Op         8
`define Alu_Sel        3

`define Inst_Valid     1'b1
`define Inst_Invalid   1'b0

`define Zero_Word      32'b0

`define Stop           1'b1
`define NoStop         1'b0

`define Branch         1'b1
`define NotBranch      1'b0

`define InDelaySlot    1'b1
`define NotInDelaySlot 1'b0

//DIV
`define DivFree           2'b00
`define DivByZero         2'b01
`define DivOn             2'b10
`define DivEnd            2'b11
`define DivResultReady    1'b1
`define DivResultNotReady 1'b0
`define DivStart          1'b1
`define DivStop           1'b0
     
/***************** instruction defination ********************/
//BRANCH
`define EXE_J           6'b000010             
`define EXE_JAL         6'b000011             
`define EXE_JALR        6'b001001            
`define EXE_JR          6'b001000           
`define EXE_BEQ         6'b000100            
`define EXE_BGEZ        5'b00001              
`define EXE_BGEZAL      5'b10001             
`define EXE_BGTZ        6'b000111            
`define EXE_BLEZ        6'b000110             
`define EXE_BLTZ        5'b00000             
`define EXE_BLTZAL      5'b10000             
`define EXE_BNE         6'b000101     
// LOGIC
`define EXE_NOP_OP    8'b00000000
`define EXE_AND_OP    8'b00100100
`define EXE_OR_OP     8'b00100101
`define EXE_XOR_OP    8'b00100110
`define EXE_NOR_OP    8'b00100111
`define EXE_ANDI_OP   8'b00001100
`define EXE_ORI_OP    8'b00001101
`define EXE_XORI_OP   8'b00001110
`define EXE_LUI_OP    8'b00001111
// SHIFT
`define EXE_SLL_OP    8'b01000000
`define EXE_SLLV_OP   8'b00000100
`define EXE_SRL_OP    8'b01000010
`define EXE_SRLV_OP   8'b00000110
`define EXE_SRA_OP    8'b00000011
`define EXE_SRAV_OP   8'b00000111

`define EXE_SYNC_OP   8'b01001111
`define EXE_PREF_OP   8'b00110011
// MOVE
`define EXE_MOVZ_OP   8'b01001010           
`define EXE_MOVN_OP   8'b01001011           
`define EXE_MFHI_OP   8'b00010000           
`define EXE_MTHI_OP   8'b00010001           
`define EXE_MFLO_OP   8'b00010010           
`define EXE_MTLO_OP   8'b00010011
// ARITHMETIC
`define EXE_SLT_OP      8'b00101010           
`define EXE_SLTU_OP     8'b00101011           
`define EXE_SLTI_OP     8'b00001010           
`define EXE_SLTIU_OP    8'b00001011           
`define EXE_ADD_OP      8'b01100000          
`define EXE_ADDU_OP     8'b01100001         
`define EXE_SUB_OP      8'b00100010         
`define EXE_SUBU_OP     8'b00100011           
`define EXE_ADDI_OP     8'b00001000          
`define EXE_ADDIU_OP    8'b00001001          
`define EXE_CLZ_OP      8'b00100000             
`define EXE_CLO_OP      8'b00100001           
`define EXE_MULT_OP     8'b00011000           
`define EXE_MULTU_OP    8'b00011001           
`define EXE_MUL_OP      8'b00000010  
// MADD
`define EXE_MADD_OP     8'b10000000           
`define EXE_MADDU_OP    8'b01000001          
`define EXE_MSUB_OP     8'b01000100           
`define EXE_MSUBU_OP    8'b00000101 
//DIV
`define EXE_DIV_OP      8'b00011010         
`define EXE_DIVU_OP     8'b00011011  
//BRANCH
`define EXE_JR_OP       8'b01001000        
`define EXE_JALR_OP     8'b01001001          
`define EXE_J_OP        8'b10000010           
`define EXE_JAL_OP      8'b01000011         
`define EXE_BEQ_OP      8'b10000100         
`define EXE_BGTZ_OP     8'b01000111         
`define EXE_BLEZ_OP     8'b01000110         
`define EXE_BNE_OP      8'b01000101          
`define EXE_BGEZ_OP     8'b00000001          
`define EXE_BGEZAL_OP   8'b01010001          
`define EXE_BLTZ_OP     8'b11000000          
`define EXE_BLTZAL_OP   8'b01010000           

`define EXE_RES_NOP             3'b000
`define EXE_RES_LOGIC           3'b001
`define EXE_RES_SHIFT           3'b010
`define EXE_RES_MOVE            3'b011
`define EXE_RES_ARITHMETIC      3'b100
`define EXE_RES_MUL             3'b101
`define EXE_RES_LOAD_STORE      3'b110
`define EXE_RES_JUMP_BRANCH     3'b111
//logic
`define EXE_ORI       6'b001101
`define EXE_AND       6'b100100
`define EXE_OR        6'b100101
`define EXE_XOR       6'b100110
`define EXE_NOR       6'b100111
`define EXE_ANDI      6'b001100
`define EXE_ORI       6'b001101
`define EXE_XORI      6'b001110
`define EXE_LUI       6'b001111
//shift
`define EXE_SLL       6'b000000
`define EXE_SLLV      6'b000100
`define EXE_SRL       6'b000010
`define EXE_SRLV      6'b000110
`define EXE_SRA       6'b000011
`define EXE_SRAV      6'b000111

`define EXE_SYNC      6'b001111
`define EXE_PREF      6'b110011
`define EXE_SPECIAL_INST      6'b000000
`define EXE_REGIMM_INST       6'b000001
`define EXE_SPECIAL2_INST     6'b011100
//move
`define EXE_MOVZ       6'b001010
`define EXE_MOVN       6'b001011
`define EXE_MFHI       6'b010000
`define EXE_MTHI       6'b010001
`define EXE_MFLO       6'b010010
`define EXE_MTLO       6'b010011
//arithmatic
`define EXE_SLT         6'b101010             
`define EXE_SLTU        6'b101011             
`define EXE_SLTI        6'b001010            
`define EXE_SLTIU       6'b001011         
`define EXE_ADD         6'b100000             
`define EXE_ADDU        6'b100001          
`define EXE_SUB         6'b100010           
`define EXE_SUBU        6'b100011           
`define EXE_ADDI        6'b001000               
`define EXE_ADDIU       6'b001001           
`define EXE_CLZ         6'b100000             
`define EXE_CLO         6'b100001          
`define EXE_MULT        6'b011000             
`define EXE_MULTU       6'b011001            
`define EXE_MUL         6'b000010 
//madd
`define EXE_MADD        6'b000000             
`define EXE_MADDU       6'b000001            
`define EXE_MSUB        6'b000100             
`define EXE_MSUBU       6'b000101    
//div
`define EXE_DIV         6'b011010
`define EXE_DIVU        6'b011011        

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
`define Reg_Double    64
/***************** regfile defination ********************/