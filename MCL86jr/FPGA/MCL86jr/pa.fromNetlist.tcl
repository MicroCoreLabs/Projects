
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name MCL86jr -dir "C:/MCL/MCL86/MCL86jr/MCL86jr/planAhead_run_3" -part xc6slx9tqg144-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/MCL/MCL86/MCL86jr/MCL86jr/MCL86jr.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/MCL/MCL86/MCL86jr/MCL86jr} {ipcore_dir} }
add_files [list {ipcore_dir/EU4Kx32.ncf}] -fileset [get_property constrset [current_run]]
set_param project.pinAheadLayout  yes
set_property target_constrs_file "MCL86jr.ucf" [current_fileset -constrset]
add_files [list {MCL86jr.ucf}] -fileset [get_property constrset [current_run]]
link_design
