/*
 * Module: branch_control
 *
 * Description: Branch control logic. Only sets the branch control bits based on the
 * branch instruction
 *
 * Inputs:
 * 1) 7-bit instruction opcode opcode_i
 * 2) 3-bit funct3 funct3_i
 * 3) 32-bit rs1 data rs1_i
 * 4) 32-bit rs2 data rs2_i
 *
 * Outputs:
 * 1) 1-bit operands are equal signal breq_o
 * 2) 1-bit rs1 < rs2 signal brlt_o
 */

 module branch_control #(
    parameter int DWIDTH=32
)(
    // inputs
    input logic [6:0] opcode_i,
    input logic [2:0] funct3_i,
    input logic [DWIDTH-1:0] rs1_i,
    input logic [DWIDTH-1:0] rs2_i,
    // outputs
    output logic breq_o,
    output logic brlt_o
);
    logic breq, brlt, brlt_signed, brlt_unsigned, enableBrOutput;

    // Branch Equal
    assign breq = (rs1_i == rs2_i);

    // Branch Less Than (Unsigned)
    assign brlt_unsigned = unsigned'(rs1_i) < unsigned'(rs2_i);

    // Branch Less Than (Signed)
    assign brlt_signed = signed'(rs1_i) < signed'(rs2_i);

    // Choose between signed and unsigned brlt depending
    // on funct3 (h6 and h7 are unsigned)
    assign brlt = (funct3_i == 3'h6 || funct3_i == 3'h7) ?
                            brlt_unsigned : brlt_signed;

    // Check if opcode is branching type
    assign enableBrOutput = (opcode_i == 7'b1100011);

    // Output result
    assign breq_o = (enableBrOutput) ? breq : 1'b0;
    assign brlt_o = (enableBrOutput) ? brlt : 1'b0;

endmodule : branch_control
