onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /noise_tb/test_number
add wave -noupdate -format Logic /noise_tb/clk
add wave -noupdate -format Logic /noise_tb/rstn
add wave -noupdate -format Logic /noise_tb/load
add wave -noupdate -format Literal -radix hexadecimal /noise_tb/seed
add wave -noupdate -format Logic /noise_tb/enable
add wave -noupdate -format Literal -radix hexadecimal /noise_tb/q
add wave -noupdate -format Analog-Step -height 74 -max 27689.999999999996 -min -27027.0 -radix decimal /noise_tb/q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 59
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
WaveRestoreZoom {0 ns} {13199 ns}
