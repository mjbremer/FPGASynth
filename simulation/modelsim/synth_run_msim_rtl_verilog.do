transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib soc
vmap soc soc
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis {C:/Users/Matt/ece-385/synth/soc/synthesis/soc.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_reset_controller.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_avalon_st_adapter.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_avalon_sc_fifo.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_sysid_qsys_0.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_sample_clk.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_onchip_memory2_0.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0_cpu.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0_cpu_debug_slave_sysclk.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0_cpu_debug_slave_tck.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0_cpu_debug_slave_wrapper.v}
vlog -vlog01compat -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_nios2_gen2_0_cpu_test_bench.v}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/register.sv}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/synth.sv}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/NCO.sv}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/testbench.sv}
vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/rom.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_irq_mapper.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_rsp_mux.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_arbitrator.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_rsp_demux.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_cmd_mux.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_cmd_demux.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_router_002.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/soc_mm_interconnect_0_router.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_slave_agent.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_burst_uncompressor.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_master_agent.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_slave_translator.sv}
vlog -sv -work soc +incdir+C:/Users/Matt/ece-385/synth/soc/synthesis/submodules {C:/Users/Matt/ece-385/synth/soc/synthesis/submodules/altera_merlin_master_translator.sv}
vcom -93 -work work {C:/Users/Matt/ece-385/synth/audio_interface.vhd}

vlog -sv -work work +incdir+C:/Users/Matt/ece-385/synth {C:/Users/Matt/ece-385/synth/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L soc -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 100 us
