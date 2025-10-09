`timescale 1ns/1ps

module igen_tb();
    // Parameters to match the DUT
    localparam int DWIDTH = 32;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk;
    logic [6:0] opcode_i;
    logic [DWIDTH-1:0] insn_i;
    logic [31:0] imm_o;

    igen #(
        .DWIDTH(DWIDTH)
    ) igen_inst (
        .opcode_i(opcode_i),
        .insn_i(insn_i),
        .imm_o(imm_o)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task check_imm(
        input [6:0] exp_opcode,
        input [31:0] exp_imm
    );
        if (imm_o !== exp_imm)
            $error("Immediate mismatch for opcode %b: expected %0d (0x%h), got %0d (0x%h)",
                   exp_opcode, exp_imm, exp_imm, imm_o, imm_o);
        else
            $display("PASS: opcode=%b imm=0x%h", exp_opcode, imm_o);
    endtask

    initial begin
        // I-type: ADDI x1, x2, 0x00A
        $display("Test 1 - I-type: ADDI x1, x2, 0x00A");
        insn_i   = 32'b0000000001010_00010_000_00001_0010011;
        opcode_i = 7'b0010011;
        #1;
        check_imm(opcode_i, 32'd10);

        // S-type: SW x5, 8(x6)
        // imm[11:5] = 0000000, imm[4:0] = 01000 -> 8
        $display("Test 2 - I-type: ADDI x1, x2, 0x00A");
        insn_i   = 32'b0000000_00101_00110_010_01000_0100011;
        opcode_i = 7'b0100011;
        #1;
        check_imm(opcode_i, 32'd8);

        // B-type: BEQ x1, x2, 16
        // imm = {imm[12], imm[10:5], imm[4:1], imm[11]} = 000000010000 -> 16
        $display("Test 3 - B-type: BEQ x1, x2, 16");
        insn_i   = 32'b000000_00010_00001_000_00100_1100011;
        opcode_i = 7'b1100011;
        #1;
        check_imm(opcode_i, 32'd16);

        // U-type: LUI x10, 0x12345
        // imm = upper 20 bits << 12
        $display("Test 4 - U-type: LUI x10, 0x12345");
        insn_i   = 32'b00010010001101000101_01010_0110111;
        opcode_i = 7'b0110111;
        #1;
        check_imm(opcode_i, 32'h12345000);

        // J-type: JAL x1, offset 0x10
        // imm = {imm[20], imm[10:1], imm[11], imm[19:12]} = 16
        $display("Test 5 - J-type: JAL x1, offset 0x10");
        insn_i   = 32'b000000000001_00000000_0000_1_1101111;
        opcode_i = 7'b1101111;
        #1;
        check_imm(opcode_i, 32'd16);

        // Negative immediate test: ADDI x1, x2, -4
        $display("Test 6 - Negative immediate test: ADDI x1, x2, -4");
        insn_i   = 32'b111111111100_00010_000_00001_0010011; // imm = 0xFFC = -4
        opcode_i = 7'b0010011;
        #1;
        check_imm(opcode_i, 32'hFFFFFFFC);

        $display("All immediate tests completed.");
        $finish;
    end

endmodule
