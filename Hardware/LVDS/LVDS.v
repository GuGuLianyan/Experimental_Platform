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
	wire[31:0] BUFF_WD_wire;
	reg BUFF_WEN;
	
	TPLSRAM_32x512BIT BUFF(
			.RCLK(CLK),
			.RADDR(EU_LVDS_BUF_ADDR),
			.WCLK(CLK),
			.WADDR(BUFF_WADDR),
			.WD(BUFF_WD),
			.WEN(BUFF_WEN),
			// Outputs
			.RD(EU_LVDS_BUF_DATA)				
							);
	
	reg[15:0] RX_FSM_current;
	reg[15:0] RX_FSM_next;
	parameter RX_FSM_IDLE		= 16'h0000;
	parameter RX_FSM_LBUFA		= 16'h0001;
	parameter RX_FSM_LBUFB		= 16'h0002;
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
							if(LVDS_VS)
						end
					RX_FSM_LBUFA	:	
						begin
							
						end
					RX_FSM_LBUFB	:	
						begin
							
						end
					RX_FSM_OVER		:
						begin
							
						end
					default:
						begin
							
						end
				endcase
			end
	end
	
	
	
	
	
	