if {[file exists rtl_work]} {
    vdel -lib rtl_work -all
}

vlib rtl_work
vmap work rtl_work

puts "Compiling SystemVerilog files..."
vlog -sv -work work +incdir+. mux_pkg.sv
vlog -sv -work work +incdir+. mux_4to1.sv
vlog -sv -work work +incdir+. mux_4to1_tb.sv

puts "Starting simulation..."
vsim -t 1ps -L rtl_work -L work -voptargs="+acc" work.mux_4to1_tb

add wave -r /*
view wave

run -all