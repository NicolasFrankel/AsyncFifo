source /tools/Xilinx/Vivado/2021.1/settings64.sh

cd synth
rm -f *
vivado -mode batch -source ../script/synth.tcl -log synthesis.log -nojournal 
