`timescale 1ns/1ps

module control_tb();
    // Parameters to match the DUT
    localparam int DWIDTH = 32;
    localparam int CLK_PERIOD = 20; // 50 MHz clock

    // Testbench signals
    logic clk;

    logic [DWIDTH-1:0] insn_i;
    logic [6:0] opcode_i, funct7_i;
    logic [2:0] funct3_i;

    logic pcsel_o;
    logic immsel_o;
    logic regwren_o;
    logic rs1sel_o;
    logic rs2sel_o;
    logic memren_o;
    logic memwren_o;
    logic [1:0] wbsel_o;
    logic [3:0] alusel_o;

    control #(
        .DWIDTH(DWIDTH)
    ) control_inst (
        .insn_i(insn_i),
        .opcode_i(opcode_i),
        .funct3_i(funct3_i),
        .funct7_i(funct7_i),

        .pcsel_o(pcsel_o),
        .immsel_o(immsel_o),
        .regwren_o(regwren_o),
        .rs1sel_o(rs1sel_o),
        .rs2sel_o(rs2sel_o),
        .memren_o(memren_o),
        .memwren_o(memwren_o),
        .wbsel_o(wbsel_o),
        .alusel_o(alusel_o)
    );

    // Clock generator
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    task check_ctrl(
        input [6:0] exp_opcode,
        input exp_pcsel,
        input exp_immsel,
        input exp_regwren,
        input exp_rs1sel,
        input exp_rs2sel,
        input exp_memren,
        input exp_memwren,
        input [1:0] exp_wbsel,
        input [3:0] exp_alusel
    );
        if (pcsel_o    !== exp_pcsel)    $error("pcsel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_pcsel, pcsel_o);
        if (immsel_o   !== exp_immsel)   $error("immsel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_immsel, immsel_o);
        if (regwren_o  !== exp_regwren)  $error("regwren mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_regwren, regwren_o);
        if (rs1sel_o   !== exp_rs1sel)   $error("rs1sel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_rs1sel, rs1sel_o);
        if (rs2sel_o   !== exp_rs2sel)   $error("rs2sel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_rs2sel, rs2sel_o);
        if (memren_o   !== exp_memren)   $error("memren mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_memren, memren_o);
        if (memwren_o  !== exp_memwren)  $error("memwren mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_memwren, memwren_o);
        if (wbsel_o    !== exp_wbsel)    $error("wbsel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_wbsel, wbsel_o);
        if (alusel_o   !== exp_alusel)   $error("alusel mismatch for opcode %b: exp=%b got=%b", exp_opcode, exp_alusel, alusel_o);
        else
            $display("PASS: opcode=%b control outputs OK", exp_opcode);
    endtask

    initial begin
        // --- R-type: ADD (opcode 0110011)
        $display("Test 1 - R-type: ADD (opcode 0110011)");
        opcode_i = 7'b0110011;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd2, 5'd1, funct3_i, 5'd3, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   0,  // pcsel: sequential
                   0,  // immsel: no immediate
                   1,  // regwren: yes
                   0,  // rs1sel: regfile
                   0,  // rs2sel: regfile
                   0,  // memren
                   0,  // memwren
                   2'b00, // wbsel: ALU result
                   4'b0000 // alusel: ADD
        );

        // --- I-type: ADDI (opcode 0010011)
        $display("Test 2 - I-type: ADDI (opcode 0010011)");
        opcode_i = 7'b0010011;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd2, 5'd1, funct3_i, 5'd3, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   0,  // pcsel
                   1,  // immsel: immediate
                   1,  // regwren
                   0,  // rs1sel
                   1,  // rs2sel: immediate
                   0,  // memren
                   0,  // memwren
                   2'b00, // wbsel: ALU result
                   4'b0000 // alusel: ADD
        );

        // --- S-type: SW (opcode 0100011)
        $display("Test 3 - S-type: SW (opcode 0100011)");
        opcode_i = 7'b0100011;
        funct3_i = 3'b010;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd2, 5'd1, funct3_i, 5'd3, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   0,  // pcsel
                   1,  // immsel
                   0,  // regwren
                   0,  // rs1sel
                   0,  // rs2sel
                   0,  // memren
                   1,  // memwren
                   2'b00, // wbsel unused
                   4'b0000 // alusel ADD (for address)
        );

        // --- B-type: BEQ (opcode 1100011)
        $display("Test 4 - B-type: BEQ (opcode 1100011)");
        opcode_i = 7'b1100011;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd2, 5'd1, funct3_i, 5'd3, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   1,  // pcsel: branch decision
                   1,  // immsel: branch offset
                   0,  // regwren
                   0,  // rs1sel
                   0,  // rs2sel
                   0,  // memren
                   0,  // memwren
                   2'b00,
                   4'b0001 // alusel: SUB (for comparison)
        );

        // --- L-type: LW (opcode 0000011)
        $display("Test 5 - L-type: LW (opcode 0000011)");
        opcode_i = 7'b0000011;
        funct3_i = 3'b010;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd2, 5'd1, funct3_i, 5'd3, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   0,  // pcsel
                   1,  // immsel
                   1,  // regwren
                   0,  // rs1sel
                   1,  // rs2sel
                   1,  // memren
                   0,  // memwren
                   2'b01, // wbsel: memory data
                   4'b0000 // alusel ADD (for address)
        );

        // --- U-type: LUI (opcode 0110111)
        $display("Test 6 - U-type: LUI (opcode 0110111)");
        opcode_i = 7'b0110111;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd0, 5'd0, funct3_i, 5'd1, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   0,  // pcsel
                   1,  // immsel
                   1,  // regwren
                   0,  // rs1sel
                   1,  // rs2sel (imm)
                   0,  // memren
                   0,  // memwren
                   2'b00, // wbsel ALU
                   4'b0010 // alusel PASS IMM
        );

        // --- J-type: JAL (opcode 1101111)
        $display("Test 7 - J-type: JAL (opcode 1101111))");
        opcode_i = 7'b1101111;
        funct3_i = 3'b000;
        funct7_i = 7'b0000000;
        insn_i = {funct7_i, 5'd0, 5'd0, funct3_i, 5'd1, opcode_i};
        #1;
        check_ctrl(opcode_i,
                   1,  // pcsel: jump
                   1,  // immsel
                   1,  // regwren: write return addr
                   0,  // rs1sel
                   0,  // rs2sel
                   0,  // memren
                   0,  // memwren
                   2'b10, // wbsel: PC+4
                   4'b0011 // alusel: PC increment
        );

        $display("All control logic tests completed.");
        $finish;
    end

endmodule
