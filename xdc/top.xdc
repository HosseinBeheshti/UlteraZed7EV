#####
## Constraints for UZ7EV
## Version 1.0
#####


#####
## Pins
#####
#300MHz system clock
set_property PACKAGE_PIN AC8 [get_ports {sysclk_uz7ev_clk_p}]
set_property IOSTANDARD LVDS [get_ports {sysclk_uz7ev_clk_p}]

#SDI TX/RX
set_property PACKAGE_PIN A3 [get_ports gth3_rx_n]
set_property PACKAGE_PIN A4 [get_ports gth3_rx_p]
set_property PACKAGE_PIN A7 [get_ports gth3_tx_n]
set_property PACKAGE_PIN A8 [get_ports gth3_tx_p]
#148.5 MHz Clock
set_property PACKAGE_PIN D9 [get_ports gth_refclk0_clk_n]
set_property PACKAGE_PIN D10 [get_ports gth_refclk0_clk_p]
create_clock -period 6.734 -waveform {0.000 3.367} [get_ports gth_refclk0_clk_p]
