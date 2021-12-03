#edited by huiseong noh
#SIM => default setting : icarus
#TOPLEVEL_LANG => language of top level HDL file
#VERILOG_SOURCE => file name of top level HDL file
#MODULE => name of python file of cocotb testbench
#TOPLEVEL => file name of HDL of top level

SIM ?= icarus 
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = $(shell pwd)/../hdl/neuron05.v

TOPLEVEL = neuron05
MODULE   = coco_bench 

include $(shell cocotb-config --makefiles)/Makefile.sim
