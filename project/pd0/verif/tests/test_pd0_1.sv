/*
 * Module: top
 *
 * Description: Testbench that drives the probes and displays the signal changes
 */
`include "probes.svh"

module top1;
 logic clock;
 logic reset;

 clockgen clkg(
     .clk(clock),
     .rst(reset)
 );

 design_wrapper dut(
     .clk(clock),
     .reset(reset)
 );

 integer counter = 0;
 integer errors = 0;


 always_ff @(posedge clock) begin
    counter <= counter + 1;
    if(counter == 100) begin
        $display("[PD0] No error encountered");
        $finish;
    end
 end

 initial begin
    $monitor(" clk = %0b", clock);
 end

 always_ff @(negedge clock) begin
    $display("###########");
 end

 logic       reset_done;
 logic       reset_neg;
 logic       reset_reg;
 integer     reset_counter;
 always_ff @(posedge clock) begin
   if(reset) reset_counter <= 0;
   else      reset_counter <= reset_counter + 1;
   // detect negedge
   reset_reg <= reset;
   if(reset_reg && !reset) reset_neg <= 1;
   // delay for some cycles
   if(reset_neg && reset_counter >= 3) begin
     reset_done <= 1;
   end
 end

`ifdef PROBE_ALU_OP1 `ifdef PROBE_ALU_OP2 `ifdef PROBE_ALU_SEL `ifdef PROBE_ALU_RES `ifdef PROBE_ALU_NFLAG `ifdef PROBE_ALU_ZFLAG
    `define PROBE_ALU_OK
