#edited by huiseong noh
#SIM => default setting : icarus
#TOPLEVEL_LANG => language of top level HDL file
#VERILOG_SOURCE => file name of top level HDL file
#MODULE => name of python file of cocotb testbench
#TOPLEVEL => file name of HDL of top level

SIM ?= icarus 
TOPLEVEL_LANG ?= verilog

TOPLEVEL = neuron07
MODULE   = coco_bench 

WPWD = $(shell pwd)
VERILOG_SOURCES += $(WPWD)/../parameter.h
VERILOG_SOURCES += $(WPWD)/../hdl/neuron07.v


include $(shell cocotb-config --makefiles)/Makefile.sim
