// ----  Probes  ----
`define PROBE_F_PC      FETCH_PC_O
`define PROBE_F_INSN    FETCH_INSN_O

`define PROBE_D_PC      DECODE_PC_I
`define PROBE_D_OPCODE  DECODE_OPCODE_O
`define PROBE_D_RD      DECODE_RD_O
`define PROBE_D_FUNCT3  DECODE_FUNCT3_O
`define PROBE_D_RS1     DECODE_RS1_O
`define PROBE_D_RS2     DECODE_RS2_O
`define PROBE_D_FUNCT7  DECODE_FUNCT7_O
`define PROBE_D_IMM     DECODE_IMM_O
`define PROBE_D_SHAMT   DECODE_SHAMT_O

`define PROBE_R_WRITE_ENABLE      RF_REGWREN_I
`define PROBE_R_WRITE_DESTINATION RF_RD_I
`define PROBE_R_WRITE_DATA        RF_DATAWB_I
`define PROBE_R_READ_RS1          RF_RS1_I
`define PROBE_R_READ_RS2          RF_RS2_I
`define PROBE_R_READ_RS1_DATA     RF_RS1DATA_O
`define PROBE_R_READ_RS2_DATA     RF_RS2DATA_O

`define PROBE_E_PC                ALU_PC_I
`define PROBE_E_ALU_RES           ALU_RES_O
`define PROBE_E_BR_TAKEN          ALU_BRTAKEN_O

`define PROBE_M_PC                MEM_INSN_ADDR_I
`define PROBE_M_ADDRESS           MEM_ADDR_I
`define PROBE_M_SIZE_ENCODED      MEM_FUNCT3_I
`define PROBE_M_DATA              MEM_DATA_O

`define PROBE_W_PC                WB_PC_I
`define PROBE_W_ENABLE            // ??
`define PROBE_W_DESTINATION       // ??
`define PROBE_W_DATA              // ??

// ----  Probes  ----

// ----  Top module  ----
`define TOP_MODULE  pd4
// ----  Top module  ----
