`timescale 1ns/1ps

module register_file_tb();
    // Parameters to match the DUT
    localparam int DWIDTH = 32;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk, rst;
    logic [4:0] rs1_i, rs2_i, rd_i;
    logic [DWIDTH-1:0] datawb_i;
    logic regwren_i;
    logic [DWIDTH-1:0] rs1data_o, rs2data_o;

    // Instantiate Register File
    register_file #(
        .DWIDTH(DWIDTH)
    ) rf (
        .clk(clk),
        .rst(rst),

        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .rd_i(rd_i),
        .datawb_i(datawb_i),
        .regwren_i(regwren_i),
        .rs1data_o(rs1data_o),
        .rs2data_o(rs2data_o)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // A local copy of the registers to verify against
    logic [DWIDTH-1:0] expected_memory [32];

    task write_reg(input int unsigned rd, input [DWIDTH-1:0] i_data);
        @(posedge clk);
        rd_i <= rd;
        datawb_i <= i_data;
        regwren_i <= 'b1;
        @(posedge clk);
        regwren_i <= 'b0;

        // Update expected mirror only if not x0 (since x0 is hardwired to 0)
        if (rd != 0)
            expected_memory[rd] = i_data;
    endtask

     // Task to read registers and check
    task check_read(input int unsigned rs1, input int unsigned rs2);
        rs1_i <= rs1;
        rs2_i <= rs2;
        @(posedge clk);
        if (rs1data_o !== expected_memory[rs1])
            $display("ERROR: rs1 mismatch at time %0t. Expected %h, got %h (rs1=%0d)",
                        $time, expected_memory[rs1], rs1data_o, rs1);
        if (rs2data_o !== expected_memory[rs2])
            $display("ERROR: rs2 mismatch at time %0t. Expected %h, got %h (rs2=%0d)",
                        $time, expected_memory[rs2], rs2data_o, rs2);
    endtask

    // Reset task
    task reset_dut();
        rst <= 1;
        rs1_i <= 0;
        rs2_i <= 0;
        rd_i <= 0;
        datawb_i <= 0;
        regwren_i <= 0;
        for (int i = 0; i < 32; i++) expected_memory[i] = 0;
        repeat(2) @(posedge clk);
        rst <= 0;
    endtask

    // Main test sequence
    initial begin
        $display("-------------------------------------------------");
        $display("-------- Starting Register File Testbench -------");
        $display("-------------------------------------------------");

        // Reset the DUT
        reset_dut();

        // Test 1: Write and read back from one register
        $display("Test 1: Write and read back from one register");
        write_reg(1, 32'hDEADBEEF);
        check_read(1, 0); // rs2=0 should always read 0

        // Test 2: Multiple writes
        $display("Test 2: Multiple writes");
        write_reg(2, 32'h12345678);
        write_reg(3, 32'hCAFEBABE);
        write_reg(4, 32'h0000FFFF);
        check_read(2, 3);
        check_read(4, 0);

        // Test 3: Overwrite same register
        $display("Test 3: Overwrite same register");
        write_reg(3, 32'hABABABAB);
        check_read(3, 3);

        // Test 4: Verify x0 is hardwired to zero
        $display("Test 4: Verify x0 is hardwired to zero");
        write_reg(0, 32'hFFFFFFFF); // should have no effect
        check_read(0, 1);

        // Test 5: Randomized write/read
        $display("Test 5: Randomized write/read");
        for (int i = 5; i < 15; i++) begin
            automatic logic [DWIDTH-1:0] rand_val = $urandom;
            write_reg(i, rand_val);
            check_read(i, 0);
        end

        // Final check all registers
        $display("Final check all registers");
        for (int i = 0; i < 32; i++) begin
            rs1_i <= i;
            @(posedge clk);
            if (rs1data_o !== expected_memory[i])
                $display("FINAL ERROR: Register x%0d mismatch. Expected %h, got %h",
                         i, expected_memory[i], rs1data_o);
        end

        $display("-------- Register File Testbench Completed -------");
        $finish;
    end

endmodule
