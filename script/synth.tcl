

create_project -in_memory -part xcku3p-ffvb676-2-e

read_verilog -sv -verbose ../src/fifo_async.sv
read_verilog -sv -verbose ../src/gray_cnt.sv
read_xdc  -verbose ../src/fifo_async_ooc.xdc



set_property top fifo_async [current_fileset]
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sources_1

eval synth_design               \
    -generic WIDTH=16           \
    -generic DEPTH_LOG2=6       \
    -mode out_of_context        \
    -top fifo_async             \
    -flatten_hierarchy none     \
    -directive Default          \
    -keep_equivalent_registers  \
    -resource_sharing off       \
    -no_lc                      \
    -shreg_min_size 5           

write_checkpoint -force "fifo_async_post_synth.dcp"

report_timing_summary   -file "fifo_async_post_synth_timing_summary.rpt"
report_utilization      -file "fifo_async_post_synth_utilization_summary.rpt"



#close_project

