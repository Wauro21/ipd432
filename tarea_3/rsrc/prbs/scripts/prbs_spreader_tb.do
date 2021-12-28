onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /prbs_spreader_tb/clk
add wave -noupdate -format Logic /prbs_spreader_tb/rstn
add wave -noupdate -divider {Source PRBS}
add wave -noupdate -format Logic /prbs_spreader_tb/src_load
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/src_seed
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/src_lfsr
add wave -noupdate -format Logic /prbs_spreader_tb/src_enable
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/src_prbs
add wave -noupdate -divider {Destination PRBS}
add wave -noupdate -format Logic /prbs_spreader_tb/dst_load
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/dst_seed
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/dst_lfsr
add wave -noupdate -format Logic /prbs_spreader_tb/dst_enable
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/dst_prbs
add wave -noupdate -divider Data
add wave -noupdate -format Logic /prbs_spreader_tb/data_enable
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/data_count
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/data_in
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/data_spread
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/data_delay
add wave -noupdate -format Literal -radix hexadecimal /prbs_spreader_tb/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6450 ns} 0}
configure wave -namecolwidth 234
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {12789 ns}
