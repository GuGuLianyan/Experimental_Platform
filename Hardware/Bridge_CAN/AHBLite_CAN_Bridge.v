`include "AHBLite_CAN_Bridge_CFG.v"

module AHBLite_CAN_Bridge
		(
////////////AHB-Lite Interface/////////////////
			//Global Signal
			input wire HRESETn,
			input wire HCLK,
			//Select Signal
			input wire HSEL,
			//input
			input wire[31:0] HADDR,
			input wire HWRITE,
			input wire[2:0] HSIZE,
			input wire[2:0] HBURST,
			input wire[3:0] HPROT,
			input wire[1:0] HTRANS,
			input wire HMASTLOCK,
			input wire HREADY,
			input wire[31:0] HWDATA,
			//output
			output reg[31:0] HRDATA,
			output reg HREADYOUT,
			output reg HRESP,
////////////CAN Interface////////////////////
			input wire CAN_CLK,
			output reg CAN_RST,
			
			output reg CAN_A_ALE,
			output reg CAN_A_RD,
			output reg CAN_A_WR,
			output reg CAN_A_CS,
			inout wire[7:0] CAN_A_Port,

			
			output reg CAN_B_ALE,
			output reg CAN_B_RD,
			output reg CAN_B_WR,
			output reg CAN_B_CS,
			inout wire[7:0] CAN_B_Port,
			
			output reg CAN_C_ALE,
			output reg CAN_C_RD,
			output reg CAN_C_WR,
			output reg CAN_C_CS,
			inout wire[7:0] CAN_C_Port,
			
			output reg CAN_D_ALE,
			output reg CAN_D_RD,
			output reg CAN_D_WR,
			output reg CAN_D_CS,
			inout wire[7:0] CAN_D_Port
			

		);
	
	reg[15:0] AHB_Lite_FSM_current;
	reg[15:0] AHB_Lite_FSM_next;

	parameter AHB_Lite_FSM_Get_ADDR				= 16'h0000;
	parameter AHB_Lite_FSM_Get_Data_2_CAN_A		= 16'h0001;
	parameter AHB_Lite_FSM_Get_Data_2_CAN_B		= 16'h0002;
	parameter AHB_Lite_FSM_Get_Data_2_CAN_C		= 16'h0004;
	parameter AHB_Lite_FSM_Get_Data_2_CAN_D		= 16'h0008;
	parameter AHB_Lite_FSM_Wait_CAN_A_Write		= 16'h0010;
	parameter AHB_Lite_FSM_Wait_CAN_B_Write		= 16'h0020;
	parameter AHB_Lite_FSM_Wait_CAN_C_Write		= 16'h0040;
	parameter AHB_Lite_FSM_Wait_CAN_D_Write		= 16'h0080;
	parameter AHB_Lite_FSM_Wait_CAN_A_Read		= 16'h0100;
	parameter AHB_Lite_FSM_Wait_CAN_B_Read		= 16'h0200;
	parameter AHB_Lite_FSM_Wait_CAN_C_Read		= 16'h0400;
	parameter AHB_Lite_FSM_Wait_CAN_D_Read		= 16'h0800;
	parameter AHB_Lite_FSM_Send_Data			= 16'h1000;
	parameter AHB_Lite_FSM_Read_Addr_Err		= 16'h2000;
	
	reg[31:0] HADDR_Continue;
	
	reg CAN_A_W_or_R_isOver;
	reg CAN_B_W_or_R_isOver;
	reg CAN_C_W_or_R_isOver;
	reg CAN_D_W_or_R_isOver;
	
	reg[7:0] CAN_A_Register;
	reg[7:0] CAN_B_Register;
	reg[7:0] CAN_C_Register;
	reg[7:0] CAN_D_Register;
	
	reg[7:0] CAN_A_Data;
	reg[7:0] CAN_B_Data;
	reg[7:0] CAN_C_Data;
	reg[7:0] CAN_D_Data;
	
	always@(posedge HCLK or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				AHB_Lite_FSM_current <= AHB_Lite_FSM_Get_ADDR;
			end
		else
			begin
				AHB_Lite_FSM_current <= AHB_Lite_FSM_next;
			end
	end
	
	always@(*)
	begin
		if(HRESETn == 1'b0)
			begin
				AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
			end
		else
			begin
				case(AHB_Lite_FSM_current)
					AHB_Lite_FSM_Get_ADDR:
						begin
							if(HSEL == 1'b1)
								begin
									if(
										(HADDR >= `CAN_A_ADDR_ABSOLUTE)
										&&(HADDR <= (`CAN_A_ADDR_ABSOLUTE + `CAN_Register_Num))
									)
										begin
											if(HWRITE == 1'b1)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data_2_CAN_A;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_A_Read;
												end
										end
									else if(
												(HADDR >= `CAN_B_ADDR_ABSOLUTE)
												&&(HADDR <= (`CAN_B_ADDR_ABSOLUTE + `CAN_Register_Num))
											)
										begin
											if(HWRITE == 1'b1)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data_2_CAN_B;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_B_Read;
												end
										end
									else if(
												(HADDR >= `CAN_C_ADDR_ABSOLUTE)
												&&(HADDR <= (`CAN_C_ADDR_ABSOLUTE + `CAN_Register_Num))
											)
										begin
											if(HWRITE == 1'b1)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data_2_CAN_C;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_C_Read;
												end
										end
									else if(
												(HADDR >= `CAN_D_ADDR_ABSOLUTE)
												&&(HADDR <= (`CAN_D_ADDR_ABSOLUTE + `CAN_Register_Num))
											)
										begin
											if(HWRITE == 1'b1)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data_2_CAN_D;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_D_Read;
												end
										end
									else
										begin
											if(HWRITE == 0)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Read_Addr_Err;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
												end
										end
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
						end
					AHB_Lite_FSM_Get_Data_2_CAN_A:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_A_Write;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_B:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_B_Write;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_C:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_C_Write;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_D:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_D_Write;
						end
					AHB_Lite_FSM_Wait_CAN_A_Write:
						begin
							if(CAN_A_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_A_Write;
								end
						end
					AHB_Lite_FSM_Wait_CAN_B_Write:
						begin
							if(CAN_B_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_B_Write;
								end
						end
					AHB_Lite_FSM_Wait_CAN_C_Write:
						begin
							if(CAN_C_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_C_Write;
								end
						end	
					AHB_Lite_FSM_Wait_CAN_D_Write:
						begin
							if(CAN_D_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_D_Write;
								end
						end
					AHB_Lite_FSM_Wait_CAN_A_Read:
						begin
							if(CAN_A_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Send_Data;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_A_Read;
								end
						end
					AHB_Lite_FSM_Wait_CAN_B_Read:
						begin
							if(CAN_B_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Send_Data;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_B_Read;
								end
						end
					AHB_Lite_FSM_Wait_CAN_C_Read:
						begin
							if(CAN_C_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Send_Data;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_C_Read;
								end
						end
					AHB_Lite_FSM_Wait_CAN_D_Read:
						begin
							if(CAN_D_W_or_R_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Send_Data;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_CAN_D_Read;
								end
						end
					AHB_Lite_FSM_Send_Data:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
						end
					AHB_Lite_FSM_Read_Addr_Err:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
						end
					default:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
						end
				endcase
			end
	end
	
	parameter HREADYOUT_RDY = 1'b1;
	parameter HREADYOUT_BSY = 1'b0;
	parameter HRESP_OKAY = 1'b0;
	always@(posedge HCLK or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				CAN_A_Register <= 0;
				CAN_B_Register <= 0;
				CAN_A_Data <= 0;
				CAN_B_Data <= 0;
				HREADYOUT <= HREADYOUT_RDY;
				HRESP <= HRESP_OKAY;
			end
		else
			begin
				case(AHB_Lite_FSM_current)
					AHB_Lite_FSM_Get_ADDR:
						begin
							if(HSEL == 1'b1)
								begin
									if(
										(HADDR >= `CAN_A_ADDR_ABSOLUTE)
										&&(HADDR <= (`CAN_A_ADDR_ABSOLUTE + `CAN_Register_Num))
										)
										begin
											CAN_A_Register <= HADDR - `CAN_A_ADDR_ABSOLUTE;
											CAN_B_Register <= 0;
											CAN_C_Register <= 0;
											CAN_D_Register <= 0;
											HREADYOUT <= HREADYOUT_BSY;
										end
									else if(
										(HADDR >= `CAN_B_ADDR_ABSOLUTE)
										&&(HADDR <= (`CAN_B_ADDR_ABSOLUTE + `CAN_Register_Num))
										)
										begin
											CAN_B_Register <= HADDR - `CAN_B_ADDR_ABSOLUTE;
											CAN_A_Register <= 0;
											CAN_C_Register <= 0;
											CAN_D_Register <= 0;
											HREADYOUT <= HREADYOUT_BSY;
										end
									else if(
										(HADDR >= `CAN_C_ADDR_ABSOLUTE)
										&&(HADDR <= (`CAN_C_ADDR_ABSOLUTE + `CAN_Register_Num))
										)
										begin
											CAN_C_Register <= HADDR - `CAN_C_ADDR_ABSOLUTE;
											CAN_A_Register <= 0;
											CAN_B_Register <= 0;
											CAN_D_Register <= 0;
											HREADYOUT <= HREADYOUT_BSY;
										end
									else if(
										(HADDR >= `CAN_D_ADDR_ABSOLUTE)
										&&(HADDR <= (`CAN_D_ADDR_ABSOLUTE + `CAN_Register_Num))
										)
										begin
											CAN_D_Register <= HADDR - `CAN_D_ADDR_ABSOLUTE;
											CAN_A_Register <= 0;
											CAN_C_Register <= 0;
											CAN_B_Register <= 0;
											HREADYOUT <= HREADYOUT_BSY;
										end
									else
										begin
											CAN_B_Register <= 0;
											CAN_A_Register <= 0;
											CAN_C_Register <= 0;
											CAN_D_Register <= 0;
											HREADYOUT <= HREADYOUT_RDY;
										end
								end
							else
								begin
									CAN_B_Register <= 0;
									CAN_A_Register <= 0;
									CAN_C_Register <= 0;
									CAN_D_Register <= 0;
									HREADYOUT <= HREADYOUT_RDY;
								end
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HRESP <= HRESP_OKAY;
							HADDR_Continue <= HADDR;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_A:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= HWDATA[7:0];
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_B:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= HWDATA[7:0];
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_C:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= HWDATA[7:0];
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Get_Data_2_CAN_D:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= HWDATA[7:0];
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_CAN_A_Write:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= HWDATA[7:0];
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_CAN_B_Write:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= HWDATA[7:0];
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_CAN_C_Write:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= HWDATA[7:0];
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_CAN_D_Write:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= HWDATA[7:0];
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_CAN_A_Read, AHB_Lite_FSM_Wait_CAN_B_Read, 
					AHB_Lite_FSM_Wait_CAN_C_Read, AHB_Lite_FSM_Wait_CAN_D_Read:
						begin
							CAN_A_Register <= CAN_A_Register;
							CAN_B_Register <= CAN_B_Register;
							CAN_C_Register <= CAN_C_Register;
							CAN_D_Register <= CAN_D_Register;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Send_Data:
						begin
							CAN_A_Register <= 0;
							CAN_B_Register <= 0;
							CAN_C_Register <= 0;
							CAN_D_Register <= 0;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_RDY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Read_Addr_Err	:
						begin
							CAN_A_Register <= 0;
							CAN_B_Register <= 0;
							CAN_C_Register <= 0;
							CAN_D_Register <= 0;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_RDY;
							HRESP <= HRESP_OKAY;
						end
					default:
						begin
							CAN_A_Register <= 0;
							CAN_B_Register <= 0;
							CAN_C_Register <= 0;
							CAN_D_Register <= 0;
							CAN_A_Data <= 0;
							CAN_B_Data <= 0;
							CAN_C_Data <= 0;
							CAN_D_Data <= 0;
							HREADYOUT <= HREADYOUT_RDY;
							HRESP <= HRESP_OKAY;
						end
				endcase
			end
	end
	
	reg[31:0] CAN_Operate_FSM_current;
	reg[31:0] CAN_Operate_FSM_next;
	parameter CAN_Operate_FSM_IDLE				= 32'h0000_0000;
	parameter CAN_Operate_FSM_A_Latch_ADDR_1st	= 32'h0000_0001;
	parameter CAN_Operate_FSM_A_Latch_ADDR_2nd	= 32'h0000_0002;
	parameter CAN_Operate_FSM_A_Read_Data_1st	= 32'h0000_0004;
	parameter CAN_Operate_FSM_A_Read_Data_2nd	= 32'h0000_0008;
	parameter CAN_Operate_FSM_A_Read_Data_3rd	= 32'h0000_0010;
	parameter CAN_Operate_FSM_A_Write_Data_1st	= 32'h0000_0020;
	parameter CAN_Operate_FSM_A_Write_Data_2nd	= 32'h0000_0040;
	parameter CAN_Operate_FSM_B_Latch_ADDR_1st	= 32'h0000_0080;
	parameter CAN_Operate_FSM_B_Latch_ADDR_2nd	= 32'h0000_0100;
	parameter CAN_Operate_FSM_B_Read_Data_1st	= 32'h0000_0200;
	parameter CAN_Operate_FSM_B_Read_Data_2nd	= 32'h0000_0400;
	parameter CAN_Operate_FSM_B_Read_Data_3rd	= 32'h0000_0800;
	parameter CAN_Operate_FSM_B_Write_Data_1st	= 32'h0000_1000;
	parameter CAN_Operate_FSM_B_Write_Data_2nd	= 32'h0000_2000;
	parameter CAN_Operate_FSM_C_Latch_ADDR_1st	= 32'h0000_4000;
	parameter CAN_Operate_FSM_C_Latch_ADDR_2nd	= 32'h0000_8000;
	parameter CAN_Operate_FSM_C_Read_Data_1st	= 32'h0001_0000;
	parameter CAN_Operate_FSM_C_Read_Data_2nd	= 32'h0002_0000;
	parameter CAN_Operate_FSM_C_Read_Data_3rd	= 32'h0004_0000;
	parameter CAN_Operate_FSM_C_Write_Data_1st	= 32'h0008_0000;
	parameter CAN_Operate_FSM_C_Write_Data_2nd	= 32'h0010_0000;
	parameter CAN_Operate_FSM_D_Latch_ADDR_1st	= 32'h0020_0000;
	parameter CAN_Operate_FSM_D_Latch_ADDR_2nd	= 32'h0040_0000;
	parameter CAN_Operate_FSM_D_Read_Data_1st	= 32'h0080_0000;
	parameter CAN_Operate_FSM_D_Read_Data_2nd	= 32'h0100_0000;
	parameter CAN_Operate_FSM_D_Read_Data_3rd	= 32'h0200_0000;
	parameter CAN_Operate_FSM_D_Write_Data_1st	= 32'h0400_0000;
	parameter CAN_Operate_FSM_D_Write_Data_2nd	= 32'h0800_0000;
	parameter CAN_Operate_FSM_Over				= 32'h1000_0000;
	
	always@(posedge CAN_CLK or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				CAN_Operate_FSM_current <= CAN_Operate_FSM_IDLE;
			end
		else
			begin
				CAN_Operate_FSM_current <= CAN_Operate_FSM_next;
			end
	end
	
	always@(*)
	begin
		if(HRESETn == 1'b0)
			begin
				CAN_Operate_FSM_next = CAN_Operate_FSM_IDLE;
			end
		else
			begin
				case(CAN_Operate_FSM_current)
					CAN_Operate_FSM_IDLE:
						begin
							if(
								(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_A_Write)
								||(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_A_Read)
							)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_A_Latch_ADDR_1st;
								end
							else if(
								(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_B_Write)
								||(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_B_Read)
							)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_B_Latch_ADDR_1st;
								end
							else if(
								(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_C_Write)
								||(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_C_Read)
							)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_C_Latch_ADDR_1st;
								end
							else if(
								(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_D_Write)
								||(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_D_Read)
							)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_D_Latch_ADDR_1st;
								end
							else
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_IDLE;
								end
						end
					CAN_Operate_FSM_A_Latch_ADDR_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_A_Latch_ADDR_2nd;
						end
					CAN_Operate_FSM_A_Latch_ADDR_2nd:
						begin
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_A_Write)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_A_Write_Data_1st;
								end
							else if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_A_Read)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_A_Read_Data_1st;
								end
							else
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
								end
						end
					CAN_Operate_FSM_A_Read_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_A_Read_Data_2nd;
						end
					CAN_Operate_FSM_A_Read_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_A_Read_Data_3rd;
						end
					CAN_Operate_FSM_A_Read_Data_3rd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_A_Write_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_A_Write_Data_2nd;
						end
					CAN_Operate_FSM_A_Write_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_B_Latch_ADDR_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_B_Latch_ADDR_2nd;
						end
					CAN_Operate_FSM_B_Latch_ADDR_2nd:
						begin
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_B_Write)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_B_Write_Data_1st;
								end
							else if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_B_Read)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_B_Read_Data_1st;
								end
							else
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
								end
						end
					CAN_Operate_FSM_B_Read_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_B_Read_Data_2nd;
						end
					CAN_Operate_FSM_B_Read_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_B_Read_Data_3rd;
						end
					CAN_Operate_FSM_B_Read_Data_3rd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_B_Write_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_B_Write_Data_2nd;
						end
					CAN_Operate_FSM_B_Write_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_C_Latch_ADDR_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_C_Latch_ADDR_2nd;
						end
					CAN_Operate_FSM_C_Latch_ADDR_2nd:
						begin
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_C_Write)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_C_Write_Data_1st;
								end
							else if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_C_Read)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_C_Read_Data_1st;
								end
							else
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
								end
						end
					CAN_Operate_FSM_C_Read_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_C_Read_Data_2nd;
						end
					CAN_Operate_FSM_C_Read_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_C_Read_Data_3rd;
						end
					CAN_Operate_FSM_C_Read_Data_3rd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_C_Write_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_C_Write_Data_2nd;
						end
					CAN_Operate_FSM_C_Write_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_D_Latch_ADDR_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_D_Latch_ADDR_2nd;
						end
					CAN_Operate_FSM_D_Latch_ADDR_2nd:
						begin
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_D_Write)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_D_Write_Data_1st;
								end
							else if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_CAN_D_Read)
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_D_Read_Data_1st;
								end
							else
								begin
									CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
								end
						end
					CAN_Operate_FSM_D_Read_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_D_Read_Data_2nd;
						end
					CAN_Operate_FSM_D_Read_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_D_Read_Data_3rd;
						end
					CAN_Operate_FSM_D_Read_Data_3rd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_D_Write_Data_1st:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_D_Write_Data_2nd;
						end
					CAN_Operate_FSM_D_Write_Data_2nd:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_Over;
						end
					CAN_Operate_FSM_Over:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_IDLE;
						end
					default:
						begin
							CAN_Operate_FSM_next = CAN_Operate_FSM_IDLE;
						end
				endcase
			end
	end
	
	reg CAN_A_PORT_DIR;
	reg CAN_B_PORT_DIR;
	reg CAN_C_PORT_DIR;
	reg CAN_D_PORT_DIR;
	reg[7:0] CAN_A_OUT_DATA;
	reg[7:0] CAN_B_OUT_DATA;
	reg[7:0] CAN_C_OUT_DATA;
	reg[7:0] CAN_D_OUT_DATA;
	parameter CAN_PORT_DIR_OUT	= 1'b0;
	parameter CAN_PORT_DIR_IN	= 1'b1;
	
	assign CAN_A_Port = (CAN_A_PORT_DIR == CAN_PORT_DIR_OUT)? CAN_A_OUT_DATA : 8'hZZ;
	assign CAN_B_Port = (CAN_B_PORT_DIR == CAN_PORT_DIR_OUT)? CAN_B_OUT_DATA : 8'hZZ;
	assign CAN_C_Port = (CAN_C_PORT_DIR == CAN_PORT_DIR_OUT)? CAN_C_OUT_DATA : 8'hZZ;
	assign CAN_D_Port = (CAN_D_PORT_DIR == CAN_PORT_DIR_OUT)? CAN_D_OUT_DATA : 8'hZZ;
	
	always@(posedge CAN_CLK or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				CAN_RST <= 1'b1;
				HRDATA <= 32'h0000_0000;
				
				CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
				CAN_A_OUT_DATA <= 8'h00;
				CAN_A_W_or_R_isOver <= 1'b0;
				CAN_A_ALE <= 1'b0;
				CAN_A_RD <= 1'b0;
				CAN_A_WR <= 1'b0; 
				CAN_A_CS <= 1'b0;
				
				CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
				CAN_B_OUT_DATA <= 8'h00;
				CAN_B_W_or_R_isOver <= 1'b0;
				CAN_B_ALE <= 1'b0;
				CAN_B_RD <= 1'b0;
				CAN_B_WR <= 1'b0; 
				CAN_B_CS <= 1'b0;
				
				CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
				CAN_C_OUT_DATA <= 8'h00;
				CAN_C_W_or_R_isOver <= 1'b0;
				CAN_C_ALE <= 1'b0;
				CAN_C_RD <= 1'b0;
				CAN_C_WR <= 1'b0; 
				CAN_C_CS <= 1'b0;
				
				CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
				CAN_D_OUT_DATA <= 8'h00;
				CAN_D_W_or_R_isOver <= 1'b0;
				CAN_D_ALE <= 1'b0;
				CAN_D_RD <= 1'b0;
				CAN_D_WR <= 1'b0; 
				CAN_D_CS <= 1'b0;
			end
		else
			begin
				case(CAN_Operate_FSM_current)
					CAN_Operate_FSM_IDLE:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= HRDATA;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Latch_ADDR_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_OUT;	/****/
							CAN_A_OUT_DATA <= CAN_A_Register;	/****/
							CAN_A_W_or_R_isOver <= 1'b0;		/****/
							CAN_A_ALE <= 1'b1;					/****/
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b1;					/****/
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Latch_ADDR_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_OUT;
							CAN_A_OUT_DATA <= CAN_A_Register;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;					/****/
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Read_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;	/****/
							CAN_A_OUT_DATA <= CAN_A_Register;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;					
							CAN_A_RD <= 1'b1;					/****/
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Read_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_A_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_A_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_A_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_A_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= CAN_A_Register;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;					
							CAN_A_RD <= 1'b1;					/****/
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Read_Data_3rd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_A_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_A_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_A_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_A_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= CAN_A_Register;
							CAN_A_W_or_R_isOver <= 1'b1;				/****/
							CAN_A_ALE <= 1'b0;					
							CAN_A_RD <= 1'b1;					
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Write_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_OUT;
							CAN_A_OUT_DATA <= CAN_A_Data;			/****/
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;					
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b1; 						/****/
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_A_Write_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_OUT;
							CAN_A_OUT_DATA <= CAN_A_Data;			
							CAN_A_W_or_R_isOver <= 1'b1;			/****/
							CAN_A_ALE <= 1'b0;					
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 						/****/
							CAN_A_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Latch_ADDR_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_OUT;	/****/
							CAN_B_OUT_DATA <= CAN_B_Register;	/****/
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b1;					/****/
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b1;					/****/
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Latch_ADDR_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_B_OUT_DATA <= CAN_B_Register;	
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;					/****/				
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b1;	
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Read_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;	/****/
							CAN_B_OUT_DATA <= 8'h00;			/****/
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;					/****/				
							CAN_B_RD <= 1'b1;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Read_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_B_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_B_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_B_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_B_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_B_OUT_DATA <= 8'h00;			
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;									
							CAN_B_RD <= 1'b1;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Read_Data_3rd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_B_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_B_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_B_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_B_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_B_OUT_DATA <= 8'h00;			
							CAN_B_W_or_R_isOver <= 1'b1;		/****/
							CAN_B_ALE <= 1'b0;									
							CAN_B_RD <= 1'b1;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Write_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_B_OUT_DATA <= CAN_B_Data;		/****/
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;									
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b1; 					/****/
							CAN_B_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_B_Write_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_B_OUT_DATA <= CAN_B_Data;	
							CAN_B_W_or_R_isOver <= 1'b1;		/****/
							CAN_B_ALE <= 1'b0;									
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 					/****/
							CAN_B_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Latch_ADDR_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_OUT;	/****/
							CAN_C_OUT_DATA <= CAN_B_Register;	/****/
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b1;					/****/
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b1;					/****/
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Latch_ADDR_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_C_OUT_DATA <= CAN_B_Register;	
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;					/****/				
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b1;	
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Read_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;	/****/
							CAN_C_OUT_DATA <= 8'h00;			/****/
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;					/****/				
							CAN_C_RD <= 1'b1;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Read_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_C_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_C_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_C_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_C_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_C_OUT_DATA <= 8'h00;			
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;									
							CAN_C_RD <= 1'b1;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Read_Data_3rd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_C_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_C_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_C_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_C_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_C_OUT_DATA <= 8'h00;			
							CAN_C_W_or_R_isOver <= 1'b1;		/****/
							CAN_C_ALE <= 1'b0;									
							CAN_C_RD <= 1'b1;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Write_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_C_OUT_DATA <= CAN_B_Data;		/****/
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;									
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b1; 					/****/
							CAN_C_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_C_Write_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_C_OUT_DATA <= CAN_B_Data;	
							CAN_C_W_or_R_isOver <= 1'b1;		/****/
							CAN_C_ALE <= 1'b0;									
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 					/****/
							CAN_C_CS <= 1'b1;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Latch_ADDR_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_OUT;	/****/
							CAN_D_OUT_DATA <= CAN_B_Register;	/****/
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b1;					/****/
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b1;					/****/
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Latch_ADDR_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_D_OUT_DATA <= CAN_B_Register;	
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;					/****/				
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b1;	
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Read_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;	/****/
							CAN_D_OUT_DATA <= 8'h00;			/****/
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;					/****/				
							CAN_D_RD <= 1'b1;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Read_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_D_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_D_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_D_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_D_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_D_OUT_DATA <= 8'h00;			
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;									
							CAN_D_RD <= 1'b1;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Read_Data_3rd:
						begin
							CAN_RST <= 1'b0;
							if(HADDR_Continue[1:0] == 0)
								begin
									HRDATA <= {24'h00_0000, CAN_D_Port[7:0]};
								end
							else if(HADDR_Continue[1:0] == 1)
								begin
									HRDATA <= {16'h0000, CAN_D_Port[7:0], 8'h00};
								end
							else if(HADDR_Continue[1:0] == 2)
								begin
									HRDATA <= {8'h00, CAN_D_Port[7:0], 16'h0000};
								end
							else 
								begin
									HRDATA <= {CAN_D_Port[7:0], 24'h00_0000};
								end
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;	
							CAN_D_OUT_DATA <= 8'h00;			
							CAN_D_W_or_R_isOver <= 1'b1;		/****/
							CAN_D_ALE <= 1'b0;									
							CAN_D_RD <= 1'b1;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Write_Data_1st:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_D_OUT_DATA <= CAN_B_Data;		/****/
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;									
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b1; 					/****/
							CAN_D_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_D_Write_Data_2nd:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_OUT;	
							CAN_D_OUT_DATA <= CAN_B_Data;	
							CAN_D_W_or_R_isOver <= 1'b1;		/****/
							CAN_D_ALE <= 1'b0;									
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 					/****/
							CAN_D_CS <= 1'b1;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
						end
					CAN_Operate_FSM_Over:
						begin
							CAN_RST <= 1'b0;
							//HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
					default:
						begin
							CAN_RST <= 1'b0;
							HRDATA <= 32'h0000_0000;
							
							CAN_A_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_A_OUT_DATA <= 8'h00;
							CAN_A_W_or_R_isOver <= 1'b0;
							CAN_A_ALE <= 1'b0;
							CAN_A_RD <= 1'b0;
							CAN_A_WR <= 1'b0; 
							CAN_A_CS <= 1'b0;
							
							CAN_B_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_B_OUT_DATA <= 8'h00;
							CAN_B_W_or_R_isOver <= 1'b0;
							CAN_B_ALE <= 1'b0;
							CAN_B_RD <= 1'b0;
							CAN_B_WR <= 1'b0; 
							CAN_B_CS <= 1'b0;
							
							CAN_C_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_C_OUT_DATA <= 8'h00;
							CAN_C_W_or_R_isOver <= 1'b0;
							CAN_C_ALE <= 1'b0;
							CAN_C_RD <= 1'b0;
							CAN_C_WR <= 1'b0; 
							CAN_C_CS <= 1'b0;
							
							CAN_D_PORT_DIR <= CAN_PORT_DIR_IN;
							CAN_D_OUT_DATA <= 8'h00;
							CAN_D_W_or_R_isOver <= 1'b0;
							CAN_D_ALE <= 1'b0;
							CAN_D_RD <= 1'b0;
							CAN_D_WR <= 1'b0; 
							CAN_D_CS <= 1'b0;
						end
				endcase
			end
	end
	
	
	
endmodule