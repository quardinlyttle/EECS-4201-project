`timescale 1ns/1ps

`include "constants.svh"

module memory_tb ();
    // Parameters to match the DUT
    localparam int AWIDTH = 32;
    localparam int DWIDTH = 32;
    localparam logic [31:0] BASE_ADDR = 32'h01000000;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk, reset;
    logic read_en, write_en;
    logic [AWIDTH-1:0] addr;
    logic [DWIDTH-1:0] data_in, data_out;
    logic [2:0] funct3;

    // Instruction interface (for completeness)
    logic [AWIDTH-1:0] insn_addr;
    logic [DWIDTH-1:0] insn_out;

    // Expected mirror memory (byte-addressable)
    byte expected_mem [`MEM_DEPTH];

    // Instantiate DUT
    memory #(
        .AWIDTH(AWIDTH),
        .DWIDTH(DWIDTH),
        .BASE_ADDR(BASE_ADDR)
    ) mem (
        .clk(clk),
        .rst(reset),

        .addr_i(addr),
        .data_i(data_in),
        .read_en_i(read_en),
        .write_en_i(write_en),
        .funct3_i(funct3),

        .insn_addr_i(insn_addr),
        .insn_o(insn_out),

        .data_o(data_out),
        .data_vld_o()
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // ------------------ Main Test Sequence ------------------
    initial begin
        $display("\n==============================================");
        $display(" Starting Memory Testbench (Byte-Addressable) ");
        $display("==============================================");

        perform_reset();

        // --- Test Case 1: Store / Load Word ---
        $display("\n--- Test 1: Store/Load Word ---");
        write_mem(32'h00000000, 32'hDEADBEEF, SWORD);
        read_and_check(32'h00000000, 32'hDEADBEEF, LWORD);

        // --- Test Case 2: Store / Load Half ---
        $display("\n--- Test 2: Store/Load Half ---");
        write_mem(32'h00000004, 32'h0000ABCD, SHALF);
        read_and_check(32'h00000004, 32'hFFFFABCD, LHALF); // signed
        read_and_check(32'h00000004, 32'h0000ABCD, LHU);   // unsigned

        // --- Test Case 3: Store / Load Byte ---
        $display("\n--- Test 3: Store/Load Byte ---");
        write_mem(32'h00000008, 32'h0000007F, SBYTE);
        read_and_check(32'h00000008, 32'h0000007F, LBYTE); // signed
        read_and_check(32'h00000008, 32'h0000007F, LBU);   // unsigned

        // --- Test Case 4: Back-to-Back Write/Read ---
        $display("\n--- Test 4: Back-to-Back Write/Read ---");
        @(posedge clk);
        addr     <= BASE_ADDR + 32'h00000010;
        data_in  <= 32'h12345678;
        funct3   <= SWORD;
        write_en <= 1;
        read_en  <= 0;
        @(posedge clk);
        write_en <= 0;
        read_en  <= 1;
        funct3   <= LWORD;
        @(posedge clk);
        if (data_out === 32'h12345678)
            $display("Back-to-back test PASSED.");
        else
            $error("Back-to-back test FAILED: Expected %h, Got %h", 32'h12345678, data_out);
        read_en <= 0;

        // --- Test Case 5: Unaligned Store Word (should ignore or be safe) ---
        $display("\n--- Test 5: Unaligned SW ---");
        write_mem(32'h00000002, 32'hFEEDFACE, SWORD); // Unaligned
        // Expect partial or ignored behavior depending on implementation
        read_and_check(32'h00000002, 32'hFEEDFACE, LWORD);

        // --- Test Case 6: Sequential Write / Read ---
        $display("\n--- Test 6: Sequential Write / Read ---");
        for (int i = 0; i < 8; i++) begin
            write_mem(i*4, i * 32'h11111111, SWORD);
        end
        for (int i = 0; i < 8; i++) begin
            read_and_check(i*4, i * 32'h11111111, LWORD);
        end

        $display("\n==============================================");
        $display(" All Memory Tests Completed Successfully ");
        $display("==============================================");
        $finish;
    end

    // ------------------ Tasks ------------------

    // Reset the DUT
    task perform_reset();
        reset = 1;
        read_en = 0;
        write_en = 0;
        addr = '0;
        data_in = '0;
        funct3 = 3'b000;
        for (int i = 0; i < `MEM_DEPTH; i++) expected_mem[i] = 'x;
        repeat (2) @(posedge clk);
        reset = 0;
        @(posedge clk);
        $display("Reset complete.");
    endtask

    // Perform a write
    task write_mem(input int unsigned offset, input [DWIDTH-1:0] i_data, input [2:0] funct3_val);
        @(posedge clk);
        addr <= BASE_ADDR + offset;
        data_in <= i_data;
        funct3 <= funct3_val;
        write_en <= 1;
        read_en <= 0;

        // Update expected memory mirror
        case (funct3_val)
            SBYTE: expected_mem[offset] = i_data[7:0];
            SHALF: begin
                expected_mem[offset]   = i_data[7:0];
                expected_mem[offset+1] = i_data[15:8];
            end
            SWORD: begin
                expected_mem[offset]   = i_data[7:0];
                expected_mem[offset+1] = i_data[15:8];
                expected_mem[offset+2] = i_data[23:16];
                expected_mem[offset+3] = i_data[31:24];
            end
        endcase
        @(posedge clk);
        write_en <= 0;
    endtask

    // Perform a read and check
    task read_and_check(input int unsigned offset, input [DWIDTH-1:0] exp_data, input [2:0] funct3_val);
        @(posedge clk);
        addr <= BASE_ADDR + offset;
        read_en <= 1;
        write_en <= 0;
        funct3 <= funct3_val;
        @(posedge clk);
        if (data_out !== exp_data)
            $error("READ MISMATCH at offset %h (addr %h): Expected %h, Got %h",
                   offset, BASE_ADDR + offset, exp_data, data_out);
        read_en <= 0;
    endtask

endmodule
