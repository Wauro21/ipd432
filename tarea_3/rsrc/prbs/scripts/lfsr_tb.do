onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /lfsr_tb/clk
add wave -noupdate -format Logic /lfsr_tb/rstn
add wave -noupdate -format Logic /lfsr_tb/load
add wave -noupdate -format Literal -radix hexadecimal /lfsr_tb/seed
add wave -noupdate -format Logic /lfsr_tb/enable
add wave -noupdate -format Literal -radix hexadecimal -expand /lfsr_tb/data
add wave -noupdate -format Logic /lfsr_tb/prbs
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {102 ns} 0}
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
WaveRestoreZoom {0 ns} {11025 ns}
