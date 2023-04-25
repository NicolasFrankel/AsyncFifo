
create_clock -period 5.000 -name w_clk -waveform {0.000 2.500} [get_ports w_clk]
create_clock -period 4.000 -name r_clk -waveform {0.000 2.000} [get_ports r_clk]

set_max_delay -from [get_clocks w_clk] -to [get_clocks -of_objects [get_nets r_clk]] 3.9 -datapath_only
set_max_delay -from [get_clocks r_clk] -to [get_clocks -of_objects [get_nets w_clk]] 3.9 -datapath_only