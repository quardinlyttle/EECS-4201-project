`timescale 1ns/1ps
`include "constants.svh"

module execute_tb;

    // Parameters
    localparam int DWIDTH = 32;
    localparam int AWIDTH = 32;

    // DUT signals
    logic [AWIDTH-1:0] pc_i;
    logic [DWIDTH-1:0] rs1_i, rs2_i;
    logic [6:0] opcode_i, funct7_i;
    logic [2:0] funct3_i;
    logic [3:0] alusel_i;
    logic [DWIDTH-1:0] res_o;
    logic brtaken_o;

    // Instantiate DUT
    alu dut (
        .pc_i(pc_i),
        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .opcode_i(opcode_i),
        .funct3_i(funct3_i),
        .funct7_i(funct7_i),
        .alusel_i(alusel_i),
        .res_o(res_o),
        .brtaken_o(brtaken_o)
    );

    // Stimulus
    initial begin
        $display("Starting ALU Testbench...");

        // Initialize
        pc_i = 32'd100;
        opcode_i = 7'b0000000;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;

        // === ADD Test ===
        alusel_i = ADD;
        rs1_i = 32'd10;
        rs2_i = 32'd20;
        #1;
        if (res_o !== 32'd30)
            $error("ADD failed: got %0d, expected 30", res_o);

        // === SUB Test ===
        alusel_i = SUB;
        rs1_i = 32'd20;
        rs2_i = 32'd10;
        #1;
        if (res_o !== 32'd10)
            $error("SUB failed: got %0d, expected 10", res_o);

        // === XOR Test ===
        alusel_i = XOR;
        rs1_i = 32'hFFFF0000;
        rs2_i = 32'h0F0F0F0F;
        #1;
        if (res_o !== (32'hFFFF0000 ^ 32'h0F0F0F0F))
            $error("XOR failed: got %h", res_o);

        // === SLT signed ===
        alusel_i = SLT;
        rs1_i = -5;
        rs2_i = 3;
        #1;
        if (res_o !== 1)
            $error("SLT failed: expected 1");

        // === SLTU unsigned ===
        alusel_i = SLTU;
        rs1_i = -5;  // 0xFFFFFFFB
        rs2_i = 3;
        #1;
        if (res_o !== 0)
            $error("SLTU failed: expected 0");

        // === PCADD test ===
        alusel_i = PCADD;
        rs2_i = 32'd4;
        #1;
        if (res_o !== (pc_i + 4))
            $error("PCADD failed: expected %0d", pc_i + 4);

        // === Branch test (integration) ===
        opcode_i = BRANCH;
        funct3_i = 3'b000; // BEQ
        rs1_i = 32'd5;
        rs2_i = 32'd5;
        #1;
        if (brtaken_o !== 1)
            $error("BEQ branch failed");

        funct3_i = 3'b001; // BNE
        rs1_i = 32'd5;
        rs2_i = 32'd10;
        #1;
        if (brtaken_o !== 1)
            $error("BNE branch failed");

        $display("All ALU tests completed.");
        $finish;
    end

endmodule
