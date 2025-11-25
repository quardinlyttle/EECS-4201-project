/*
 * Good practice to define constants and refer to them in the
 * design files. An example of some constants are provided to you
 * as a starting point
 *
 */
`ifndef CONSTANTS_SVH_
`define CONSTANTS_SVH_

parameter logic [31:0] ZERO =   32'd0;

//ALU Constants
parameter logic [3:0]   ADD             = 4'd0;
parameter logic [3:0]   SUB             = 4'd1;
parameter logic [3:0]   XOR             = 4'd2;
parameter logic [3:0]   OR              = 4'd3;
parameter logic [3:0]   AND             = 4'd4;
parameter logic [3:0]   SLL             = 4'd5;
parameter logic [3:0]   SRL             = 4'd6;
parameter logic [3:0]   SRA             = 4'd7;
parameter logic [3:0]   SLT             = 4'd8;
parameter logic [3:0]   SLTU            = 4'd9;
parameter logic [3:0]   PCADD           = 4'd10;

//Write Back Constants
parameter logic [1:0]   wbALU           = 2'b00;
parameter logic [1:0]   wbMEM           = 2'b01;
parameter logic [1:0]   wbPC            = 2'b10;
parameter logic [1:0]   wbJAL           = 2'b11; //Gate writeback/turn it off

//Instruction Types Opcodes
parameter logic [6:0]   RTYPE           = 7'b011_0011;
parameter logic [6:0]   ITYPE           = 7'b001_0011;
parameter logic [6:0]   LOAD            = 7'b000_0011;
parameter logic [6:0]   STORE           = 7'b010_0011;
parameter logic [6:0]   BRANCH          = 7'b110_0011;
parameter logic [6:0]   JAL             = 7'b110_1111;
parameter logic [6:0]   JALR            = 7'b110_0111;
parameter logic [6:0]   LUI             = 7'b011_0111;
parameter logic [6:0]   AUIPC           = 7'b001_0111;

//LOAD funct3
parameter logic [2:0]   LBYTE           = 3'h0;
parameter logic [2:0]   LHALF           = 3'h1;
parameter logic [2:0]   LWORD           = 3'h2;
parameter logic [2:0]   LBU             = 3'h4;
parameter logic [2:0]   LHU             = 3'h5;

//STORE funct3
parameter logic [2:0]   SBYTE           = 3'h0;
parameter logic [2:0]   SHALF           = 3'h1;
parameter logic [2:0]   SWORD           = 3'h2;

//BIT WIDTHS
parameter int           OPCODE_SIZE     = 7;
parameter int           FUNCT3_SIZE     = 3;
parameter int           FUNCT7_SIZE     = 7;
parameter int           WBSEL_SIZE      = 2;
parameter int           ALUSEL_SIZE     = 4;
parameter int           RADDR_SIZE      = 5;

`endif
