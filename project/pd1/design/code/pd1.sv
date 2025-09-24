/*
 * Module: pd1
 *
 * Description: Top level module that will contain sub-module instantiations.
 *
 * Inputs:
 * 1) clk
 * 2) reset signal
 */

module pd1 #(
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

  // Memory Probes
  logic [AWIDTH-1:0] probe_addr;
  logic [DWIDTH-1:0] probe_data_in;
  logic [DWIDTH-1:0] probe_data_out;
  logic probe_read_en;
  logic probe_write_en;

  // Fetch Probes
  logic [AWIDTH-1:0] probe_f_pc;
  logic [DWIDTH-1:0] probe_f_insn;

  // Fetch I/O Signals
  logic [AWIDTH-1:0] FETCH_PC;
  logic [DWIDTH-1:0] FETCH_INSN;
  fetch #(
    .AWIDTH(AWIDTH),
    .DWIDTH(DWIDTH)
  ) fetch_inst (
    .clk(clk),
    .reset(rst),

    .pc_o(FETCH_PC),
    .insn_o(FETCH_INSN)
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

    .addr_i(MEMORY_ADDR),
    .data_i(MEMORY_DATA_IN),

    .read_en_i(MEMORY_READ_EN),
    .write_en_i(MEMORY_WRITE_EN),

    .data_o(MEMORY_DATA_OUT)
  );

  assign MEMORY_ADDR = probe_addr;
  assign MEMORY_DATA_IN = probe_data_in;
  assign MEMORY_READ_EN = probe_read_en;
  assign MEMORY_WRITE_EN = probe_write_en;

  // ========= Probe Outputs =========
  // Fetch Probes
  assign probe_f_pc   = FETCH_PC;
  assign probe_f_insn = FETCH_INSN;
  // Memory Probes
  assign probe_data_out = MEMORY_DATA_OUT;

endmodule : pd1
