/*
 * Module: igen
 *
 * Description: Immediate value generator
 *
 * Inputs:
 * 1) opcode opcode_i
 * 2) input instruction insn_i
 * Outputs:
 * 2) 32-bit immediate value imm_o
 */

module igen #(
    parameter int DWIDTH=32
    )(
    input logic [6:0] opcode_i,
    input logic [DWIDTH-1:0] insn_i,
    output logic [31:0] imm_o
);
    /*
     * Process definitions to be filled by
     * student below...
     */

    //Noticed that the output for imm_o is not consisten for the DWIDTH. Might bring up later?
    logic [DWIDTH-1:0] instruction, imm_reg;
    logic [2:0] funct3;
    assign instruction = insn_i;
    assign imm_o = imm_reg;
    assign funct3 = insn_i[14:12];

    always_comb begin : immgen
        case(opcode_i)

            //R-Type instructions
            7'b011_0011: begin
                imm_reg = 'd0;
            end

            //I-Type Instructions (except loads):
            7'b001_0011: begin
                case(funct3)
                    //Remember, all sign extended unless otherwise noted
                    //ADDI, XORI, ORI, ANDI
                    3'h0,
                    3'h4,
                    3'h6,
                    3'h7: begin
                        imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
                    end

                    //Shift logical left
                    /*Note, I am passing on the values of the immediate for the ALU or control
                    to be able to establish the logical or airthmetic for right or left
                    */
                    3'h1: begin
                        if(instruction[31:25]=='h0) begin
                            imm_reg = {{DWIDTH-12{0}},instruction[31:20]};
                        end
                        else imm_reg = 'd0;
                    end

                    //Shift Right Logical and Shift Right Arithmetic
                    3'h5: begin
                        if(instruction[31:25]=='h0 ||instruction[31:25]=='h20) begin
                            imm_reg = {{DWIDTH-12{0}},instruction[31:20]};
                        end
                        else imm_reg = 'd0;
                    end

                    //Set Less Than (signed and unsigned)
                    3'h2,
                    3'h3: imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};

                    default: begin
                        imm_reg='d0;
                    end
                endcase

            end

            //Load instructions
            7'b000_0011: begin
                imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
            end

            //Store Instructions
            7'b010_0011: begin
                imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:25],instruction[11:7]};
                end

            //Branch Instructions
            7'b110_0011: begin
            //Pay special attention to how Branch instructions are sliced!!
            imm_reg = {{DWIDTH-13{instruction[31]}}, instruction[31], instruction[7],instruction[30:25],instruction[11:8],1'b0};
            end

            //Jump and Link
            7'b110_1111: begin
            //Another funky slicing, pay attention.
            imm_reg = {{DWIDTH-21{instruction[31]}}, instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
            end

            //Jump and Link Register
            //Note: this uses the I Type format. Funct 3 is fixed to 0;
            7'b110_0111: begin
            imm_reg = {{DWIDTH-12{instruction[31]}}, instruction[31:20]};
            end

            //Load Upper Immedaite
            7'b011_0111: begin
                imm_reg = {instruction[31:12],12'b0};
            end

            //Add Upper Immediate to PC
            7'b001_0111: begin
                imm_reg = {instruction[31:12],12'b0};
            end

            //Zero out everything on reset or unknown/invalid opcode
            default : begin
                imm_reg = 'd0;

            end
        endcase
    end

endmodule : igen
