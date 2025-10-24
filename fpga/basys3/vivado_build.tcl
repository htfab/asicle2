set design_name "asicle2"
set board_name "basys3"
set fpga_part "xc7a35tcpg236-1"

set src_dir [file normalize "../../src"]

read_verilog -sv "${src_dir}/input_gamepad.sv"
read_verilog -sv "${src_dir}/input_debounce.sv"
read_verilog -sv "${src_dir}/input_logic.sv"
read_verilog -sv "${src_dir}/input_top.sv"
read_verilog -sv "${src_dir}/vga_grid.sv"
read_verilog -sv "${src_dir}/vga_render.sv"
read_verilog -sv "${src_dir}/vga_top.sv"
read_verilog -sv "${src_dir}/qspi_arbiter.sv"
read_verilog -sv "${src_dir}/qspi_sequencer.sv"
read_verilog -sv "${src_dir}/qspi_sampler.sv"
read_verilog -sv "${src_dir}/qspi_fifo.sv"
read_verilog -sv "${src_dir}/qspi_top.sv"
read_verilog -sv "${src_dir}/game_board.sv"
read_verilog -sv "${src_dir}/game_feedback.sv"
read_verilog -sv "${src_dir}/game_logic.sv"
read_verilog -sv "${src_dir}/game_top.sv"
read_verilog -sv "${src_dir}/project.sv"
read_verilog -sv "pll.sv"
read_verilog -sv "delay.sv"
read_verilog -sv "fpga_top.sv"

read_xdc "${board_name}.xdc"

synth_design -top "fpga_top" -part "${fpga_part}"

opt_design
place_design
route_design

write_bitstream -force "${design_name}.bit"

