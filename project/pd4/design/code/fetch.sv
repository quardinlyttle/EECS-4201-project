/*
 * Module: fetch
 *
 * Description: Fetch stage
 *
 * -------- REPLACE THIS FILE WITH THE MEMORY MODULE DEVELOPED IN PD1 -----------
 *
 * Inputs:
 * 1) clk
 * 2) rst signal
 *
 * Outputs:
 * 1) AWIDTH wide program counter pc_o
 * 2) DWIDTH wide instruction output insn_o
 */
module fetch #(
    parameter int DWIDTH=32,
    parameter int AWIDTH=32,
    parameter int BASEADDR=32'h01000000
    )(
	// inputs
	input logic clk,
	input logic rst,
    input logic pc_sel_i,
    input logic [AWIDTH - 1:0] newpc_i,
	// outputs
	output logic [AWIDTH - 1:0] pc_o,
    output logic [DWIDTH - 1:0] insn_o
);
    /*
     * Process definitions to be filled by
     * student below...
     */

    logic [AWIDTH - 1:0] pc;
    logic pc_sel;

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= BASEADDR;
            pc_sel <= 1'b1;
        end else begin
            if(pc_sel) begin
                pc <= pc + 32'd4;
            end
            else begin
                pc <= newpc_i;
            end
        end
    end

	assign pc_o = pc;

endmodule : fetch