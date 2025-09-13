/*
 * Module: pd0
 *
 * Description: Top level module that will contain sub-module instantiations.
 * An instantiation of the assign_xor module is shown as an example. The other
 * modules must be instantiated similarly. Probes are defined, which will be used
 * to test This file also defines probes that will be used to test the design. Note
 * that the top level module should have only two inputs: clk and rest signals.
 *
 * Inputs:
 * 1) clk
 * 2) reset signal
 */

module pd0 #(
    parameter int DWIDTH = 32)
 (
    input logic clk,
    input logic reset
    );

 // Probes that will be defined in probes.svh
 logic assign_xor_op1;
 logic assign_xor_op2;
 logic assign_xor_res;

 logic [DWIDTH-1:0] assign_ALU_op1, assign_ALU_op2, assign_ALU_res;
 logic [1:0] assign_ALU_sel;
 logic assign_ALU_nflag, assign_ALU_zflag;

 logic [DWIDTH-1:0] assign_reg_in, assign_reg_out;

 logic [DWIDTH-1:0] assign_TSP_op1, assign_TSP_op2, assign_TSP_res;

 assign_xor assign_xor_0 (
     .op1_i (assign_xor_op1),
     .op2_i (assign_xor_op2),
     .res_o (assign_xor_res)
 );

 /*
  * Instantiate other submodules and
  * probes. To be filled by student...
  *
  */
  three_stage_pipeline #(
    .DWIDTH(DWIDTH)
  ) pipeline (
    .clk(clk),
    .rst(rst),
    .op1_i(assign_TSP_op1),
    .op2_i(assign_TSP_op2),
    .res_o(assign_TSP_res)
  );

  alu #(
    .DWIDTH(DWIDTH)
  ) the_alu (
    .zero_o(assign_ALU_zflag),
    .neg_o(assign_ALU_nflag),
    .sel_i(assign_ALU_sel),
    .op1_i(assign_ALU_op1),
    .op2_i(assign_ALU_op2),
    .res_o(assign_ALU_res)
  );

  reg_rst #(
    .DWIDTH(DWIDTH)
  ) register (
    .clk(clk),
    .rst(rst),
    .in_i(assign_reg_in),
    .out_o(assign_reg_out)
  );

  

endmodule: pd0
