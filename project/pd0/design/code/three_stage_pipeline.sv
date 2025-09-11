/*
 * Module: three_stage_pipeline
 *
 * A 3-stage pipeline (TSP) where the first stage performs an addition of two
 * operands (op1_i, op2_i) and registers the output, and the second stage computes
 * the difference between the output from the first stage and op1_i and registers the
 * output. This means that the output (res_o) must be available two cycles after the
 * corresponding inputs have been observed on the rising clock edge
 *
 * Visually, the circuit should look like this:
 *               <---         Stage 1           --->
 *                                                        <---         Stage 2           --->
 *                                                                                               <--    Stage 3    -->
 *                                    |------------------>|                    |
 * -- op1_i -->|                    | --> |         |     |                    |-->|         |   |                    |
 *             | pipeline registers |     | ALU add | --> | pipeline registers |   | ALU sub |-->| pipeline register  | -- res_o -->
 * -- op2_i -->|                    | --> |         |     |                    |-->|         |   |                    |
 *
 * Inputs:
 * 1) 1-bit clock signal
 * 2) 1-bit wide synchronous reset
 * 3) DWIDTH-wide input op1_i
 * 4) DWIDTH-wide input op2_i
 *
 * Outputs:
 * 1) DWIDTH-wide result res_o
 */

module three_stage_pipeline #(
parameter int DWIDTH = 8)(
        input logic clk,
        input logic rst,
        input logic [DWIDTH-1:0] op1_i,
        input logic [DWIDTH-1:0] op2_i,
        output logic [DWIDTH-1:0] res_o
    );

    /*
     * Process definitions to be filled by
     * student below...
     * [HINT] Instantiate the alu and reg_rst modules
     * and set up the necessary connections
     *
     */
    
    wire [DWIDTH-1:0] stage2_in_1, stage2_in_2, stage2_out_1, stage2_out_2;
    wire [DWIDTH-1:0] stage1_1, stage1_2;
    wire [DWIDTH-1:0] stage3_in_1, stage3_out_1;

    //First Stage
    //Remember, op1_i is then used again in the second stage. You need to pass it on.
    reg_rst pipe1_1 (.clk(clk), .rst(rst), .in_i(op1_i),.out_o(stage1_1));
    reg_rst pipe1_2 (.clk(clk),
                    .rst(rst), .in_i(op2_i), .out_o(stage1_2));
    reg_rst pipe1_3 (.clk(clk), .rst(rst), .in_i(op1_i), .out_o(stage2_in_1));

    //As the input goes into the first registers, after the clock its passed into the alu (which is comibinational!)
    alu adder (.sel_i(2'b00), .op1_i(stage1_1), .op2_i(stage1_2), .res_o(stage2_in_2), .zero_o(), .neg_o());

    //Second Stage
    //stage2_in_1 is the op1_i from earlier
    reg_rst pipe2_1 (.clk(clk), .rst(rst), .in_i(stage2_in_1), .out_o(stage2_out_1));
    //stage2_in2 is the output from the adder.
    reg_rst pipe2_2 (.clk(clk), .rst(rst), .in_i(stage2_in_2), .out_o(stage2_out_2));
    
    //Remember, the operation is SUM-op1_i, so the output from the first stage subtracts the first input from the summed output.
    alu subtract (.sel_i(2'b01), .op1_i(stage2_out_2), .op2_i(stage2_out_1),.res_o(stage3_in_1),.zero_o(), .neg_o());

    //Final pipeline
    reg_rst out_(.clk(clk), .rst(rst), .in_i(stage3_in_1), .out_o(stage3_out_1));

    assign reg_o = stage3_out_1;



endmodule: three_stage_pipeline
