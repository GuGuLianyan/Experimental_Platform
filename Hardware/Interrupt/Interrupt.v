module Interrupt(
		output wire[15:0] ARM_Interrupt,
		input wire CAN_A_U_Interrupt,
		input wire CAN_A_S_Interrupt,
		input wire CAN_B_U_Interrupt,
		input wire CAN_B_S_Interrupt,
		input wire BUS1553_Interrupt,
		input wire EU_LVDS_1_Interrupt,
		input wire EU_LVDS_2_Interrupt,
		input wire EU_LVDS_3_Interrupt,
		input wire EU_LVDS_4_Interrupt
		
		/*
		input wire LVDS_Interrupt,
		*/
				);
		assign ARM_Interrupt = {7'h00, 
								EU_LVDS_1_Interrupt|
								EU_LVDS_2_Interrupt|
								EU_LVDS_3_Interrupt|
								EU_LVDS_4_Interrupt,
								BUS1553_Interrupt, 
								CAN_B_S_Interrupt,
								CAN_B_U_Interrupt,
								CAN_A_S_Interrupt,
								CAN_A_U_Interrupt};

endmodule