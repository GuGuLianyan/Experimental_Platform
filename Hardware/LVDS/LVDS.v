`timescale 1ps/1ps
module LVDS
	(
		input wire LVDS_VS,
		input wire LVDS_CLK,
		input wire LVDS_DATA,
		
		input wire CLK,
		input wire RSTn,
		
		output wire[31:0] EU_LVDS_BUF_DATA,
		input wire[8:0] EU_LVDS_BUF_ADDR,
		
		output reg[7:0] LVDS_EU_STATE,
		output wire LVDS_EU_Interrupt,
		
		input wire LVDS_STATE_CLEAR_CS,
		input wire LVDS_STATE_CLEAR
	);


	reg[8:0] BUFF_WADDR;
	parameter BUFF_WADDR_limit = 2047;
	
	reg[31:0] BUFF_WD_wire;
	reg BUFF_WEN;
	
	reg[31:0] BUFF_A;
	reg[4:0] BUFF_A_CNT;
	reg[31:0] BUFF_B;
	reg[4:0] BUFF_B_CNT;
	
	
	TPLSRAM_32x512BIT BUFF(
			.RCLK(CLK),
			.RADDR(EU_LVDS_BUF_ADDR),
			.WCLK(LVDS_CLK),
			.WADDR(BUFF_WADDR),
			.WD(BUFF_WD_wire),
			.WEN(BUFF_WEN),
			// Outputs
			.RD(EU_LVDS_BUF_DATA)				
							);
	
	reg[15:0] RX_FSM_current;
	reg[15:0] RX_FSM_next;
	parameter RX_FSM_IDLE		= 16'h0000;
	parameter RX_FSM_LBUFA		= 16'h0001;
	parameter RX_FSM_LBUFB		= 16'h0002;
	parameter RX_FSM_WAITE_CRC	= 16'h0004;
	parameter RX_FSM_OVER		= 16'h0008;
	
	always@(posedge LVDS_CLK or negedge RSTn)
	begin
		if(RSTn == 0)
			begin
				RX_FSM_current <= RX_FSM_IDLE;
			end
		else
			begin
				RX_FSM_current <= RX_FSM_next;
			end
	end
	
	always@(*)
	begin
		if(RSTn == 0)
			begin
				RX_FSM_next = RX_FSM_IDLE;
			end
		else
			begin
				case(RX_FSM_current)
					RX_FSM_IDLE		:
						begin
							if(LVDS_VS == 0)
								begin
									RX_FSM_next = RX_FSM_LBUFA;
								end
							else
								begin
									RX_FSM_next = RX_FSM_IDLE;
								end
						end
					RX_FSM_LBUFA	:	
						begin
							if(LVDS_VS == 1)
								begin
									RX_FSM_next = RX_FSM_WAITE_CRC;
								end
							else
								begin
									if(
										(BUFF_A_CNT >= 31)
										&&(BUFF_WADDR < BUFF_WADDR_limit)
										)
										begin
											RX_FSM_next = RX_FSM_LBUFB;
										end
									else if(
										(BUFF_A_CNT >= 31)
										&&(BUFF_WADDR >= BUFF_WADDR_limit)
										)
										begin
											RX_FSM_next = RX_FSM_WAITE_CRC;
										end
									else
										begin
											RX_FSM_next = RX_FSM_LBUFA;
										end
								end
						end
					RX_FSM_LBUFB	:	
						begin
							if(LVDS_VS == 1)
								begin
									RX_FSM_next = RX_FSM_WAITE_CRC;
								end
							else
								begin
									if(
											(BUFF_WADDR >= BUFF_WADDR_limit)
										)
										begin
											RX_FSM_next = RX_FSM_WAITE_CRC;
										end
									else if
										(
											(BUFF_B_CNT >= 31)
											&&(BUFF_WADDR < BUFF_WADDR_limit)
										)
										begin
											RX_FSM_next = RX_FSM_LBUFA;
										end
									else
										begin
											RX_FSM_next = RX_FSM_LBUFB;
										end
								end
						end
					RX_FSM_WAITE_CRC:
						begin
							RX_FSM_next = RX_FSM_OVER;
						end
					RX_FSM_OVER		:
						begin
							RX_FSM_next = RX_FSM_IDLE;
						end
					default:
						begin
							RX_FSM_next = RX_FSM_IDLE;
						end
				endcase
			end
	end
	
	always@(posedge LVDS_CLK or negedge RSTn)
	begin
		if(RSTn == 0)
			begin
				BUFF_A <= 0;
				BUFF_B <= 0;
				BUFF_A_CNT <= 0;
				BUFF_B_CNT <= 0;
				BUFF_WADDR <= 0;
			end
		else
			begin
				case(RX_FSM_current)
					RX_FSM_IDLE		:
						begin
							BUFF_B <= 0;
							BUFF_A_CNT <= 1;
							BUFF_B_CNT <= 0;
							BUFF_WADDR <= 0;
							BUFF_A <= {7'h00,LVDS_DATA};
						end
					RX_FSM_LBUFA	:
						begin
							BUFF_A <= (BUFF_A << 1) | LVDS_DATA;
							BUFF_A_CNT <= BUFF_A_CNT + 1;
							if(BUFF_A_CNT >= 31)
								begin
									if(BUFF_WADDR == 0)
										begin
											BUFF_WADDR <= BUFF_WADDR ;
										end
									else
										begin
											BUFF_WADDR <= BUFF_WADDR + 1;
										end
									
									BUFF_B <= 0;
									BUFF_B_CNT <= 0;
								end
						end
					RX_FSM_LBUFB	:
						begin
							BUFF_B <= (BUFF_B << 1) | LVDS_DATA;
							BUFF_B_CNT <= BUFF_B_CNT + 1;
							if(BUFF_B_CNT >= 31)
								begin
									BUFF_WADDR <= BUFF_WADDR + 1;
									
									BUFF_A <= 0;
									BUFF_A_CNT <= 0;
								end
						end
					RX_FSM_OVER	    :
						begin
							BUFF_A <= 0;
							BUFF_A_CNT <= 0;
							
						end
					default:
						begin
							BUFF_A <= 0;
							BUFF_B <= 0;
							BUFF_A_CNT <= 0;
							BUFF_B_CNT <= 0;
							BUFF_WADDR <= 0;
						end
				endcase
			end
	end
	
	
	always@(*)
	begin
		if(RSTn == 0)
			begin
				BUFF_WEN = 0;
				BUFF_WD_wire = 0;
			end
		else
			begin
				case(RX_FSM_current)
					RX_FSM_IDLE		:
						begin
							BUFF_WEN = 0;
							BUFF_WD_wire = 0;
						end
					RX_FSM_LBUFA	:
						begin
							if(BUFF_A_CNT != 31)
								begin
									if(BUFF_WADDR == 0)
										begin
											BUFF_WEN = 0;
											BUFF_WD_wire = 0;
										end
									else
										begin
											BUFF_WEN = 1;
											BUFF_WD_wire = BUFF_B;
										end
								end
							else
								begin
									BUFF_WEN = 0;
									BUFF_WD_wire = 0;
								end
						end
					RX_FSM_LBUFB	:
						begin
							if(BUFF_B_CNT != 31)
								begin
									BUFF_WEN = 1;
									BUFF_WD_wire = BUFF_A;
								end
							else
								begin
									BUFF_WEN = 0;
									BUFF_WD_wire = 0;
								end
						end
					RX_FSM_WAITE_CRC :
						begin
							BUFF_WEN = 1;
							BUFF_WD_wire = BUFF_B;
						end
					RX_FSM_OVER   :
						begin
							BUFF_WEN = 0;
							BUFF_WD_wire = 0;
						end
					default:
						begin
							BUFF_WEN = 0;
							BUFF_WD_wire = 0;
						end
				endcase
			end
	end
	
	
	reg CRC_ENABLE;
	reg CRC_INIT;
	wire[31:0] CRC_VAL;
	CRC32
		#(
			.Init_Value(32'h0)
		)
		CRC_inst(
			.CLK(LVDS_CLK),
			.RSTn(RSTn),
			.CRC_ENABLE(CRC_ENABLE),
			.CRC_Init(CRC_INIT),
			.DATA_Serial_Stream(LVDS_DATA),
			.CRC_Resault(CRC_VAL)
		);
	
	assign LVDS_EU_Interrupt = LVDS_EU_STATE[1:1];
	
	always@(posedge LVDS_CLK or negedge RSTn)
	begin
		if(RSTn == 0)
			begin
				LVDS_EU_STATE <= 0;
			end
		else
			begin
				if(
					(LVDS_STATE_CLEAR_CS == 1)
					&&(LVDS_STATE_CLEAR == 1)
				)
					begin
						LVDS_EU_STATE <= 0;
					end
				else
					begin
						case(RX_FSM_current)
							RX_FSM_IDLE		:
								begin
									LVDS_EU_STATE <= LVDS_EU_STATE;
								end
							RX_FSM_LBUFA,RX_FSM_LBUFB	:	
								begin
									LVDS_EU_STATE <= 1;
								end
							RX_FSM_WAITE_CRC:	
								begin
									if(CRC_VAL == 0)
										begin
											LVDS_EU_STATE <= 1;
										end
									else
										begin
											LVDS_EU_STATE <= 5;
										end
								end
							RX_FSM_OVER		:
								begin
									LVDS_EU_STATE[1:0] <= 2;
								end
							default:
								begin
									LVDS_EU_STATE <= 0;
								end
						endcase
					end
			end
	end
	
	
	always@(*)
	begin
		if(RSTn == 0)
			begin
				CRC_ENABLE = 0;
				CRC_INIT = 1;
			end
		else
			begin
				case(RX_FSM_current)
					RX_FSM_IDLE,RX_FSM_OVER	:
						begin
							CRC_ENABLE = 0;
							CRC_INIT = 1;
						end
					RX_FSM_LBUFA,RX_FSM_LBUFB	:	
						begin
							if(
								(BUFF_WADDR == 0)
								&&(RX_FSM_current == RX_FSM_LBUFB)
								)
								begin
									CRC_ENABLE = 1;
									CRC_INIT = 0;
								end
							else if(LVDS_VS == 1)
								begin
									CRC_ENABLE = 0;
									CRC_INIT = 0;
								end
							else
								begin
									CRC_ENABLE = CRC_ENABLE;
									CRC_INIT = CRC_INIT;
								end
						end
					RX_FSM_WAITE_CRC:	
						begin
							CRC_ENABLE = 0;
							CRC_INIT = 0;
						end
					default:
						begin
							CRC_ENABLE = 0;
							CRC_INIT = 1;
						end
				endcase
			end
	end
	
endmodule