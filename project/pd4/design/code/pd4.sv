/*
 * Module: pd4
 *
 * Description: Top level module that will contain sub-module instantiations.
 *
 * Inputs:
 * 1) clk
 * 2) reset signal
 */

module pd4 #(
    parameter int AWIDTH = 32,
    parameter int DWIDTH = 32)(
    input logic clk,
    input logic reset
);
    // ============================================
    // ============== MODULE SIGNALS ==============
    // ============================================

    // ======= CONTROL SIGNALS =======
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
    logic               FETCH_PC_SEL_I;
    logic [AWIDTH-1:0]  FETCH_NEWPC_I;

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
    logic [2:0]         MEM_FUNCT3_I;
    // Memory Outputs
    logic [DWIDTH-1:0]  MEM_DATA_O;
    logic               MEM_DATA_VLD_O;
    //Instruction Ports
    logic [AWIDTH-1:0] MEM_INSN_ADDR_I;
    logic [DWIDTH-1:0] MEM_INSN_O;

    // ======= REGISTER FILE SIGNALS =======
    // RF Inputs
    logic [4:0]         RF_RS1_I;
    logic [4:0]         RF_RS2_I;
    logic [4:0]         RF_RD_I;
    logic [DWIDTH-1:0]  RF_DATAWB_I;
    logic               RF_REGWREN_I;
    // RF Outputs
    logic [DWIDTH-1:0]  RF_RS1DATA_O;
    logic [DWIDTH-1:0]  RF_RS2DATA_O;

    // ======= ALU SIGNALS =======
    // ALU Inputs
    logic [AWIDTH-1:0]  ALU_PC_I;
    logic [DWIDTH-1:0]  ALU_RS1_I;
    logic [DWIDTH-1:0]  ALU_RS2_I;
    logic [3:0]         ALU_SEL_I;
    // ALU Outputs
    logic [DWIDTH-1:0]  ALU_RES_O;
    logic               ALU_BRTAKEN_O;

    // ======= BRANCH COMPARATOR SIGNALS =======
    // BC Inputs
    logic               BC_OPCODE_I;
    logic               BC_FUNCT3_I;
    logic [DWIDTH-1:0]  BC_RS1_I;
    logic [DWIDTH-1:0]  BC_RS2_I;
    // BC Outputs
    logic               BC_BREQ_O;
    logic               BC_BRLT_O;

    // ======= WRITEBACK SIGNALS =======
    logic [AWIDTH-1:0]  WB_PC_I;
    logic [DWIDTH-1:0]  WB_ALU_RES_I;
    logic [DWIDTH-1:0]  WB_MEMORY_DATA_I;
    logic [1:0]         WB_SEL_I;
    logic               WB_BRTAKEN_I;
    logic [DWIDTH-1:0]  WB_DATA_O;
    logic [AWIDTH-1:0]  WB_NEXT_PC_O;

    // ============================================
    // ============= RV32 MAIN BLOCKS =============
    // ============================================

    // =========== CONTROL MODULE INSTANTIATION ===========
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

    // =========== FETCH MODULE INSTANTIATION ===========
    fetch fetch_i(
        .clk        (clk),
        .rst        (reset),
        .pc_sel_i   (FETCH_PC_SEL_I)
        .newpc_o    (FETCH_NEWPC_I)
        .pc_o       (FETCH_PC_O),
        .insn_o     (FETCH_INSN_O)
    );
    assign FETCH_INSN_O     = MEM_INSN_O;
    assign FETCH_PC_SEL_I   = CTRL_PCSEL_O;
    assign FETCH_NEWPC_I    = ALU_SEL_I;

    // =========== INSTRUCTION MEMORY MODULE INSTANTIATION ===========
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
        .funct3_i   (MEM_FUNCT3_I),

        .insn_addr_i(MEM_ADDR_I),
        .insn_o     (MEM_INSN_O),

        .data_o     (MEM_DATA_O),
        .data_vld_o (MEM_DATA_VLD_O)
    );
    // Assign Instruction Memory Inputs
    assign MEM_ADDR_I       = DECODE_PC_O;
    assign MEM_DATA_I       = 32'b0;
    assign MEM_READ_EN_I    = 1'b1;
    assign MEM_WRITE_EN_I   = 1'b0;
    assign MEM_FUNCT3_I     = DECODE_FUNCT3_O;
    assign MEM_INSN_ADDR_I  = FETCH_PC_O;

    // =========== DECODE MODULE INSTANTIATION ===========
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

    // =========== IMMEDIATE GENERATOR MODULE INSTANTIATION ===========
    igen igen_i(
        .opcode_i   (IGEN_OPCODE_I),
        .insn_i     (IGEN_INSN_I),
        .imm_o      (IGEN_IMM_O)
    );
    // Assign Igen Inputs
    assign IGEN_OPCODE_I    = DECODE_OPCODE_O;
    assign IGEN_INSN_I      = DECODE_INSN_O;

    // =========== REGISTER FILE MODULE INSTANTIATION ===========
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
    // Assign Register File Inputs
    assign RF_RS1_I         = DECODE_RS1_O;
    assign RF_RS2_I         = DECODE_RS2_O;
    assign RF_RD_I          = DECODE_RD_O;
    // assign RF_DATAWB_I      = ALU_RES_O;
    assign RF_DATAWB_I      = 'd0;
    assign RF_REGWREN_I     = CTRL_REGWREN_O;

    // =========== BRANCH COMPARATOR MODULE INSTANTIATION ===========
    branch_control branching(
        .opcode_i(DECODE_OPCODE_O),
        .funct3_i(DECODE_FUNCT3_O),
        .rs1_i(RF_RS1DATA_O),
        .rs2_i(RF_RS2DATA_O),
        .breq_o(BC_BREQ_O),
        .brlt_o(BC_BRLT_O)
    );
    // BC Input Assignments
    assign BC_OPCODE_I      = DECODE_OPCODE_O;
    assign BC_FUNCT3_I      = DECODE_FUNCT3_O;
    assign BC_RS1_I         = RF_RS1DATA_O;
    assign BC_RS2_I         = RF_RS2DATA_O;

    // Branch Taken Computation
    always_comb begin: BRANCHER
        if(DECODE_OPCODE_O==BRANCH) begin
            case(DECODE_FUNCT3_O)
            'h0: ALU_BRTAKEN_O = BC_BREQ_O;
            'h1: ALU_BRTAKEN_O = ~BC_BREQ_O;
            'h4, 'h6: ALU_BRTAKEN_O = BC_BRLT_O;
            'h5, 'h7: ALU_BRTAKEN_O = ~BC_BRLT_O;
            default: ALU_BRTAKEN_O = 'd0;
            endcase
        end
        else ALU_BRTAKEN_O = 'd0;
    end

    // =========== EXECUTE MODULE INSTANTIATION ===========
    alu #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    )alu_e(
        .pc_i       (ALU_PC_I),
        .funct3_i   (DECODE_FUNCT3_O),
        .funct7_i   (DECODE_FUNCT7_O),
        .rs1_i      (ALU_RS1_I),
        .rs2_i      (ALU_RS2_I),
        .alusel_i   (ALU_SEL_I),
        .res_o      (ALU_RES_O),
        .brtaken_o  (ALU_BRTAKEN_O) // Dummy
    );
    // Assign ALU inputs
    assign ALU_PC_I     = DECODE_PC_O;
    assign ALU_RS1_I    = RF_RS1DATA_O;
    assign ALU_RS2_I    = (CTRL_IMMSEL_O)? IGEN_IMM_O : RF_RS2DATA_O;
    assign ALU_SEL_I    = CTRL_ALUSEL_O;

    // =========== WRITEBACK MODULE INSTANTIATION ===========
    writeback #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    )writeback(
        .pc_i(WB_PC_I),
        .alu_res_i(WB_ALU_RES_I),
        .memory_data_i(WB_MEMORY_DATA_I),
        .wbsel_i(WB_SEL_I),
        .brtaken_i(WB_BRTAKEN_I),
        .write_data_o(WB_DATA_O),
        .next_pc_o(WB_NEXT_PC_O)
    );

    assign WB_PC_I          = ;
    assign WB_ALU_RES_I     = ALU_RES_O;
    assign WB_MEMORY_DATA_I = MEM_DATA_O;
    assign WB_SEL_I         = CTRL_WBSEL_O;
    assign WB_BRTAKEN_I     = ALU_BRTAKEN_O;


    // program termination logic
    reg is_program = 0;
    always_ff @(posedge clk) begin
        if (data_out == 32'h00000073) $finish;  // directly terminate if see ecall
        if (data_out == 32'h00008067) is_program = 1;  // if see ret instruction, it is simple program test
        // [TODO] Change register_file_0.registers[2] to the appropriate x2 register based on your module instantiations...
        // if (is_program && (register_file_0.registers[2] == 32'h01000000 + `MEM_DEPTH)) $finish;
        if (is_program && (register_file_i.rf_registers[2] == 32'h01000000 + `MEM_DEPTH)) $finish;
    end

endmodule : pd4
