# ============================================================================
# Basys 3 constraints for tron port (top: chipInterface)
# Ports: CLOCK_100, BTN[3:0], SW[15:0], PD1..PD8, vga_r/g/b[3:0], vga_hs, vga_vs
# ============================================================================

# 100 MHz system clock (Basys 3 oscillator on W5)
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports CLOCK_100]
create_clock -period 10.000 -name sys_clk [get_ports CLOCK_100]

# ---------------------------------------------------------------------------
# VGA  (4 bits per channel) + sync
# ---------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {vga_r[0]}]
set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33} [get_ports {vga_r[1]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {vga_r[2]}]
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVCMOS33} [get_ports {vga_r[3]}]
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33} [get_ports {vga_b[0]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {vga_b[1]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {vga_b[2]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {vga_b[3]}]
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {vga_g[0]}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {vga_g[1]}]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {vga_g[2]}]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {vga_g[3]}]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports vga_hs]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33} [get_ports vga_vs]

# ---------------------------------------------------------------------------
# Buttons  BTN[3:0]  (Basys 3: btnU=T18, btnL=W19, btnR=T17, btnD=U17)
# Player 1 uses these four as left/right/up/down
# ---------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports {BTN[0]}]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports {BTN[1]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {BTN[2]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {BTN[3]}]

# ---------------------------------------------------------------------------
# Switches  SW[15:0]   (SW[0] is reset in this design)
# ---------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN W17 IOSTANDARD LVCMOS33} [get_ports {SW[3]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {SW[4]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {SW[5]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {SW[6]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {SW[7]}]
set_property -dict {PACKAGE_PIN V2  IOSTANDARD LVCMOS33} [get_ports {SW[8]}]
set_property -dict {PACKAGE_PIN T3  IOSTANDARD LVCMOS33} [get_ports {SW[9]}]
set_property -dict {PACKAGE_PIN T2  IOSTANDARD LVCMOS33} [get_ports {SW[10]}]
set_property -dict {PACKAGE_PIN R3  IOSTANDARD LVCMOS33} [get_ports {SW[11]}]
set_property -dict {PACKAGE_PIN W2  IOSTANDARD LVCMOS33} [get_ports {SW[12]}]
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVCMOS33} [get_ports {SW[13]}]
set_property -dict {PACKAGE_PIN T1  IOSTANDARD LVCMOS33} [get_ports {SW[14]}]
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports {SW[15]}]

# ---------------------------------------------------------------------------
# Player 2 controller on Pmod JA (PD1..PD4) and JB (PD5..PD8)
# Pulldown so idle reads 0 (matches direction-decode default)
# ---------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN J1  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD1}]
set_property -dict {PACKAGE_PIN L2  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD2}]
set_property -dict {PACKAGE_PIN J2  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD3}]
set_property -dict {PACKAGE_PIN G2  IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD4}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD5}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD6}]
set_property -dict {PACKAGE_PIN B15 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD7}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33 PULLDOWN true} [get_ports {PD8}]
