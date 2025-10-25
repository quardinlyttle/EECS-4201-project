/*
 * Module: pd3
 *
 * Description: Top level module that will contain sub-module instantiations.
 *
 * Inputs:
 * 1) clk
 * 2) reset signal
 */

module pd3 #(
    parameter int AWIDTH = 32,
    parameter int DWIDTH = 32)(
    input logic clk,
    input logic reset
);

    // ======= CONTROL =======
    // Control Inputs
    logic [DWIDTH-1:0]  CTRL_INSN_I;
    logic [6:0]         CTRL_OPCODE_I;
    logic [6:0]         CTRL_FUNCT7_I;
    logic [2:0]         CTRL_FUNCT3_I;
    // Control Outputs
    logic               CTRL_PCSEL_O;
    logic               CTRL_IMMSEL_O;
    logic               CTRL_REGWREN_O;
    logic               CTRL_RS1SEL_O;
    logic               CTRL_RS2SEL_O;
    logic               CTRL_MEMREN_O;
    logic               CTRL_MEMWREN_O;
    logic [1:0]         CTRL_WBSEL_O;
    logic [3:0]         CTRL_ALUSEL_O;

    // ======= FETCH SIGNALS =======
    // Fetch Outputs
    logic [AWIDTH-1:0]  FETCH_PC_O;
    logic [DWIDTH-1:0]  FETCH_INSN_O;

    // ======= DECODE SIGNALS =======
    // Decode Inputs
    logic [DWIDTH-1:0]  DECODE_INSN_I;
    logic [AWIDTH-1:0]  DECODE_PC_I;
    // Decode Outputs
    logic [AWIDTH-1:0]  DECODE_PC_O;
    logic [DWIDTH-1:0]  DECODE_INSN_O;
    logic [6:0]         DECODE_OPCODE_O;
    logic [4:0]         DECODE_RD_O;
    logic [4:0]         DECODE_RS1_O;
    logic [4:0]         DECODE_RS2_O;
    logic [2:0]         DECODE_FUNCT3_O;
    logic [6:0]         DECODE_FUNCT7_O;
    logic [4:0]         DECODE_SHAMT_O;
    logic [DWIDTH-1:0]  DECODE_IMM_O;

    // ======= IGEN SIGNALS =======
    // Igen Inputs
    logic [6:0]         IGEN_OPCODE_I;
    logic [DWIDTH-1:0]  IGEN_INSN_I;
    // Igen Outputs
    logic [DWIDTH-1:0]  IGEN_IMM_O;

    // ======= MEMORY SIGNALS =======
    // Memory Inputs
    logic [AWIDTH-1:0]  MEM_ADDR_I;
    logic [DWIDTH-1:0]  MEM_DATA_I;
    logic               MEM_READ_EN_I;
    logic               MEM_WRITE_EN_I;
    // Memory Outputs
    logic [DWIDTH-1:0]  MEM_DATA_O;

    // ======= REGISTER FILE =======
    // RF Inputs
    logic [4:0]         RF_RS1_I;
    logic [4:0]         RF_RS2_I;
    logic [4:0]         RF_RD_I;
    logic [DWIDTH-1:0]  RF_DATAWB_I;
    logic               RF_REGWREN_I;
    // RF Outputs
    logic [DWIDTH-1:0]  RF_RS1DATA_O;
    logic [DWIDTH-1:0]  RF_RS2DATA_O;

    // ======= ALU =======
    // ALU Inputs
    logic [AWIDTH-1:0] ALU_PC_I;
    logic [DWIDTH-1:0] ALU_RS1_I;
    logic [DWIDTH-1:0] ALU_RS2_I;
    logic [3:0]        ALU_SEL_I;
    // ALU Outputs
    logic [DWIDTH-1:0] ALU_RES_O;
    logic              ALU_BRTAKEN_O;

    // ============================================
    // ============= RV32 MAIN BLOCKS =============
    // ============================================

    // =========== CONTROL ===========
    control #(
        .DWIDTH     (DWIDTH)
    ) ctrl_inst (
        .insn_i     (CTRL_INSN_I),
        .opcode_i   (CTRL_OPCODE_I),
        .funct7_i   (CTRL_FUNCT7_I),
        .funct3_i   (CTRL_FUNCT3_I),

        .pcsel_o    (CTRL_PCSEL_O),
        .immsel_o   (CTRL_IMMSEL_O),
        .regwren_o  (CTRL_REGWREN_O),
        .rs1sel_o   (CTRL_RS1SEL_O),
        .rs2sel_o   (CTRL_RS2SEL_O),
        .memren_o   (CTRL_MEMREN_O),
        .memwren_o  (CTRL_MEMWREN_O),
        .wbsel_o    (CTRL_WBSEL_O),
        .alusel_o   (CTRL_ALUSEL_O)
    );
    assign CTRL_INSN_I      = DECODE_INSN_O;
    assign CTRL_OPCODE_I    = DECODE_OPCODE_O;
    assign CTRL_FUNCT7_I    = DECODE_FUNCT7_O;
    assign CTRL_FUNCT3_I    = DECODE_FUNCT3_O;

    // =========== FETCH ===========
    fetch fetch_i(
        .clk        (clk),
        .rst        (reset),
        .pc_o       (FETCH_PC_O),
        .insn_o     (FETCH_INSN_O)
    );
    assign FETCH_INSN_O     = MEM_DATA_O;

    // =========== INSTRUCTION MEMORY ===========
    memory #(
        .AWIDTH     (AWIDTH),
        .DWIDTH     (DWIDTH)
    ) insn_mem (
        .clk        (clk),
        .rst        (reset),

        .addr_i     (MEM_ADDR_I),
        .data_i     (MEM_DATA_I),

        .read_en_i  (MEM_READ_EN_I),
        .write_en_i (MEM_WRITE_EN_I),

        .data_o     (MEM_DATA_O)
    );
    // Assign Instruction Memory Inputs
    assign MEM_ADDR_I       = DECODE_PC_O;
    assign MEM_DATA_I       = 32'b0;
    assign MEM_READ_EN_I    = 1'b1;
    assign MEM_WRITE_EN_I   = 1'b0;

    // =========== DECODE ===========
    decode decode_i(
        .clk        (clk),
        .rst        (reset),
        .insn_i     (DECODE_INSN_I),
        .pc_i       (DECODE_PC_I),
        .pc_o       (DECODE_PC_O),
        .insn_o     (DECODE_INSN_O),
        .opcode_o   (DECODE_OPCODE_O),
        .rd_o       (DECODE_RD_O),
        .rs1_o      (DECODE_RS1_O),
        .rs2_o      (DECODE_RS2_O),
        .funct3_o   (DECODE_FUNCT3_O),
        .funct7_o   (DECODE_FUNCT7_O),
        .shamt_o    (DECODE_SHAMT_O),
        .imm_o      (DECODE_IMM_O)
    );
    // Assign Decode Inputs
    assign DECODE_INSN_I    = FETCH_INSN_O;
    assign DECODE_PC_I      = FETCH_PC_O;
    assign DECODE_IMM_O     = IGEN_IMM_O;

    // =========== IMMEDIATE GENERATOR ===========
    igen igen_i(
        .opcode_i   (IGEN_OPCODE_I),
        .insn_i     (IGEN_INSN_I),
        .imm_o      (IGEN_IMM_O)
    );
    // Assign Igen Inputs
    assign IGEN_OPCODE_I    = DECODE_OPCODE_O;
    assign IGEN_INSN_I      = DECODE_INSN_O;

    // =========== REGISTER FILE ===========
    register_file #(
        .DWIDTH(DWIDTH)
    ) register_file_i (
        .clk        (clk),
        .rst        (reset),

        .rs1_i      (RF_RS1_I),
        .rs2_i      (RF_RS2_I),
        .rd_i       (RF_RD_I),
        .datawb_i   (RF_DATAWB_I),
        .regwren_i  (RF_REGWREN_I),
        .rs1data_o  (RF_RS1DATA_O),
        .rs2data_o  (RF_RS2DATA_O)
    );
    //Assign Register File Inputs
    assign RF_RS1_I         = DECODE_RS1_O;
    assign RF_RS2_I         = DECODE_RS2_O;
    assign RF_RD_I          = DECODE_RD_O;
    assign RF_DATAWB_I      = 32'b0;
    assign RF_REGWREN_I     = 1'b0;

    // =========== EXECUTE ===========
    alu #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    )alu_e(
        .pc_i       (ALU_PC_I),
        .rs1_i      (ALU_RS1_I),
        .rs2_i      (ALU_RS2_I),
        .alusel_i   (ALU_SEL_I),
        .res_o      (ALU_RES_O),
        .brtaken_o  (ALU_BRTAKEN_O)
    );
    //Assign ALU inputs
    assign ALU_PC_I     = DECODE_PC_O;
    assign ALU_RS1_I    = RF_RS1DATA_O;
    assign ALU_RS2_I    = (CTRL_IMMSEL_O == 0)? RF_RS2DATA_O : IGEN_IMM_O;
    assign ALU_SEL_I    = CTRL_ALUSEL_O;


endmodule : pd3
