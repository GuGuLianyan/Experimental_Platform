module Interrupt(
		output wire[15:0] ARM_Interrupt,
		input wire CAN_A_U_Interrupt,
		input wire CAN_A_S_Interrupt,
		input wire CAN_B_U_Interrupt,
		input wire CAN_B_S_Interrupt,
		input wire BUS1553_Interrupt
		
		/*
		input wire LVDS_Interrupt,
		*/
				);
		assign ARM_Interrupt = {11'h000, 
								BUS1553_Interrupt, 
								CAN_B_S_Interrupt,
								CAN_B_U_Interrupt,
								CAN_A_S_Interrupt,
								CAN_A_U_Interrupt};

endmodule