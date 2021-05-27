`ifndef AHBLite_CAN_Bridge_CFG
	`define AHBLite_CAN_Bridge_CFG
	
	`define NAND_Bridge_ADDR						32'h0000_0000
	`define NAND_Bridge_DATA						32'h0000_0004
	`define NAND_Bridge_CMD							32'h0000_0008
	`define NAND_Bridge_Operate_Over_Resaultreg		32'h0000_000C
	`define NAND_Bridge_IN_DATA_CNT_reg				32'h0000_000D
	`define NAND_Bridge_OUT_DATA_CNT_reg			32'h0000_000E
	`define NAND_Bridge_OUT_DATA					32'h0000_000F
`endif