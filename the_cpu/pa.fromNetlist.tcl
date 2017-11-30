
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name the_cpu -dir "C:/Users/nuonuo/Desktop/3weeks_in/3weeks/the_cpu/planAhead_run_3" -part xc3s1200efg320-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/nuonuo/Desktop/3weeks_in/3weeks/the_cpu/cpu.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/nuonuo/Desktop/3weeks_in/3weeks/the_cpu} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "cpu.ucf" [current_fileset -constrset]
add_files [list {cpu.ucf}] -fileset [get_property constrset [current_run]]
link_design
