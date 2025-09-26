`timescale 1ns/1ps

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

    // A local copy of the memory to verify against, sized by the `define
    logic [DWIDTH-1:0] expected_memory [`MEM_DEPTH];

    // Instantiate the Device Under Test (DUT)
    // Assumes your memory module is named 'memory'
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

        .data_o(data_out)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Main test sequence
    initial begin
        $display("-------------------------------------------------");
        $display("--- Starting Memory Testbench (with BASE_ADDR) ---");
        $display("--- BASE_ADDR = %h, MEM_DEPTH = %d ---", BASE_ADDR, `MEM_DEPTH);
        $display("-------------------------------------------------");

        // 1. Reset the DUT
        perform_reset();

        // --- Test Case 1: Basic Write then Read ---
        $display("\n--- Test Case 1: Basic Write then Read ---");
        write_mem('hA5, 32'hDEADBEEF);
        read_and_check('hA5, 32'hDEADBEEF);

        // --- Test Case 2: Sequential Write, Sequential Read ---
        $display("\n--- Test Case 2: Sequential Write / Read ---");
        for (int i = 0; i < 16; i++) begin
            write_mem(i*4, i * 4);
        end
        for (int i = 0; i < 16; i++) begin
            read_and_check(i*4, i * 4);
        end

        // --- Test Case 3: Random Write and Read ---
        $display("\n--- Test Case 3: Random Write / Read ---");
        for (int i = 0; i < 64; i++) begin // Perform 64 random writes
            int unsigned random_offset;
            logic [DWIDTH-1:0] random_data;
            random_offset = $urandom_range(0, `MEM_DEPTH-1);
            random_data = $urandom();
            write_mem(random_offset, random_data);
        end
        // Now read back all written values and check
        for (int i = 0; i < `MEM_DEPTH; i++) begin
            if (expected_memory[i] !== 'x) begin // Check only initialized locations
                read_and_check(i, expected_memory[i]);
            end
        end

        // --- Test Case 4: Back-to-Back Write then Read ---
        $display("\n--- Test Case 4: Back-to-Back Write/Read (Same Address) ---");
        @(posedge clk);
        addr <= BASE_ADDR + 'hF0;
        data_in <= 32'h12345678;
        write_en <= 1;
        read_en <= 0;
        @(posedge clk);
        // On the very next cycle, switch to read
        write_en <= 0;
        read_en <= 1;
        // Assuming 1-cycle read latency, data will be valid on the next edge
        @(posedge clk);
        if (data_out === 32'h12345678) begin
            $display("Back-to-back test PASSED.");
        end else begin
            $error("Back-to-back test FAILED. Expected %h, got %h", 32'h12345678, data_out);
        end
        read_en <= 0;

        // --- Test Case 5: Address Boundary Check ---
        $display("\n--- Test Case 5: Address Boundary Check ---");
        write_mem(0, 32'hCAFEF00D);                   // First address
        write_mem(`MEM_DEPTH-1, 32'hBEEFFACE); // Last address
        read_and_check(0, 32'hCAFEF00D);
        read_and_check(`MEM_DEPTH-1, 32'hBEEFFACE);

        // --- Test Case 6: Simultaneous Read/Write Enable ---
        $display("\n--- Test Case 6: Simultaneous Read/Write Enable ---");
        // We assume write takes priority
        write_mem('hCC, 32'hFEEDF00D); // Pre-load a value
        @(posedge clk);
        addr <= BASE_ADDR + 'hCC;
        data_in <= 32'hABADBABE;      // New data to write
        write_en <= 1;
        read_en <= 1;                 // Assert both
        @(posedge clk);
        write_en <= 0;
        read_en <= 0;
        read_and_check('hCC, 32'hABADBABE); // Check if the NEW data was written

        // --- Test Case 7: Read from Uninitialized Address ---
        $display("\n--- Test Case 7: Uninitialized Read ---");
        @(posedge clk);
        addr <= BASE_ADDR + 'hEE; // An offset we have not written to
        read_en <= 1;
        @(posedge clk); // Wait for read latency
        if ($isunknown(data_out)) begin
             $display("Uninitialized read test PASSED. Got expected X's.");
        end else begin
             $error("Uninitialized read test FAILED. Expected X's, got %h", data_out);
        end
        @(posedge clk);
        read_en <= 0;

        $display("\n-------------------------------------------------");
        $display("--- All Tests Completed Successfully! ---");
        $display("-------------------------------------------------");
        $finish;
    end

    // Task to reset the DUT and initialize signals
    task perform_reset();
        reset = 1;
        read_en = 0;
        write_en = 0;
        addr = 'x;
        data_in = 'x;
        // Initialize the mirror memory to all X's
        for (int i = 0; i < `MEM_DEPTH; i++) begin
            expected_memory[i] = 'x;
        end
        repeat(2) @(posedge clk);
        reset = 0;
        @(posedge clk);
        $display("Reset complete.");
    endtask

    // Task to perform a memory write using a memory offset
    task write_mem(input int unsigned offset, input [DWIDTH-1:0] i_data);
        @(posedge clk);
        addr <= BASE_ADDR + offset; // Drive the full system address
        data_in <= i_data;
        write_en <= 1;
        read_en <= 0;
        // Update our local mirror using the offset as the index
        expected_memory[offset] = i_data;
        @(posedge clk);
        write_en <= 0;
    endtask

    // Task to perform a memory read and check the result using a memory offset
    task read_and_check(input int unsigned offset, input [DWIDTH-1:0] exp_data);
        @(posedge clk);
        addr <= BASE_ADDR + offset; // Drive the full system address
        read_en <= 1;
        write_en <= 0;
        @(posedge clk);
        if (data_out !== exp_data) begin
            $error("READ MISMATCH at offset %h (addr %h): Expected %h, Got %h", offset, BASE_ADDR + offset, exp_data, data_out);
        end
        read_en <= 0;
    endtask

endmodule
