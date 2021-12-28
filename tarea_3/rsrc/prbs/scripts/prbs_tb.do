onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /prbs_tb/clk_fast
add wave -noupdate -format Logic /prbs_tb/clk
add wave -noupdate -format Logic /prbs_tb/rstn
add wave -noupdate -divider {LFSR/PRBS seed}
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/seed
add wave -noupdate -divider LFSR
add wave -noupdate -format Logic /prbs_tb/lfsr_load
add wave -noupdate -format Logic /prbs_tb/lfsr_enable
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/lfsr_q
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/lfsr_shift
add wave -noupdate -divider PRBS
add wave -noupdate -format Logic /prbs_tb/prbs_load
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/prbs_lfsr
add wave -noupdate -format Logic /prbs_tb/prbs_enable
add wave -noupdate -divider {Parallel PRBS values}
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/lfsr_prbs
add wave -noupdate -format Literal -radix hexadecimal /prbs_tb/prbs_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {204160 ns} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ns} {90048 ns}
