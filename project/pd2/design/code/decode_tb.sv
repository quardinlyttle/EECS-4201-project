`timescale 1ns/1ps

module decode_tb();
    // Parameters to match the DUT
    localparam int AWIDTH = 32;
    localparam int DWIDTH = 32;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk, rst;
    logic [DWIDTH-1:0] insn_i;
    logic [AWIDTH-1:0] pc_i;
    logic [DWIDTH-1:0] insn_o, imm_o;
    logic [AWIDTH-1:0] pc_o;
    logic [6:0] opcode_o, funct7_o;
    logic [4:0] rd_o, rs1_o, rs2_o, shamt_o;
    logic [2:0] funct3_o;

    decode #(
        .DWIDTH(DWIDTH),
        .AWIDTH(AWIDTH)
    ) decode_inst (
        .clk(clk),
        .rst(rst),

        .insn_i(insn_i),
        .pc_i(pc_i),

        .pc_o(pc_o),
        .insn_o(insn_o),
        .opcode_o(opcode_o),
        .rd_o(rd_o),
        .rs1_o(rs1_o),
        .rs2_o(rs2_o),
        .funct7_o(funct7_o),
        .funct3_o(funct3_o),
        .shamt_o(shamt_o),
        .imm_o(imm_o)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task check_fields(
        input [31:0] exp_opcode,
        input [4:0] exp_rd,
        input [4:0] exp_rs1,
        input [4:0] exp_rs2,
        input [2:0] exp_funct3,
        input [6:0] exp_funct7,
        input [31:0] exp_imm
    );
        if (opcode_o !== exp_opcode) $error("Opcode mismatch: expected %b, got %b", exp_opcode, opcode_o);
        if (rd_o     !== exp_rd)     $error("RD mismatch: expected %0d, got %0d", exp_rd, rd_o);
        if (rs1_o    !== exp_rs1)    $error("RS1 mismatch: expected %0d, got %0d", exp_rs1, rs1_o);
        if (rs2_o    !== exp_rs2)    $error("RS2 mismatch: expected %0d, got %0d", exp_rs2, rs2_o);
        if (funct3_o !== exp_funct3) $error("funct3 mismatch: expected %b, got %b", exp_funct3, funct3_o);
        if (funct7_o !== exp_funct7) $error("funct7 mismatch: expected %b, got %b", exp_funct7, funct7_o);
    endtask

    initial begin
        rst = 1;
        insn_i = 0;
        pc_i = 0;
        @(posedge clk);
        rst = 0;

        // R-type: ADD x1, x2, x3
        $display("Test 1 - R-type: ADD x1, x2, x3");
        insn_i = 32'b0000000_00011_00010_000_00001_0110011;
        pc_i = 32'h0;
        @(posedge clk);
        @(posedge clk); // Wait one cycle if sequential
        check_fields(7'b0110011, 5'd1, 5'd2, 5'd3, 3'b000, 7'b0000000, 32'd0);

        // I-type: ADDI x5, x6, 10
        $display("Test 2 - I-type: ADDI x5, x6, 10");
        insn_i = 32'b0000000001010_00110_000_00101_0010011;
        pc_i = 32'h4;
        @(posedge clk);
        @(posedge clk);
        check_fields(7'b0010011, 5'd5, 5'd6, 5'd0, 3'b000, 7'b0000000, 32'd10);

        // S-type: SW x7, 8(x8)
        $display("Test 3 - S-type: SW x7, 8(x8)");
        insn_i = 32'b0000000_00111_01000_010_01000_0100011;
        pc_i = 32'h8;
        @(posedge clk);
        @(posedge clk);
        check_fields(7'b0100011, 5'd0, 5'd8, 5'd7, 3'b010, 7'b0000000, 32'd8);

        // B-type: BEQ x1, x2, 16
        $display("Test 3 - B-type: BEQ x1, x2, 16");
        insn_i = 32'b000000_00010_00001_000_00100_1100011;
        pc_i = 32'hC;
        @(posedge clk);
        @(posedge clk);
        check_fields(7'b1100011, 5'd0, 5'd1, 5'd2, 3'b000, 7'b0000000, 32'd16);

        // U-type: LUI x10, 0x12345
        $display("Test 4 - U-type: LUI x10, 0x12345");
        insn_i = 32'b00010010001101000101_01010_0110111;
        pc_i = 32'h10;
        @(posedge clk);
        @(posedge clk);
        check_fields(7'b0110111, 5'd10, 5'd0, 5'd0, 3'b000, 7'b0000000, 32'h12345000);

        // J-type: JAL x1, 0x10
        $display("Test 5 - J-type: JAL x1, 0x10");
        insn_i = 32'b000000000001_00000000_0000_1_1101111;
        pc_i = 32'h14;
        @(posedge clk);
        @(posedge clk);
        check_fields(7'b1101111, 5'd1, 5'd0, 5'd0, 3'b000, 7'b0000000, 32'd16);

        $display("All tests completed.");
        $finish;
    end

endmodule
