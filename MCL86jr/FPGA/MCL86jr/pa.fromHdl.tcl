
# PlanAhead Launch Script for Pre-Synthesis Floorplanning, created by Project Navigator

create_project -name MCL86jr -dir "C:/MCL/MCL86/MCL86jr/MCL86jr/planAhead_run_1" -part xc6slx9tqg144-3
set_param project.pinAheadLayout yes
set srcset [get_property srcset [current_run -impl]]
set_property target_constrs_file "MCL86jr.ucf" [current_fileset -constrset]
set hdlfile [add_files [list {ipcore_dir/EU4Kx32.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
add_files [list {ipcore_dir/EU4Kx32.ngc}]
set hdlfile [add_files [list {../src4synth/eu.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../src4synth/biu_min.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set hdlfile [add_files [list {../src4synth/MCL86jr.v}]]
set_property file_type Verilog $hdlfile
set_property library work $hdlfile
set_property top MCL86jr $srcset
add_files [list {MCL86jr.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/EU4Kx32.ncf}] -fileset [get_property constrset [current_run]]
open_rtl_design -part xc6slx9tqg144-3
