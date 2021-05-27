module NAND_WR_CMD
	#(
		parameter tWP_cnt = 2,
		parameter tHOLD_cnt = 1
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire Start,
		output reg Over,
		
		output reg CLE,
		output reg WEn,
		output reg ALE
		
	);

reg[7:0] WR_CMD_FSM_current;
reg[7:0] WR_CMD_FSM_next;
parameter WR_CMD_FSM_IDLE			= 8'h00;
parameter WR_CMD_FSM_WEn_LOW		= 8'h01;
parameter WR_CMD_FSM_WEn_HIGH		= 8'h02;
parameter WR_CMD_FSM_OVER			= 8'h04;

reg[7:0] WP_CNT;
reg[7:0] HOLD_CNT;
always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			WP_CNT <= 0;
			HOLD_CNT <= 0;
		end
	else
		begin
			if(WR_CMD_FSM_current == WR_CMD_FSM_WEn_LOW)
				begin
					if(WP_CNT < 8'hFE)
						begin
							WP_CNT <= WP_CNT + 1;
						end
					else
						begin
							WP_CNT <= WP_CNT;
						end
				end
			else
				begin
					WP_CNT <= 0;
				end
			
			if(WR_CMD_FSM_current == WR_CMD_FSM_WEn_HIGH)
				begin
					if(HOLD_CNT < 8'hFE)
						begin
							HOLD_CNT <= HOLD_CNT + 1;
						end
					else
						begin
							HOLD_CNT <= HOLD_CNT;
						end
				end
			else
				begin
					HOLD_CNT <= 0;
				end
		end
end

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			WR_CMD_FSM_current <= WR_CMD_FSM_IDLE;
		end
	else
		begin
			WR_CMD_FSM_current <= WR_CMD_FSM_next;
		end
end

always@(*)
begin
	if(RSTn == 0)
		begin
			WR_CMD_FSM_next = WR_CMD_FSM_IDLE;
		end
	else
		begin
			case(WR_CMD_FSM_current)
				WR_CMD_FSM_IDLE:
					begin
						if(Start == 1)
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_WEn_LOW;
							end
						else
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_IDLE;
							end
					end
				WR_CMD_FSM_WEn_LOW:
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_WEn_HIGH;
							end
						else
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_WEn_LOW;
							end
					end
				WR_CMD_FSM_WEn_HIGH:
					begin
						if(HOLD_CNT >= tHOLD_cnt)
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_OVER;
							end
						else
							begin
								WR_CMD_FSM_next = WR_CMD_FSM_WEn_HIGH;
							end
					end
				WR_CMD_FSM_OVER:
					begin
						WR_CMD_FSM_next = WR_CMD_FSM_IDLE;
					end
				default:
					begin
						WR_CMD_FSM_next = WR_CMD_FSM_IDLE;
					end
			endcase
		end
end

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			Over <= 0;
			CLE <= 0;
			WEn <= 1;
			ALE <= 0;
		end
	else
		begin
			case(WR_CMD_FSM_current)
				WR_CMD_FSM_IDLE:
					begin
						Over <= 0;
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
					end
				WR_CMD_FSM_WEn_LOW:
					begin
						Over <= 0;
						CLE <= 1;
						WEn <= 0;
						ALE <= 0;
					end
				WR_CMD_FSM_WEn_HIGH:
					begin
						Over <= 0;
						CLE <= 1;
						WEn <= 1;
						ALE <= 0;
					end
				WR_CMD_FSM_OVER:
					begin
						Over <= 1;
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
					end
				default:
					begin
						Over <= 0;
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
					end
			endcase
		end
end


endmodule