`endif  `endif `endif `endif
`ifdef PROBE_ALU_OK
 // alu
 logic [1:0] alu_sel;
 logic [31:0] alu_op1;
 logic [31:0] alu_op2;
 logic [31:0] alu_res;
 logic alu_nflag, alu_zflag;

 integer alu_counter = 0;
 always_comb begin: alu_input
      case(alu_counter)

        // TESTING ADD
        'd1 : begin // Add Case 6: Zero ADD Case
            dut.core.`PROBE_ALU_SEL  = 2'b00;
            dut.core.`PROBE_ALU_OP1  = 'b0;
            dut.core.`PROBE_ALU_OP2  = 'b0;
            if (alu_res != 'd0 && alu_zflag)
                $display("[PD0] ADD Error: 1");
        end
        'd2 : begin // Add Case 6: Positive ADD Case
            dut.core.`PROBE_ALU_SEL  = 2'b00;
            dut.core.`PROBE_ALU_OP1  = 'd5;
            dut.core.`PROBE_ALU_OP2  = 'd3;
            if (alu_res != 'd8)
                $display("[PD0] ADD Error: 2");
        end
        'd3 : begin // Add Case 6: Negative ADD Case
            dut.core.`PROBE_ALU_SEL  = 2'b00;
            dut.core.`PROBE_ALU_OP1  = -32'd5;
            dut.core.`PROBE_ALU_OP2  = -32'd3;
            if (alu_res != -32'd8 && alu_nflag)
                $display("[PD0] ADD Error: 3");
        end
        'd4 : begin // Add Case 6: Mixed ADD Case
            dut.core.`PROBE_ALU_SEL  = 2'b00;
            dut.core.`PROBE_ALU_OP1  = 'd5;
            dut.core.`PROBE_ALU_OP2  = -32'd3;
            if (alu_res != 'd2)
                $display("[PD0] ADD Error: 4");
        end
        'd5 : begin // Add Case 6: Mixed ADD Case
            dut.core.`PROBE_ALU_SEL  = 2'b00;
            dut.core.`PROBE_ALU_OP1  = -32'd5;
            dut.core.`PROBE_ALU_OP2  = 32'd3;
            if (alu_res != -32'd2 && alu_nflag)
                $display("[PD0] ADD Error: 5");
        end
        'd6 : begin // Add Case 6: Two positive numbers
            dut.core.`PROBE_ALU_SEL = 2'b00; // Assuming 2'b00 is the opcode for ADD
            dut.core.`PROBE_ALU_OP1 = 32'd5;
            dut.core.`PROBE_ALU_OP2 = 32'd3;
            if (alu_res != 32'd8)
                $display("[PD0] ADD Error: Signed positive addition failed.");
        end
        'd7 : begin // Add Case 7: Two negative numbers
            dut.core.`PROBE_ALU_SEL = 2'b00;
            dut.core.`PROBE_ALU_OP1 = -32'd5;
            dut.core.`PROBE_ALU_OP2 = -32'd3;
            if (alu_res != -32'd8 && alu_nflag)
                $display("[PD0] ADD Error: Signed negative addition failed.");
        end
        'd8 : begin // Add Case 8: Mixed signs (positive result)
            dut.core.`PROBE_ALU_SEL = 2'b00;
            dut.core.`PROBE_ALU_OP1 = 32'd10;
            dut.core.`PROBE_ALU_OP2 = -32'd4;
            if (alu_res != 32'd6)
                $display("[PD0] ADD Error: Mixed sign addition failed (pos result).");
        end
        'd9 : begin // Add Case 9: Mixed signs (negative result)
            dut.core.`PROBE_ALU_SEL = 2'b00;
            dut.core.`PROBE_ALU_OP1 = -32'd10;
            dut.core.`PROBE_ALU_OP2 = 32'd4;
            if (alu_res != -32'd6 && alu_nflag)
                $display("[PD0] ADD Error: Mixed sign addition failed (neg result).");
        end
        'd10 : begin // Add Case 10: Overflow
            dut.core.`PROBE_ALU_SEL = 2'b00;
            dut.core.`PROBE_ALU_OP1 = 32'd2147483647; // Max signed 32-bit value
            dut.core.`PROBE_ALU_OP2 = 32'd1;
            // Expected result: -2147483648 (most negative signed 32-bit value due to wrap-around)
            if (alu_res != -32'd2147483648)
                $display("[PD0] ADD Error: Overflow test failed.");
        end
        'd11 : begin // Add Case 11: Underflow
            dut.core.`PROBE_ALU_SEL = 2'b00;
            dut.core.`PROBE_ALU_OP1 = -32'd2147483648; // Min signed 32-bit value
            dut.core.`PROBE_ALU_OP2 = -32'd1;
            // Expected result: 2147483647 (most positive signed 32-bit value due to wrap-around)
            if (alu_res != 32'd2147483647)
                $display("[PD0] ADD Error: Underflow test failed.");
        end

        // TESTING SUB
        'd12 : begin // Sub Case 1: Two positive numbers
            dut.core.`PROBE_ALU_SEL = 2'b01; // Assuming 2'b01 is the opcode for SUB
            dut.core.`PROBE_ALU_OP1 = 32'd8;
            dut.core.`PROBE_ALU_OP2 = 32'd5;
            if (alu_res != 32'd3)
                $display("[PD0] SUB Error: Signed positive subtraction failed.");
        end
        'd13 : begin // Sub Case 2: Two negative numbers
            dut.core.`PROBE_ALU_SEL = 2'b01;
            dut.core.`PROBE_ALU_OP1 = -32'd8;
            dut.core.`PROBE_ALU_OP2 = -32'd5;
            if (alu_res != -32'd3 && alu_nflag)
                $display("[PD0] SUB Error: Signed negative subtraction failed.");
        end
        'd14 : begin // Sub Case 3: Mixed signs (positive result)
            dut.core.`PROBE_ALU_SEL = 2'b01;
            dut.core.`PROBE_ALU_OP1 = 32'd10;
            dut.core.`PROBE_ALU_OP2 = -32'd4;
            if (alu_res != 32'd14)
                $display("[PD0] SUB Error: Mixed sign subtraction failed (pos result).");
        end
        'd15 : begin // Sub Case 4: Mixed signs (negative result)
            dut.core.`PROBE_ALU_SEL = 2'b01;
            dut.core.`PROBE_ALU_OP1 = -32'd10;
            dut.core.`PROBE_ALU_OP2 = 32'd4;
            if (alu_res != -32'd14 && alu_nflag)
                $display("[PD0] SUB Error: Mixed sign subtraction failed (neg result).");
        end
        'd16 : begin // Sub Case 5: Overflow
            dut.core.`PROBE_ALU_SEL = 2'b01;
            dut.core.`PROBE_ALU_OP1 = 32'd2147483647; // Max signed 32-bit value
            dut.core.`PROBE_ALU_OP2 = -32'd1;
            // Expected result: -2147483648
            if (alu_res != -32'd2147483648)
                $display("[PD0] SUB Error: Overflow test failed.");
        end
        'd17 : begin // Sub Case 6: Underflow
            dut.core.`PROBE_ALU_SEL = 2'b01;
            dut.core.`PROBE_ALU_OP1 = -32'd2147483648; // Min signed 32-bit value
            dut.core.`PROBE_ALU_OP2 = 32'd1;
            // Expected result: 2147483647
            if (alu_res != 32'd2147483647)
                $display("[PD0] SUB Error: Underflow test failed.");
        end

        'd18 : begin // AND Case 1: Simple test
            dut.core.`PROBE_ALU_SEL = 2'b10; // Assuming 2'b11 is the opcode for AND
            dut.core.`PROBE_ALU_OP1 = 32'h0F0F0F0F;
            dut.core.`PROBE_ALU_OP2 = 32'hF0F0F0F0;
            if (alu_res != 32'h00000000)
                $display("[PD0] AND Error: 1");
        end
        'd19 : begin // AND Case 2: Identity (AND with all 1s)
            dut.core.`PROBE_ALU_SEL = 2'b10;
            dut.core.`PROBE_ALU_OP1 = 32'hA5A5A5A5;
            dut.core.`PROBE_ALU_OP2 = 32'hFFFFFFFF;
            if (alu_res != 32'hA5A5A5A5)
                $display("[PD0] AND Error: 2");
        end
        'd20 : begin // AND Case 3: Zeroing out (AND with all 0s)
            dut.core.`PROBE_ALU_SEL = 2'b10;
            dut.core.`PROBE_ALU_OP1 = 32'hA5A5A5A5;
            dut.core.`PROBE_ALU_OP2 = 32'h00000000;
            if (alu_res != 32'h00000000 && alu_zflag)
                $display("[PD0] AND Error: 3");
        end

        // TESTING OR
        'd21 : begin // OR Case 1: Simple test
            dut.core.`PROBE_ALU_SEL = 2'b11; // Assuming 2'b10 is the opcode for OR
            dut.core.`PROBE_ALU_OP1 = 32'hA5A5A5A5;
            dut.core.`PROBE_ALU_OP2 = 32'h5A5A5A5A;
            if (alu_res != 32'hFFFFFFFF)
                $display("[PD0] OR Error: 1");
        end
        'd22 : begin // OR Case 2: Identity (OR with 0)
            dut.core.`PROBE_ALU_SEL = 2'b11;
            dut.core.`PROBE_ALU_OP1 = 32'hA5A5A5A5;
            dut.core.`PROBE_ALU_OP2 = 32'h00000000;
            if (alu_res != 32'hA5A5A5A5)
                $display("[PD0] OR Error: 2");
        end
        'd23 : begin // OR Case 3: Setting all bits (OR with all 1s)
            dut.core.`PROBE_ALU_SEL = 2'b11;
            dut.core.`PROBE_ALU_OP1 = 32'h00000000;
            dut.core.`PROBE_ALU_OP2 = 32'hFFFFFFFF;
            if (alu_res != 32'hFFFFFFFF)
                $display("[PD0] OR Error: 3");
        end
      endcase
  end
  always_ff @(posedge clock) begin: alu_test
      if (reset_done) begin
          $display("[ALU] inp1=%b, inp2=%b, alusel=%b, res=%b", alu_op1, alu_op2, alu_sel, alu_res);

      end
      alu_sel  <= dut.core.`PROBE_ALU_SEL;
      alu_op1 <= dut.core.`PROBE_ALU_OP1;
      alu_op2 <= dut.core.`PROBE_ALU_OP2;
      alu_res  <= dut.core.`PROBE_ALU_RES;

      alu_nflag <= dut.core.`PROBE_ALU_NFLAG;
      alu_zflag <= dut.core.`PROBE_ALU_ZFLAG;

      if (reset_done)
        alu_counter <= alu_counter + 1;
  end
 `else
    always_ff @(posedge clock) begin: alu_test
        $fatal(1, "[ALU] Probe signals not defined");
    end
`endif


`ifdef PROBE_REG_IN `ifdef PROBE_REG_OUT
`define PROBE_REG_OK
`endif `endif
`ifdef PROBE_REG_OK
  logic [31:0] reg_rst_inp;
  logic [31:0] reg_rst_out;

  always_comb begin: reg_rst_input
      dut.core.`PROBE_REG_IN = counter[31:0];
  end
  always_ff @(posedge clock) begin: reg_rst_test
      if (reset_done) begin
        $display("[REG] inp=%b, out=%b", reg_rst_inp, reg_rst_out);
      end
      reg_rst_inp <= dut.core.`PROBE_REG_IN;
      reg_rst_out <= dut.core.`PROBE_REG_OUT;
  end
  `else
    always_ff @(posedge clock) begin: reg_rst_test
        $fatal(1, "[REG] Probe signals not defined");
    end
`endif

`ifdef PROBE_TSP_OP1 `ifdef PROBE_TSP_OP2 `ifdef PROBE_TSP_RES
`define PROBE_TSP_OK
`endif `endif `endif
`ifdef PROBE_TSP_OK

  // three_stage_pipeline
  logic [31:0] tsp_op1;
  logic [31:0] tsp_op2;
  logic [31:0] tsp_out;
  always_comb begin: tsp_input
      dut.core.`PROBE_TSP_OP1 = counter[31:0];
      dut.core.`PROBE_TSP_OP2 = {counter[1], counter[2], counter[0], counter[31:3]};
  end
  always_ff @(posedge clock) begin: tsp_test
      if (reset_done) begin
        $display("[TSP] op1=%b, op2=%b, out=%b", tsp_op1, tsp_op2, tsp_out);
      end
      tsp_op1 <= dut.core.`PROBE_TSP_OP1;
      tsp_op2 <= dut.core.`PROBE_TSP_OP2;
      tsp_out <= dut.core.`PROBE_TSP_RES;
  end
    `else
    always_ff @(posedge clock) begin: tsp_test
        $fatal(1, "[TSP] Probe signals not defined");
    end
`endif


 `ifdef VCD
  initial begin
    $dumpfile(`VCD_FILE);
    $dumpvars;
  end
  `endif
endmodule
