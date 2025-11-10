/*
 * Module: control
 *
 * Description: This module sets the control bits (control path) based on the decoded
 * instruction. Note that this is part of the decode stage but housed in a separate
 * module for better readability, debug and design purposes.
 *
 * -------- REPLACE THIS FILE WITH THE MEMORY MODULE DEVELOPED IN PD2 -----------
 */

/*
 * Module: control
 *
 * Description: This module sets the control bits (control path) based on the decoded
 * instruction. Note that this is part of the decode stage but housed in a separate
 * module for better readability, debug and design purposes.
 *
 * Inputs:
 * 1) DWIDTH instruction ins_i
 * 2) 7-bit opcode opcode_i
 * 3) 7-bit funct7 funct7_i
 * 4) 3-bit funct3 funct3_i
 *
 * Outputs:
 * 1) 1-bit PC select pcsel_o
 * 2) 1-bit Immediate select immsel_o
 * 3) 1-bit register write en regwren_o
 * 4) 1-bit rs1 select rs1sel_o
 * 5) 1-bit rs2 select rs2sel_o
 * 6) k-bit ALU select alusel_o
 * 7) 1-bit memory read en memren_o
 * 8) 1-bit memory write en memwren_o
 * 9) 2-bit writeback sel wbsel_o
 */

`include "constants.svh"

module control #(
	parameter int DWIDTH=32
)(
	// inputs
    input logic [DWIDTH-1:0] insn_i,
    input logic [6:0] opcode_i,
    input logic [6:0] funct7_i,
    input logic [2:0] funct3_i,

    // outputs
    output logic pcsel_o,
    output logic immsel_o,
    output logic regwren_o,
    output logic rs1sel_o,
    output logic rs2sel_o,
    output logic memren_o,
    output logic memwren_o,
    output logic [1:0] wbsel_o,
    output logic [3:0] alusel_o
);
    always_comb begin : Control
        case(opcode_i)
            //R Type
            RTYPE: begin
                wbsel_o =   wbALU;
                pcsel_o =   1'b0;
                immsel_o =  1'b0;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;

                case(funct3_i)
                    //ADD and SUB
                    3'h0: begin
                        case(funct7_i)
                            7'h0: alusel_o = ADD;
                            7'h2: alusel_o = SUB;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //XOR
                    3'h4: begin
                        case(funct7_i)
                            7'h0: alusel_o = XOR;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //OR
                    3'h6: begin
                        case(funct7_i)
                            7'h0: alusel_o = OR;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //AND
                    3'h7: begin
                        case(funct7_i)
                            7'h0: alusel_o = AND;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SLL
                    3'h1: begin
                        case(funct7_i)
                            7'h0: alusel_o = SLL;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SRL SRA
                    3'h5: begin
                        case(funct7_i)
                            7'h0: alusel_o = SRL;
                            7'h2: alusel_o = SRA;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SLT
                    3'h2: begin
                        case(funct7_i)
                            7'h0: alusel_o = SLT;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SLTU
                    3'h3: begin
                        case(funct7_i)
                            7'h0: alusel_o = SLTU;
                            default: alusel_o = ADD;
                        endcase
                    end
                endcase
            end

            //I-Type Instructions (except loads):
            ITYPE: begin
                wbsel_o =   wbALU;
                pcsel_o =   1'b0;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b1;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                case(funct3_i)
                    //ADDI
                    3'h0: alusel_o = ADD;
                    //XORI
                    3'h4: alusel_o = XOR;
                    //ORI
                    3'h6: alusel_o = OR;
                    //ANDI
                    3'h7: alusel_o = AND;
                    //SLLI
                    3'h1: begin
                        case(insn_i[31:25])
                            7'h0: alusel_o = SLL;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SRLI SRAI
                    3'h5: begin
                       case(insn_i[31:25])
                            7'h0: alusel_o = SRL;
                            7'h2: alusel_o = SRA;
                            default: alusel_o = ADD;
                        endcase
                    end
                    //SLTI
                    3'h2: alusel_o = SLT;
                    //SLTIU
                    3'h3: alusel_o = SLTU;
                endcase
            end

            //Load instructions
            //Explicitly handle funct3 and funct7
            LOAD: begin
                wbsel_o =   wbMEM;
                pcsel_o =   1'b0;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b1;
                memren_o =  1'b1;
                memwren_o = 1'b0;
                alusel_o = ADD;
            end

            //Store Instructions
            //Remember the logic is a mux not on off so 0 is selected.
            STORE: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b0;
                immsel_o =  1'b1;
                regwren_o = 1'b0;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b1;
                alusel_o = ADD;
            end

            //Branch Instructions
            BRANCH: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b1;
                immsel_o =  1'b1;
                regwren_o = 1'b0;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                alusel_o =  PCADD;
            end

            //Jump and Link
            JAL: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b1;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                alusel_o = PCADD;
            end

            //Jump and Link Register
            //Note: this uses the I Type format. Funct 3 is fixed to 0;
            JALR: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b1;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                alusel_o = ADD;
            end

            //Load Upper Immedaite
            LUI: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b0;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b1;
                memwren_o = 1'b0;
                alusel_o = ADD;
            end

            //Add Upper Immediate to PC
            AUIPC: begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b1;
                immsel_o =  1'b1;
                regwren_o = 1'b1;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                alusel_o = ADD;
            end

            //Zero out everything on reset or unknown/invalid opcode
            default : begin
                wbsel_o =   wbOFF;
                pcsel_o =   1'b0;
                immsel_o =  1'b0;
                regwren_o = 1'b0;
                rs1sel_o =  1'b0;
                rs2sel_o =  1'b0;
                memren_o =  1'b0;
                memwren_o = 1'b0;
                alusel_o = ADD;
            end
        endcase
    end
endmodule : control
