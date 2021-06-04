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
		
		input wire LVDS_STATE_CLEAR_CS,
		input wire LVDS_STATE_CLEAR
	);


	reg[8:0] BUFF_WADDR;
	reg[31:0] BUFF_WD_wire;
	reg BUFF_WEN;
	
	reg[31:0] BUFF_A;
	reg[4:0] BUFF_A_CNT;
	reg[31:0] BUFF_B;
	reg[4:0] BUFF_B_CNT;
	
	reg CRC_ERR;
	parameter isCRC_ERR = 1;
	parameter noCRC_ERR = 0;
	
	
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
	parameter RX_FSM_WAITE_CRC	= 16'h0008;
	parameter RX_FSM_OVER		= 16'h0004;
	
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
							if(
								(BUFF_A_CNT >= 31)
								&&(BUFF_WADDR < 511)
								)
								begin
									RX_FSM_next = RX_FSM_LBUFB;
								end
							else if(
								(BUFF_A_CNT >= 31)
								&&(BUFF_WADDR >= 511)
								)
								begin
									RX_FSM_next = RX_FSM_OVER;
								end
							else
								begin
									RX_FSM_next = RX_FSM_LBUFA;
								end
						end
					RX_FSM_LBUFB	:	
						begin
							if(
									(BUFF_WADDR >= 511)
									&&(BUFF_B_CNT >= 30)
								)
								begin
									RX_FSM_next = RX_FSM_OVER;
								end
							else if
								(
									(BUFF_B_CNT >= 31)
									&&(BUFF_WADDR < 511)
								)
								begin
									RX_FSM_next = RX_FSM_LBUFA;
								end
							else
								begin
									RX_FSM_next = RX_FSM_LBUFB;
								end
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
				LVDS_EU_STATE = 0;
			end
		else
			begin
				case(RX_FSM_current)
					RX_FSM_IDLE		:
						begin
							BUFF_WEN = 0;
							BUFF_WD_wire = 0;
							if(
								(LVDS_STATE_CLEAR_CS == 1)
								&&(LVDS_STATE_CLEAR)
							)
								begin
									LVDS_EU_STATE = 0;
								end
						end
					RX_FSM_LBUFA	:
						begin
							LVDS_EU_STATE = 1;
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
							LVDS_EU_STATE = 1;
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
					RX_FSM_OVER	    :
						begin
							LVDS_EU_STATE = 2;
							BUFF_WEN = 0;
							BUFF_WD_wire = 0;
						end
					default:
						begin
							LVDS_EU_STATE = 0;
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
			.Init_Value = 32'h0;
		)
		CRC_inst(
			.CLK(LVDS_CLK),
			.RSTn(RSTn),
			.CRC_ENABLE(CRC_ENABLE),
			.CRC_Init(CRC_INIT),
			.DATA_Serial_Stream(LVDS_DATA),
			.CRC_Resault(CRC_VAL)
		);
		
	always@(*)
	begin
		if(RSTn == 0)
			begin
				CRC_ENABLE <= 0;
				
			end
		else
			begin
				if(BUFF_WADDR >= 4)
			end
	end
	
endmodule