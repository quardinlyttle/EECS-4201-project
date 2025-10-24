/*
 * Module: alu
 *
 * Description: ALU implementation for execute stage.
 *
 * Inputs:
 * 1) 32-bit PC pc_i
 * 2) 32-bit rs1 data rs1_i
 * 3) 32-bit rs2 data rs2_i
 * 4) 3-bit funct3 funct3_i
 * 5) 7-bit funct7 funct7_i
 *
 * Outputs:
 * 1) 32-bit result of ALU res_o
 * 2) 1-bit branch taken signal brtaken_o
 */


`include "constants.svh"

module alu #(
    parameter int DWIDTH=32,
    parameter int AWIDTH=32
)(
    input logic [AWIDTH-1:0] pc_i,
    input logic [DWIDTH-1:0] rs1_i,
    input logic [DWIDTH-1:0] rs2_i,
    //input logic [2:0] funct3_i,
    //input logic [6:0] funct7_i,
    /* We are going to be using the alusel_i from decode*/
    input logic [3:0] alusel_i,
    output logic [DWIDTH-1:0] res_o,
    output logic brtaken_o
);

    /*
     * Process definitions to be filled by
     * student below...
     */
    assign brtaken_o = 1'b0;
    always_comb begin: ALU
        case(alusel_i)
        ADD: res_o = rs1_i + rs2_i;
        SUB: res_o = rs1_i - rs2_i;
        XOR: res_o = rs1_i ^ rs2_i;
        AND: res_o = rs1_i & rs2_i;
        OR:  res_o = rs1_i | rs2_i;
        SLL: res_o = rs1_i << rs2_i;
        SRL: res_o = rs1_i >> rs2_i;
        SRA: res_o = rs1_i >>> rs2_i;
        SLT: res_o = (rs1 < rs2) ? 1:0;
        SLTU: res_o = ($unsigned(rs1) < $unsigned(rs2)) ? 1:0;
        PCADD: res_o = pc_i + rs2_i;

        default: res_o = 'd0;
        endcase
    end

endmodule : alu
