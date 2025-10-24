# =====================
# ModelSim Multi-TB Makefile
# =====================

TESTBENCHES = register_file_tb branch_control_tb
DESIGN_SRCS = register_file.sv branch_control.sv
COMMON_SRCS = constants.svh
WORK = work

all: $(TESTBENCHES:%=run_%)

$(WORK):
	vlib $(WORK)

run_%: $(WORK)
	@echo "=== Running $* ==="
	vlog -work $(WORK) -sv $(DESIGN_SRCS) $(COMMON_SRCS) $*.sv
	@echo 'vcd file "$*.vcd"'  >  run_$*.macro
	@echo 'vcd add -r /$*/*'   >> run_$*.macro
	@echo 'run -all'           >> run_$*.macro
	@echo 'quit'               >> run_$*.macro
	vsim -c -do run_$*.macro $(WORK).$*
	rm -f run_$*.macro

clean:
	rm -rf $(WORK) *.vcd transcript vsim.wlf run_*.macro
