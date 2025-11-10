`timescale 1ns/1ps
`include "constants.svh"

module writeback_tb;
    // ==========================================================
    // Parameters
    // ==========================================================
    localparam int AWIDTH = 32;
    localparam int DWIDTH = 32;

    // ==========================================================
    // Testbench Signals
    // ==========================================================
    logic [AWIDTH-1:0] pc_i;
    logic [DWIDTH-1:0] alu_res_i;
    logic [DWIDTH-1:0] memory_data_i;
    logic [1:0]        wbsel_i;
    logic              brtaken_i;
    logic [DWIDTH-1:0] writeback_data_o;
    logic [AWIDTH-1:0] next_pc_o;

    // ==========================================================
    // Instantiate DUT
    // ==========================================================
    writeback #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH)
    ) dut (
        .pc_i(pc_i),
        .alu_res_i(alu_res_i),
        .memory_data_i(memory_data_i),
        .wbsel_i(wbsel_i),
        .brtaken_i(brtaken_i),
        .writeback_data_o(writeback_data_o),
        .next_pc_o(next_pc_o)
    );

    // ==========================================================
    // Main Test Sequence
    // ==========================================================
    initial begin
        $display("===============================================");
        $display("         Starting WRITEBACK Testbench          ");
        $display("===============================================");

        // Initialize inputs
        pc_i          = 32'h01000000;
        alu_res_i     = 32'hDEADBEEF;
        memory_data_i = 32'hCAFEBABE;
        brtaken_i     = 0;
        wbsel_i       = 0;
        #5;

        // ---------------- Test Case 1: wbALU ----------------
        $display("\n--- Test Case 1: wbALU ---");
        wbsel_i = wbALU;
        brtaken_i = 0;
        #1;
        check_outputs(alu_res_i, pc_i + 4);

        // ---------------- Test Case 2: wbMEM ----------------
        $display("\n--- Test Case 2: wbMEM ---");
        wbsel_i = wbMEM;
        #1;
        check_outputs(memory_data_i, pc_i + 4);

        // ---------------- Test Case 3: wbPC ----------------
        $display("\n--- Test Case 3: wbPC ---");
        wbsel_i = wbPC;
        #1;
        check_outputs(pc_i, pc_i + 4);

        // ---------------- Test Case 4: wbJAL ----------------
        $display("\n--- Test Case 4: wbJAL ---");
        wbsel_i = wbJAL;
        #1;
        check_outputs(pc_i + 4, alu_res_i);  // next_pc_o = alu_res_i for wbJAL

        // ---------------- Test Case 5: Branch Taken ----------------
        $display("\n--- Test Case 5: Branch Taken (wbALU) ---");
        wbsel_i = wbALU;
        brtaken_i = 1;
        #1;
        check_outputs(alu_res_i, alu_res_i); // When branch taken, next_pc_o = alu_res_i

        $display("\n===============================================");
        $display("        All WRITEBACK Tests Completed!");
        $display("===============================================");
        $finish;
    end

    // ==========================================================
    // Task: Output Checker
    // ==========================================================
    task check_outputs(input logic [DWIDTH-1:0] exp_write_data, input logic [AWIDTH-1:0] exp_next_pc);
        if (writeback_data_o !== exp_write_data)
            $error("WRITEBACK DATA MISMATCH: Expected %h, Got %h", exp_write_data, writeback_data_o);
        else
            $display("Writeback data correct: %h", writeback_data_o);

        if (next_pc_o !== exp_next_pc)
            $error("NEXT PC MISMATCH: Expected %h, Got %h", exp_next_pc, next_pc_o);
        else
            $display("Next PC correct: %h", next_pc_o);
    endtask

endmodule
