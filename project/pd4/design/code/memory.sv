/*
 * Module: memory
 *
 * Description: Byte-addressable memory implementation with wrap-around addressing.
 * Supports both instruction and data access (read/write).
 *
 * Inputs:
 *  - clk, rst
 *  - addr_i, data_i, read_en_i, write_en_i, opcode_i, funct3_i
 *  - insn_addr_i (for instruction fetch)
 *
 * Outputs:
 *  - insn_o (instruction word)
 *  - data_o (read data)
 *  - data_vld_o (read valid flag)
 */

`include "constants.svh"
module memory #(
    // Parameters
    parameter int AWIDTH = 32,
    parameter int DWIDTH = 32,
    parameter logic [31:0] BASE_ADDR = 32'h01000000
)(
    // Normal Data Inputs
    input  logic clk,
    input  logic rst,
    input  logic [AWIDTH-1:0] addr_i,
    input  logic [DWIDTH-1:0] data_i,
    input  logic read_en_i,
    input  logic write_en_i,
    input  logic [6:0] opcode_i,
    input  logic [2:0] funct3_i,

    // Instruction Data Inputs
    input  logic [AWIDTH-1:0] insn_addr_i,

    // Instruction Data Outputs
    output logic [DWIDTH-1:0] insn_o,

    // Data Outputs
    output logic [DWIDTH-1:0] data_o,
    output logic data_vld_o
);

    localparam integer BYTE_SIZE = 8;

    // Main memory
    logic [DWIDTH-1:0] temp_memory [0:`MEM_DEPTH];
    logic [7:0] main_memory [0:`MEM_DEPTH];  // Byte-addressable

    // ============================================================
    // Address wrapping logic
    // ============================================================
    // Ensure all addresses map inside [0, MEM_DEPTH)
    logic [AWIDTH-1:0] address;
    logic [AWIDTH-1:0] insn_address;

    assign address = ((addr_i >= BASE_ADDR) ? (addr_i - BASE_ADDR) : addr_i) % `MEM_DEPTH;
    assign insn_address = ((insn_addr_i >= BASE_ADDR) ? (insn_addr_i - BASE_ADDR) : insn_addr_i) % `MEM_DEPTH;

    // ============================================================
    // Memory initialization
    // ============================================================
    `ifndef TESTBENCH
    initial begin
        // Initialize main memory to zero
        for (int i = 0; i < `MEM_DEPTH; i++) begin
            main_memory[i] = 8'h00;
        end

        // Load memory content
        $readmemh(`MEM_PATH, temp_memory);
        for (int i = 0; i < `LINE_COUNT; i++) begin
            main_memory[4*i]     = temp_memory[i][7:0];
            main_memory[4*i + 1] = temp_memory[i][15:8];
            main_memory[4*i + 2] = temp_memory[i][23:16];
            main_memory[4*i + 3] = temp_memory[i][31:24];
        end

        $display("IMEMORY: Loaded %0d 32-bit words from %s", `LINE_COUNT, `MEM_PATH);
    end
    `endif

    // ============================================================
    // WRITE LOGIC
    // ============================================================
    always_ff @(posedge clk) begin : Write_Mem
        if (write_en_i) begin
            case (funct3_i)
                SBYTE: main_memory[address] <= data_i[7:0];

                SHALF: for (int i = 0; i < 2; i++)
                    main_memory[(address + i) % `MEM_DEPTH] <= data_i[i*BYTE_SIZE +: BYTE_SIZE];

                SWORD: for (int i = 0; i < 4; i++)
                    main_memory[(address + i) % `MEM_DEPTH] <= data_i[i*BYTE_SIZE +: BYTE_SIZE];
            endcase
        end
    end

    // ============================================================
    // READ LOGIC (data path)
    // ============================================================
    logic [DWIDTH-1:0] data;

    always_comb begin
        if (rst) begin
            data_o = '0;
            data_vld_o = 1'b0;
        end
        else if (read_en_i) begin
            data_vld_o = 1'b1;
            data = {
                main_memory[(address + 3) % `MEM_DEPTH],
                main_memory[(address + 2) % `MEM_DEPTH],
                main_memory[(address + 1) % `MEM_DEPTH],
                main_memory[(address + 0) % `MEM_DEPTH]
            };
        end
        else begin
            data = '0;
            data_vld_o = 1'b0;
        end

        // Load-type decoding
        if (opcode_i == LOAD) begin
            case (funct3_i)
                // Sign-extended
                LBYTE: data_o = { {24{data[7]}},  data[7:0] };
                LHALF: data_o = { {16{data[15]}}, data[15:0] };

                // Zero-extended
                LBU: data_o = { 24'b0, data[7:0] };
                LHU: data_o = { 16'b0, data[15:0] };

                // Full word
                LWORD: data_o = data;
            endcase
        end else begin
            data_o = data;
        end
    end

    // ============================================================
    // INSTRUCTION FETCH
    // ============================================================
    always_comb begin
        insn_o = {
            main_memory[(insn_address + 3) % `MEM_DEPTH],
            main_memory[(insn_address + 2) % `MEM_DEPTH],
            main_memory[(insn_address + 1) % `MEM_DEPTH],
            main_memory[(insn_address + 0) % `MEM_DEPTH]
        };
    end

endmodule : memory
