`timescale 1ns/1ps

module branch_control_tb();
    // Parameters to match the DUT
    localparam int DWIDTH = 32;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk, rst;
    logic [DWIDTH-1:0] rs1_i, rs2_i;
    logic [6:0] opcode_i;
    logic [2:0] funct3_i;
    logic breq_o, brlt_o;

    // Combinational Branch Control
    branch_control #(
        .DWIDTH(DWIDTH)
    ) bc_i (
        .opcode_i(opcode_i),
        .funct3_i(funct3_i),
        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .breq_o(breq_o),
        .brlt_o(brlt_o)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Reset task
    task reset_dut();
        rst <= 1;
        opcode_i <= 0;
        funct3_i <= 0;
        rs1_i <= 0;
        rs2_i <= 0;
        @(posedge clk);
        rst <= 0;
    endtask

    // Task: Apply a branch test case
    task branch_test(
        input [6:0] opcode,
        input [2:0] funct3,
        input [DWIDTH-1:0] rs1_val,
        input [DWIDTH-1:0] rs2_val,
        input logic exp_breq,
        input logic exp_brlt,
        input string testname
    );
        opcode_i <= opcode;
        funct3_i <= funct3;
        rs1_i <= rs1_val;
        rs2_i <= rs2_val;
        @(posedge clk);

        if (breq_o !== exp_breq || brlt_o !== exp_brlt)
            $display("ERROR in %s @ time %0t: rs1=%h rs2=%h funct3=%0b | breq_o=%0b (exp %0b), brlt_o=%0b (exp %0b)",
                      testname, $time, rs1_val, rs2_val, funct3,
                      breq_o, exp_breq, brlt_o, exp_brlt);
        else
            $display("PASS: %s @ time %0t", testname, $time);
    endtask

    localparam [6:0] OPCODE_BRANCH = 7'b1100011;

    // Main test sequence
    initial begin
        $display("-------------------------------------------------");
        $display("-------- Starting Branch Control Testbench -------");
        $display("-------------------------------------------------");

        reset_dut();

        // Test 1: BEQ (equal)
        branch_test(OPCODE_BRANCH, 3'b000, 32'hA5A5A5A5, 32'hA5A5A5A5, 1, 0, "BEQ equal");
        branch_test(OPCODE_BRANCH, 3'b000, 32'h11111111, 32'h22222222, 0, 0, "BEQ not equal");

        // Test 2: BNE (not equal)
        branch_test(OPCODE_BRANCH, 3'b001, 32'h12345678, 32'h87654321, 0, 0, "BNE not equal");
        branch_test(OPCODE_BRANCH, 3'b001, 32'hFACEFACE, 32'hFACEFACE, 1, 0, "BNE equal (should not branch)");

        // Test 3: BLT (signed)
        branch_test(OPCODE_BRANCH, 3'b100, 32'shFFFFFFFF, 32'sh00000001, 0, 1, "BLT rs1 < rs2 (signed)");
        branch_test(OPCODE_BRANCH, 3'b100, 32'sh00000002, 32'shFFFFFFFE, 0, 0, "BLT rs1 > rs2 (signed)");

        // Test 4: BGE (signed)
        branch_test(OPCODE_BRANCH, 3'b101, 32'sh00000005, 32'shFFFFFFFE, 0, 0, "BGE rs1 >= rs2 (signed)");
        branch_test(OPCODE_BRANCH, 3'b101, 32'shFFFFFFFE, 32'sh00000001, 0, 1, "BGE rs1 < rs2 (signed)");

        // Test 5: BLTU (unsigned)
        branch_test(OPCODE_BRANCH, 3'b110, 32'h00000001, 32'hFFFFFFFF, 0, 1, "BLTU unsigned less than");
        branch_test(OPCODE_BRANCH, 3'b110, 32'hFFFFFFFF, 32'h00000001, 0, 0, "BLTU unsigned greater than");

        // Test 6: BGEU (unsigned)
        branch_test(OPCODE_BRANCH, 3'b111, 32'hFFFFFFFF, 32'h00000001, 0, 0, "BGEU unsigned greater/equal");
        branch_test(OPCODE_BRANCH, 3'b111, 32'h00000001, 32'hFFFFFFFF, 0, 1, "BGEU unsigned less than");

        $display("-------- Branch Control Testbench Completed -------");
        $finish;
    end

endmodule
