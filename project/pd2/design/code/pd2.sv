/*
 * Module: pd2
 *
 * Description: Top level module that will contain sub-module instantiations.
 *
 * Inputs:
 * 1) clk
 * 2) reset signal
 */

module pd2 #(
    parameter int AWIDTH = 32,
    parameter int DWIDTH = 32)(
    input logic clk,
    input logic reset
);

 /*
  * Instantiate other submodules and
  * probes. To be filled by student...
  *
  */

  // Fetch Probes
  logic [AWIDTH-1:0] probe_f_pc;
  logic [DWIDTH-1:0] probe_f_insn;

  //Decode Probes
  logic [DWIDTH-1:0] probe_d_insn;
  logic [AWIDTH-1:0] probe_d_pc;
  logic [6:0] probe_d_opcode_o;
  logic [4:0] probe_d_rd_o;
  logic [4:0] probe_d_rs1_o;
  logic [4:0] probe_d_rs2_o;
  logic [6:0] probe_d_funct7;
  logic [2:0] probe_d_funct3;
  logic [4:0] probe_d_shamt_o;
  logic [DWIDTH-1:0] probe_d_imm_o;


  //Instantiations
  fetch ftch(
    .clk(clk),
    .rst(reset),
    .pc_o(probe_f_pc),
    .insn_o(probe_f_insn)
  );

  decode dcde(
    .clk(clk),
    .rst(reset),
    .insn_i(probe_f_insn),
    .pc_i(probe_f_pc),
    .pc_o(probe_d_pc),
    .insn_o(probe_d_insn),
    .opcode_o(probe_d_opcode_o),
    .rd_o(probe_d_rd_o),
    .rs1_o(probe_d_rs1_o),
    .rs2_o(probe_d_rs2_o),
    .funct3_o(probe_d_funct3),
    .funct7_o(probe_d_funct7),
    .shamt_o(probe_d_shamt_o),
    .imm_o(probe_d_imm_o)
  );

  igen immgen(
    .opcode_i(probe_d_opcode_o),
    .insn_i(probe_d_insn),
    .imm_o(probe_d_imm_o)
  );

    // Memory I/O Signals
  logic [AWIDTH-1:0] MEMORY_ADDR;
  logic [DWIDTH-1:0] MEMORY_DATA_IN;
  logic MEMORY_READ_EN;
  logic MEMORY_WRITE_EN;
  logic [DWIDTH-1:0] MEMORY_DATA_OUT;
  memory #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH)
  ) mem_inst (
    .clk(clk),
    .rst(reset),

    .addr_i(probe_f_pc),
    .data_i(MEMORY_DATA_IN),

    .read_en_i(1'b1),
    .write_en_i(MEMORY_WRITE_EN),

    .data_o(probe_f_insn)
  );


endmodule : pd2
