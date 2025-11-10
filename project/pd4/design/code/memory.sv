/*
 * -------- REPLACE THIS FILE WITH THE MEMORY MODULE DEVELOPED IN PD1 -----------
 * Module: memory
 *
 * Description: Byte-addressable memory implementation. Supports both read and write.
 *
 * Inputs:
 * 1) clk
 * 2) rst signal
 * 3) AWIDTH address addr_i
 * 4) DWIDTH data to write data_i
 * 5) read enable signal read_en_i
 * 6) write enable signal write_en_i
 *
 * Outputs:
 * 1) DWIDTH data output data_o
 * 2) data out valid signal data_vld_o
 */
`include"constants.svh"
module memory #(
    // parameters
    parameter int AWIDTH = 32,
    parameter int DWIDTH = 32,
    parameter logic [31:0] BASE_ADDR = 32'h01000000
) (
    // Normal Data Inputs
    input logic clk,
    input logic rst,
    input logic [AWIDTH-1:0] addr_i,
    input logic [DWIDTH-1:0] data_i,
    input logic read_en_i,
    input logic write_en_i,
    input logic [6:0]opcode_i,
    input logic [2:0] funct3_i,

    // Instruction Data Inputs
    input logic [AWIDTH-1:0] insn_addr_i,

    // Instruction Data Outputs
    output logic [DWIDTH-1:0] insn_o,

    // Data Outputs
    output logic [DWIDTH-1:0] data_o,
    output logic data_vld_o
);

    localparam integer BYTE_SIZE = 8;

    logic [DWIDTH-1:0] temp_memory [0:`MEM_DEPTH];
    // Byte-addressable memory
    logic [7:0] main_memory [0:`MEM_DEPTH];  // Byte-addressable memory
    logic [AWIDTH-1:0] address;
    assign address = (addr_i < BASE_ADDR) ? addr_i : (addr_i - BASE_ADDR);

    logic [AWIDTH-1:0] insn_address;
    assign insn_address = (insn_addr_i < BASE_ADDR) ? 'h0 : (insn_addr_i - BASE_ADDR);

    `ifndef TESTBENCH
    initial begin
        // Initialize entire main memory to zero
        for (int i = 0; i < `MEM_DEPTH; i++) begin
            main_memory[i] = 8'h00;
        end

        $readmemh(`MEM_PATH, temp_memory);
        // Load data from temp_memory into main_memory
        for (int i = 0; i < `LINE_COUNT; i++) begin
        main_memory[4*i]     = temp_memory[i][7:0];
        main_memory[4*i + 1] = temp_memory[i][15:8];
        main_memory[4*i + 2] = temp_memory[i][23:16];
        main_memory[4*i + 3] = temp_memory[i][31:24];
        end
        $display("IMEMORY: Loaded %0d 32-bit words from %s", `LINE_COUNT, `MEM_PATH);
    end
    `endif

    // ========================= MEMORY WRITE LOGIC =========================
    always_ff @(posedge clk) begin : Write_Mem
        if (write_en_i) begin
        // Check if Address is in range, ignore write if not
        if (address < `MEM_DEPTH - 3) begin

            case(funct3_i)
                SBYTE: main_memory[address] <= data_i[7:0];

                SHALF: begin
                    for (int i = 0; i<2; i++)begin
                        main_memory[address + i] <= data_i[i*BYTE_SIZE +: BYTE_SIZE];
                    end
                end

                SWORD: begin
                    // Loop iterates through 4 input bytes
                    for (int i = 0; i<4; i++) begin
                        main_memory[address + i] <= data_i[i*BYTE_SIZE +: BYTE_SIZE];
                    end
                    /*
                    * What the For-Loop is doing:
                    * main_memory[address]      <= data_i[7:0];
                    * main_memory[address + 1]  <= data_i[15:8];
                    * main_memory[address + 2]  <= data_i[23:16];
                    * main_memory[address + 3]  <= data_i[31:24];
                    */
                end
            endcase
        end
        end
    end

  /* ========================= MEMORY READ LOGIC =========================
   * Read from memory, output zero if not enabled
   */

    logic [DWIDTH-1:0] data;
    always_comb begin
        if(rst) begin
            data_o = 'd0;
            data_vld_o = 1'b0;
        end else if (read_en_i) begin
            data_vld_o = 1'b1;
            data =  {
                        main_memory[address + 3],
                        main_memory[address + 2],
                        main_memory[address + 1],
                        main_memory[address]
                    };
        end else begin
            // Not Enabled Case: If read_en_i is not enabled, the output is all zeros.
            data = '0;
            data_vld_o = 1'b0;
        end

        // Output data from readout according to read mode specified
        if(opcode_i == LOAD)begin
            case(funct3_i)
                // Signed Extended Outputs
                LBYTE:  data_o  = { {24{data[BYTE_SIZE-1]}}, data[BYTE_SIZE-1:0] };
                LHALF:  data_o  = { {16{data[2*BYTE_SIZE-1]}}, data[2*BYTE_SIZE-1:0] };

                // Zero Extended Outputs
                LBU:    data_o  =  { 24'b0, data[BYTE_SIZE-1:0] };
                LHU:    data_o  =  { 16'b0, data[2*BYTE_SIZE-1:0] };

                // Full Word Output
                LWORD:  data_o  = data;
            endcase
        end
        else begin
            data_o = data;
        end
    end

    // Instruction readout
    always_comb begin
        insn_o =  {
                    main_memory[insn_address + 3],
                    main_memory[insn_address + 2],
                    main_memory[insn_address + 1],
                    main_memory[insn_address]
                };
    end

endmodule : memory
