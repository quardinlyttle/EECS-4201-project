# Makefile for memory_tb.sv testbench with ModelSim (vsim)

# Top-level testbench module
TOP      = memory_tb

# Source files
SRCS     = memory.sv memory_tb.sv

# Output VCD
VCD      = $(TOP).vcd

# Work library
WORK     = work

all: run

# Create ModelSim work library if not exists
$(WORK):
	vlib $(WORK)

compile: $(WORK)
	vlog -work $(WORK) -sv \
	+define+MEM_DEPTH=1048576 \
	+define+TESTBENCH=1 \
	$(SRCS)


# Run simulation and dump VCD
run: compile run.macro
	vsim -c -do run.macro $(WORK).$(TOP)

# Macro file for VCD dump
run.macro:
	echo 'vcd file "$(VCD)"'        >  run.macro
	echo 'vcd add -r /$(TOP)/*'     >> run.macro
	echo 'run -all'                 >> run.macro
	echo 'quit'                     >> run.macro

clean:
	rm -rf $(WORK) *.vcd transcript vsim.wlf run.macro
