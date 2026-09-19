#==============================================================================
# crc_top.xdc -- ZedBoard (Zynq XC7Z020-1CLG484C, part xc7z020clg484-1)
#
# Every top-level port must appear here with both a PACKAGE_PIN and an
#==============================================================================

#------------------------------------------------------------------------------
# Clock -- 100 MHz PL oscillator, bank 13
#------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN Y9  IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

#------------------------------------------------------------------------------
# Slide switches -- banks 34/35, powered from Vadj (J18).
# If these read stuck-low on hardware, your board has Vadj at 1.8 V:
# change LVCMOS33 to LVCMOS18 on these three lines only.
#------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports sw_override]  ;# SW0
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports sw_load_sel]  ;# SW1

set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports btn_par_load]  ;# BTNL
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports btn_start_tx]  ;# BTNR
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports btn_rst]       ;# BTND

#------------------------------------------------------------------------------
# User LEDs -- bank 33, 3.3 V, active high
#------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {led[0]}]  ;# LD0 RECEIVED
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {led[1]}]  ;# LD1 CORRUPTED
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {led[2]}]  ;# LD2 tx_ready
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {led[3]}]  ;# LD3 rx_done
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {led[4]}]  ;# LD4 override
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {led[5]}]  ;# LD5 load_select

#------------------------------------------------------------------------------
# Switch inputs are asynchronous and go through a 2-flop synchroniser in RTL,
# so no input timing path is real. Tell the tool not to analyse them.
#------------------------------------------------------------------------------
set_false_path -from [get_ports sw_override]
set_false_path -from [get_ports sw_load_sel]
set_false_path -from [get_ports btn_par_load]
set_false_path -from [get_ports btn_start_tx]
set_false_path -from [get_ports btn_rst]
set_false_path -to [get_ports {led[*]}]
