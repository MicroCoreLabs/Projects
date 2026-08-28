onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix binary /top/i_ATMax/isa_memory_match
add wave -noupdate /top/i_ATMax/ISA_RST
add wave -noupdate /top/i_isabus16_model/ISA_CLK
add wave -noupdate /top/i_ATMax/ISA_ADDR
add wave -noupdate /top/i_ATMax/ISA_DATA
add wave -noupdate /top/i_isabus16_model/ISA_ALE
add wave -noupdate /top/i_ATMax/ISA_SBHE_n
add wave -noupdate /top/i_ATMax/ISA_AEN
add wave -noupdate /top/i_ATMax/ISA_MEM_WR_n
add wave -noupdate /top/i_ATMax/ISA_MEM_RD_n
add wave -noupdate /top/i_ATMax/ISA_IO_WR_n
add wave -noupdate /top/i_ATMax/ISA_IO_RD_n
add wave -noupdate /top/i_ATMax/ISA_REFRESH_n
add wave -noupdate /top/i_ATMax/ISA_NOWAIT_n
add wave -noupdate /top/i_ATMax/SDRAM_CLK
add wave -noupdate /top/i_ATMax/sdram_cmd
add wave -noupdate /top/i_ATMax/ISA_MEM16_n
add wave -noupdate /top/i_ATMax/SDRAM_CKE
add wave -noupdate -radix binary /top/i_ATMax/SDRAM_BA
add wave -noupdate /top/i_ATMax/SDRAM_ADDR
add wave -noupdate /top/i_ATMax/SDRAM_DATA
add wave -noupdate /top/i_ATMax/memory_address
add wave -noupdate /top/i_ATMax/SDRAM_CS_n
add wave -noupdate /top/i_ATMax/SDRAM_RAS_n
add wave -noupdate /top/i_ATMax/SDRAM_CAS_n
add wave -noupdate /top/i_ATMax/SDRAM_WE_n
add wave -noupdate -radix binary /top/i_ATMax/SDRAM_DQM
add wave -noupdate /top/i_ATMax/isa_data_out_oe
add wave -noupdate /top/i_ATMax/isa_mem_rd_n_d1
add wave -noupdate -radix binary /top/i_ATMax/isa_data_out_oe_d1
add wave -noupdate /top/i_ATMax/main_state
add wave -noupdate /top/i_ATMax/sdram_data_out_oe
add wave -noupdate /top/i_ATMax/sdram_data_out_oe_d1
add wave -noupdate /top/i_ATMax/isa_rst_d1
add wave -noupdate /top/i_ATMax/isa_rst_d2
add wave -noupdate /top/i_ATMax/sdram_address_out
add wave -noupdate /top/i_ATMax/sdram_cke_int
add wave -noupdate /top/i_ATMax/isa_mem_rd_n_d2
add wave -noupdate /top/i_ATMax/isa_mem_wr_n_d1
add wave -noupdate /top/i_ATMax/isa_mem_wr_n_d2
add wave -noupdate /top/i_ATMax/isa_io_rd_n_d1
add wave -noupdate /top/i_ATMax/isa_io_rd_n_d2
add wave -noupdate /top/i_ATMax/isa_io_wr_n_d1
add wave -noupdate /top/i_ATMax/isa_io_wr_n_d2
add wave -noupdate /top/i_ATMax/ems_frame_pointer0
add wave -noupdate /top/i_ATMax/ems_frame_pointer1
add wave -noupdate /top/i_ATMax/ems_frame_pointer2
add wave -noupdate /top/i_ATMax/ems_frame_pointer3
add wave -noupdate /top/i_ATMax/ems_base_segment
add wave -noupdate /top/i_ATMax/umb_base_segment
add wave -noupdate /top/i_ATMax/sdram_data_in_d1
add wave -noupdate /top/i_ATMax/isa_data_out
add wave -noupdate /top/i_ATMax/isa_data_out_d1
add wave -noupdate /top/i_ATMax/sdram_data_out
add wave -noupdate /top/i_ATMax/sdram_data_out_d1
add wave -noupdate /top/i_ATMax/sdram_dqm_int
add wave -noupdate /top/i_ATMax/delay_counter
add wave -noupdate /top/i_ATMax/sdram_cke_int_out
add wave -noupdate /top/i_ATMax/sdram_ba_int_out
add wave -noupdate /top/i_ATMax/sdram_addr_int_out
add wave -noupdate /top/i_ATMax/sdram_cs_n_int_out
add wave -noupdate /top/i_ATMax/sdram_ras_n_int_out
add wave -noupdate /top/i_ATMax/sdram_cas_n_int_out
add wave -noupdate /top/i_ATMax/sdram_we_n_int_out
add wave -noupdate /top/i_ATMax/sdram_dqm_int_out
add wave -noupdate /top/i_ATMax/isa_io_mman_match
add wave -noupdate /top/i_ATMax/isa_memory_match
add wave -noupdate /top/i_ATMax/PIANO_SWITCH
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 10} {398854800 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 254
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
WaveRestoreZoom {398292300 ps} {399454100 ps}
