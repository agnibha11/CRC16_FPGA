set_property SRC_FILE_INFO {cfile:{/home/agnibha/Documents/acads/Reconfig/Lab Assignments/Lab 2/CRC16/CRC16.srcs/constrs_1/new/CRC_CONSTRAINTS.xdc} rfile:../../../CRC16.srcs/constrs_1/new/CRC_CONSTRAINTS.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:10 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33} [get_ports clk]
set_property src_info {type:XDC file:1 line:18 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports sw_override]  ;# SW0
set_property src_info {type:XDC file:1 line:19 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports sw_load_sel]  ;# SW1
set_property src_info {type:XDC file:1 line:21 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports btn_par_load]  ;# BTNL
set_property src_info {type:XDC file:1 line:22 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports btn_start_tx]  ;# BTNR
set_property src_info {type:XDC file:1 line:23 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports btn_rst]       ;# BTND
set_property src_info {type:XDC file:1 line:28 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {led[0]}]  ;# LD0 RECEIVED
set_property src_info {type:XDC file:1 line:29 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {led[1]}]  ;# LD1 CORRUPTED
set_property src_info {type:XDC file:1 line:30 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {led[2]}]  ;# LD2 tx_ready
set_property src_info {type:XDC file:1 line:31 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {led[3]}]  ;# LD3 rx_done
set_property src_info {type:XDC file:1 line:32 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {led[4]}]  ;# LD4 override
set_property src_info {type:XDC file:1 line:33 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {led[5]}]  ;# LD5 load_select
