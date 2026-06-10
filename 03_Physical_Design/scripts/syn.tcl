set design mips_16

#set top_module mips_16_TOP

set_svf /home/ahesham/ref_flow_before/syn/output/${design}.svf

set_app_var search_path "/home/ahesham/ref_flow_before/standard_cell_libraries/NangateOpenCellLibrary_PDKv1_3_v2010_12/lib/Front_End/Liberty/NLDM"
set_app_var link_library "* NangateOpenCellLibrary_ss0p95vn40c.db"
set_app_var target_library "NangateOpenCellLibrary_ss0p95vn40c.db"


sh rm -rf work
sh mkdir -p work
define_design_lib work -path ./work


analyze -library work -format verilog /home/ahesham/ref_flow_before/rtl/${design}.v
elaborate $design -lib work
current_design 

check_design
source /home/ahesham/ref_flow_before/syn/cons/cons.tcl
link


compile -area_effort high -map_effort high 

report_area > /home/ahesham/ref_flow_before/syn/report/synth_area.rpt
report_cell > /home/ahesham/ref_flow_before/syn/report/synth_cells.rpt
report_qor  > /home/ahesham/ref_flow_before/syn/report/synth_qor.rpt
report_resources > /home/ahesham/ref_flow_before/syn/report/synth_resources.rpt
report_timing -max_paths 10 > /home/ahesham/ref_flow_before/syn/report/synth_timing.rpt 

set_svf -off
 
write_sdc  /home/ahesham/ref_flow_before/syn/output/${design}.sdc 

define_name_rules  no_case -case_insensitive
change_names -rule no_case -hierarchy
change_names -rule verilog -hierarchy
set verilogout_no_tri	 true
set verilogout_equation  false

write -hierarchy -format verilog -output /home/ahesham/ref_flow_before/syn/output/${design}.v 
write -f ddc -hierarchy -output /home/ahesham/ref_flow_before/syn/output/${design}.ddc   

exit
