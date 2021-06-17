`ifndef AHBLite_LVDS_Bridge_CFG
	`define AHBLite_LVDS_Bridge_CFG
	`define AHBLite_LVDS_Bridge_BASE_ADDR		32'h8000_0000
	`define AHBLite_LVDS_EU1_STATE				(`AHBLite_LVDS_Bridge_BASE_ADDR)
	`define AHBLite_LVDS_EU2_STATE				(`AHBLite_LVDS_Bridge_BASE_ADDR + 1)
	`define AHBLite_LVDS_EU3_STATE				(`AHBLite_LVDS_Bridge_BASE_ADDR + 2)
	`define AHBLite_LVDS_EU4_STATE				(`AHBLite_LVDS_Bridge_BASE_ADDR + 3)
	`define AHBLite_LVDS_BUFF_BASE_ADDR			(`AHBLite_LVDS_Bridge_BASE_ADDR + 32'h0000_1000)
	`define AHBLite_LVDS_BUFF_END_ADDR			(`AHBLite_LVDS_Bridge_BASE_ADDR + 32'h0000_2FFF)
`endif