/*
 * Module: decode
 *
 * Description: Decode stage
 *
 * Inputs:
 * 1) clk
 * 2) rst signal
 * 3) insn_iruction ins_i
 * 4) program counter pc_i
 * Outputs:
 * 1) AWIDTH wide program counter pc_o
 * 2) DWIDTH wide insn_iruction output insn_o
 * 3) 5-bit wide destination register ID rd_o
 * 4) 5-bit wide source 1 register ID rs1_o
 * 5) 5-bit wide source 2 register ID rs2_o
 * 6) 7-bit wide funct7 funct7_o
 * 7) 3-bit wide funct3 funct3_o
 * 8) 32-bit wide immediate imm_o
 * 9) 5-bit wide shift amount shamt_o
 * 10) 7-bit width opcode_o
 */

`include "constants.svh"

module decode #(
    parameter int DWIDTH=32,
    parameter int AWIDTH=32
)(
	// inputs
	input logic clk,
	input logic rst,
	input logic [DWIDTH - 1:0] insn_i,
	input logic [DWIDTH - 1:0] pc_i,

    // outputs
    output logic [AWIDTH-1:0] pc_o,
    output logic [DWIDTH-1:0] insn_o,
    output logic [6:0] opcode_o,
    output logic [4:0] rd_o,
    output logic [4:0] rs1_o,
    output logic [4:0] rs2_o,
    output logic [6:0] funct7_o,
    output logic [2:0] funct3_o,
    output logic [4:0] shamt_o,
    output logic [DWIDTH-1:0] imm_o
);

    /*
     * Process definitions to be filled by
     * student below...
     */

    logic [6:0] opcode, funct7;
    logic [4:0] rs1, rs2, rd, shiftamt;
    logic [2:0] funct3;
    logic [DWIDTH-1:0] instruction, imm_reg;
    logic [AWIDTH-1:0] programcounter;

    //Slice opcode out for further comibinational decode later
    assign opcode = instruction[6:0];

    //Assign wires for output
    assign insn_o = instruction;
    assign pc_o = programcounter;
    assign opcode_o = opcode;
    assign funct3_o = funct3;
    assign funct7_o = funct7;
    assign rs1_o = rs1;
    assign rs2_o = rs2;
    assign rd_o = rd;
    assign imm_o = imm_reg;
    assign shamt_o = shiftamt;

    //Logic to accept new instructions and program counter as well as to reset.
    always_ff @(posedge clk) begin
        if(rst) begin
            instruction <='d0;
            programcounter <='d0;
        end
        else begin
            instruction <= insn_i;
            programcounter <= pc_i;
        end
    end

    //Decoding the opcodes
    always_comb begin : Decode
        case(opcode):

            //R-Type instructions
            7'b0110011: begin
                //slice instruction
                rd = instruction[11:7];
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct7 = instruction[31:25];
            end

            //I-Type Instructions:
            7'0010011: begin
                rd = instruction[11:7];
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                case(funct3):
                    //Remember, all sign extended unless otherwise noted
                    //ADDI, XORI, ORI, ANDI
                    3'h0: imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
                    3'h4: imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
                    3'h6: imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
                    3'h7: imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};

                    //Shift logical left
                    /*Note, I am passing on the values of the immediate for the ALU or control
                    to be able to establish the logical or airthmetic for right or left. 
                    */
                    3'h1: begin
                        if(instruction[31:25]==0x00) begin
                            shiftamt = instruction[11:7];
                            imm_reg = {{DWIDTH-12{0}},instruction[31:25],instruction[11:7]};
                        end
                    end

                    //Shift Right Logical and Shift Right Arithmetic
                    3'h5: begin
                        if(instruction[31:25]==0x00 ||instruction[31:25]==0x20) begin
                            shiftamt = instruction[11:7];
                            imm_reg = {{DWIDTH-12{0}},instruction[31:25],instruction[11:7]};
                        end
                    end

                endcase

            end
            //Zero out everything on reset or unknown opcode
            default : begin
                rd = 'd0;
                funct3 = 'd0;
                rs1 = 'd0;
                rs2 = 'd0;
                funct7 = 'd0;

            end
        endcase
    end

endmodule : decode
