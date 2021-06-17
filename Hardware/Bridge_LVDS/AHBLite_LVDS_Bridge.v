`include "AHBLite_LVDS_Bridge_CFG.v"

module AHBLite_LVDS_Bridge
	#(
		parameter LVDS_BUF_ADDR_SIZE = 9
		
	)
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
////////////LVDS Module Interface/////////////////
		output wire[LVDS_BUF_ADDR_SIZE-1 : 0] EU_LVDS_BUF_ADDR,
		input wire[31:0] EU1_LVDS_BUF_DATA,
		input wire[31:0] EU2_LVDS_BUF_DATA,
		input wire[31:0] EU3_LVDS_BUF_DATA,
		input wire[31:0] EU4_LVDS_BUF_DATA,
		
		input wire[7:0] LVDS_EU1_STATE,
		input wire[7:0] LVDS_EU2_STATE,
		input wire[7:0] LVDS_EU3_STATE,
		input wire[7:0] LVDS_EU4_STATE,
		
		output wire LVDS_EU1,
		output wire LVDS_EU2,
		output wire LVDS_EU3,
		output wire LVDS_EU4,
		output reg RX_STATE_CLEAR
	);
	
	
	reg[3:0] LVDS_RX_STATE_ADDR;
	assign LVDS_EU1 = LVDS_RX_STATE_ADDR[0:0];
	assign LVDS_EU2 = LVDS_RX_STATE_ADDR[1:1];
	assign LVDS_EU3 = LVDS_RX_STATE_ADDR[2:2];
	assign LVDS_EU4 = LVDS_RX_STATE_ADDR[3:3];
	
	reg[31 : 0] EU_INTER_ADDR;
	assign EU_LVDS_BUF_ADDR = EU_INTER_ADDR[10:2];

	
	reg[15:0] AHB_Lite_FSM_current;
	reg[15:0] AHB_Lite_FSM_next;
	
	parameter AHB_Lite_FSM_Wait_HSEL			= 16'h0000;
	parameter AHB_Lite_FSM_Read_State			= 16'h0001;
	parameter AHB_Lite_FSM_Read_State_OVER		= 16'h0002;
	parameter AHB_Lite_FSM_State_Clear			= 16'h0004;
	parameter AHB_Lite_FSM_State_Clear_OVER		= 16'h0008;
	parameter AHB_Lite_FSM_Read_BUFF			= 16'h0010;
	parameter AHB_Lite_FSM_Read_BUFF_OVER		= 16'h0020;
	
	always@(posedge HCLK or negedge HRESETn)
	begin
		if(HRESETn == 0)
			begin
				AHB_Lite_FSM_current <= AHB_Lite_FSM_Wait_HSEL;
			end
		else
			begin
				AHB_Lite_FSM_current <= AHB_Lite_FSM_next;
			end
	end
	

	always@(*)
	begin
		if(HRESETn == 0)
			begin
				AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
			end
		else
			begin
				case(AHB_Lite_FSM_current)
					AHB_Lite_FSM_Wait_HSEL			:
						begin
							if(HSEL == 1)
								begin
									if(HWRITE == 1)
										begin
											if(
												(HADDR & 8'h0F) != 0
											)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_State_Clear;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
												end
										end
									else
										begin
											if(
												(HADDR >= `AHBLite_LVDS_Bridge_BASE_ADDR)
												&&(HADDR < (`AHBLite_LVDS_Bridge_BASE_ADDR + 4))
											)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Read_State;
												end
											else if(
												(HADDR >= `AHBLite_LVDS_BUFF_BASE_ADDR)
												&&(HADDR <= `AHBLite_LVDS_BUFF_END_ADDR)
											)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Read_BUFF;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
												end
										end
								end
						end
					AHB_Lite_FSM_Read_State		    :
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
						end
					AHB_Lite_FSM_State_Clear		:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_State_Clear_OVER;
						end
					AHB_Lite_FSM_State_Clear_OVER	:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
						end
					AHB_Lite_FSM_Read_BUFF		    :
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
						end
					default                         :
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_HSEL;
						end
				endcase
			end
	end
	
	parameter HREADYOUT_RDY = 1'b1;
	parameter HREADYOUT_BSY = 1'b0;
	parameter HRESP_OKAY = 1'b0;
	parameter isRX_STATE_CLEAR = 1'b1;
	parameter notRX_STATE_CLEAR = 1'b0;
	
	reg[1:0] EU_Slect;
	
	always@(posedge HCLK or negedge HRESETn)
	begin
		if(HRESETn == 0)
			begin
				HREADYOUT <= HREADYOUT_RDY;
				HRESP <= HRESP_OKAY;
				EU_INTER_ADDR <= 0;
				LVDS_RX_STATE_ADDR <= 0;
				RX_STATE_CLEAR <= notRX_STATE_CLEAR;
			end
		else
			begin
				case(AHB_Lite_FSM_current)
					AHB_Lite_FSM_Wait_HSEL			:
						begin
							if(HSEL == 1)
								begin
									if(HWRITE == 1)
										begin
											if(
												(HADDR & 8'h0F) != 0
											)
												begin
													LVDS_RX_STATE_ADDR <= HADDR[3:0];
													RX_STATE_CLEAR <= isRX_STATE_CLEAR;
													HREADYOUT <= HREADYOUT_BSY;
												end
											else
												begin
													LVDS_RX_STATE_ADDR <= 0;
													HREADYOUT <= HREADYOUT_RDY;
													RX_STATE_CLEAR <= notRX_STATE_CLEAR;
												end
										end
									else
										begin
											if(
												(HADDR == `AHBLite_LVDS_EU1_STATE)
												||(HADDR == `AHBLite_LVDS_EU2_STATE)
												||(HADDR == `AHBLite_LVDS_EU3_STATE)
												||(HADDR == `AHBLite_LVDS_EU4_STATE)
											)
												begin
													LVDS_RX_STATE_ADDR <= (HADDR - `AHBLite_LVDS_Bridge_BASE_ADDR);
													RX_STATE_CLEAR <= notRX_STATE_CLEAR;
													HREADYOUT <= HREADYOUT_BSY;
												end
											else if(
												(HADDR >= `AHBLite_LVDS_BUFF_BASE_ADDR)
												&&(HADDR <= `AHBLite_LVDS_BUFF_END_ADDR)
											)
												begin
													EU_INTER_ADDR <= HADDR;
													HREADYOUT <= HREADYOUT_BSY;
													if(
														(HADDR >= `AHBLite_LVDS_BUFF_BASE_ADDR)
														&&(HADDR < (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h800))
													)
														begin
															EU_Slect <= 0;
														end
													else if(
														(HADDR >= (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h800))
														&&(HADDR < (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h1000))
													)
														begin
															EU_Slect <= 1;
														end
													else if(
														(HADDR >= (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h1000))
														&&(HADDR < (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h1800))
													)
														begin
															EU_Slect <= 2;
														end
													else if(
														(HADDR >= (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h1800))
														&&(HADDR < (`AHBLite_LVDS_BUFF_BASE_ADDR + 32'h2000))
													)
														begin
															EU_Slect <= 3;
														end
													else
														begin
															EU_Slect <= 0;
														end
												end
											else
												begin
													HREADYOUT <= HREADYOUT_RDY;
												end
										end
								end
						end
					AHB_Lite_FSM_Read_State		    :
						begin
							HRDATA <= {LVDS_EU1_STATE, LVDS_EU2_STATE, LVDS_EU3_STATE, LVDS_EU4_STATE};
							HREADYOUT <= HREADYOUT_RDY;
						end
					AHB_Lite_FSM_State_Clear		:
						begin
							RX_STATE_CLEAR <= isRX_STATE_CLEAR;
							HREADYOUT <= HREADYOUT_BSY;
						end
					AHB_Lite_FSM_State_Clear_OVER	:
						begin
							RX_STATE_CLEAR <= notRX_STATE_CLEAR;
							HREADYOUT <= HREADYOUT_RDY;
						end
					AHB_Lite_FSM_Read_BUFF		    :
						begin
							case(EU_Slect)
								0:
									begin
										HRDATA <= EU1_LVDS_BUF_DATA;
									end
								1:
									begin
										HRDATA <= EU2_LVDS_BUF_DATA;
									end
								2:
									begin
										HRDATA <= EU3_LVDS_BUF_DATA;
									end
								3:
									begin
										HRDATA <= EU4_LVDS_BUF_DATA;
									end
								default:
									begin
										HRDATA <= 0;
									end
							endcase
							HREADYOUT <= HREADYOUT_RDY;
						end
					default                         :
						begin
							HREADYOUT <= HREADYOUT_RDY;
						end
				endcase
			end
	end
	
	
	
	
	
	
endmodule