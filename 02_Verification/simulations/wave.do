onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group clock /SYS_TOP_TB/CLK_tb
add wave -noupdate -expand -group reset -color Gold /SYS_TOP_TB/RST_N_tb
add wave -noupdate -expand -group {Push Buttons} -color Cyan /SYS_TOP_TB/dut/mode_pulse
add wave -noupdate -expand -group {Push Buttons} -color Pink /SYS_TOP_TB/dut/set_pulse
add wave -noupdate -expand -group {Push Buttons} -color Magenta /SYS_TOP_TB/dut/mode_set
add wave -noupdate -expand -group States -radix unsigned -radixshowbase 0 /SYS_TOP_TB/dut/U0_SYS_CTRL/current_state
add wave -noupdate -expand -group States -radix unsigned -radixshowbase 0 /SYS_TOP_TB/dut/U0_SYS_CTRL/next_state
add wave -noupdate -expand -group enables /SYS_TOP_TB/dut/U0_SYS_CTRL/en_sw
add wave -noupdate -expand -group enables /SYS_TOP_TB/dut/U0_SYS_CTRL/en_ala
add wave -noupdate -expand -group enables /SYS_TOP_TB/dut/U0_SYS_CTRL/en_st
add wave -noupdate -expand -group {Time and indicators} -color Cyan -radix unsigned /SYS_TOP_TB/hours_2_tb
add wave -noupdate -expand -group {Time and indicators} -color Magenta /SYS_TOP_TB/load_en_hr_2_tb
add wave -noupdate -expand -group {Time and indicators} -color Cyan -radix unsigned /SYS_TOP_TB/hours_1_tb
add wave -noupdate -expand -group {Time and indicators} -color Magenta /SYS_TOP_TB/load_en_hr_1_tb
add wave -noupdate -expand -group {Time and indicators} -color Yellow -radix unsigned /SYS_TOP_TB/minute_2_tb
add wave -noupdate -expand -group {Time and indicators} -color Magenta /SYS_TOP_TB/load_en_min_2_tb
add wave -noupdate -expand -group {Time and indicators} -color Yellow -radix unsigned /SYS_TOP_TB/minute_1_tb
add wave -noupdate -expand -group {Time and indicators} -color Magenta /SYS_TOP_TB/load_en_min_1_tb
add wave -noupdate -expand -group {Other Outputs} -color Pink /SYS_TOP_TB/Split_ind_tb
add wave -noupdate -expand -group {Other Outputs} -color {Cornflower Blue} /SYS_TOP_TB/sound_tb
add wave -noupdate -group {time setting} -radix unsigned /SYS_TOP_TB/dut/U0_time_set/current_state
add wave -noupdate -group {time setting} -radix unsigned /SYS_TOP_TB/dut/U0_time_set/next_state
add wave -noupdate -group {time setting} -color Cyan -radix unsigned /SYS_TOP_TB/dut/U0_time_set/Hd2
add wave -noupdate -group {time setting} -color Cyan -radix unsigned /SYS_TOP_TB/dut/U0_time_set/Hd1
add wave -noupdate -group {time setting} -color Yellow -radix unsigned /SYS_TOP_TB/dut/U0_time_set/Md2
add wave -noupdate -group {time setting} -color Yellow -radix unsigned /SYS_TOP_TB/dut/U0_time_set/Md1
add wave -noupdate -expand -group Testing -radix unsigned -radixshowbase 0 /SYS_TOP_TB/TEST_NUM
add wave -noupdate -expand -group Testing -radix unsigned -radixshowbase 0 /SYS_TOP_TB/passed_cases
add wave -noupdate -expand -group Testing -color Red -radix unsigned -radixshowbase 0 /SYS_TOP_TB/failed_cases
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {597 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {5446471408935 ns} {7027027820583 ns}
