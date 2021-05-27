module NAND_RD
	#(
		parameter tREA_cnt = 2
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire Start,
		output wire Over,
		
		output wire CLE,
		output wire REn,
		output wire ALE
	);
	
reg[7:0] RD_FSM_current;
reg[7:0] RD_FSM_next;
parameter RD_FSM_IDLE			= 8'h00;
parameter RD_FSM_REn_LOW		= 8'h01;
parameter RD_FSM_REn_High		= 8'h02;
parameter RD_FSM_OVER			= 8'h04;

reg[7:0] REA_CNT;


always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			WP_CNT <= 0;
			REA_CNT <= 0;
		end
	else
		begin
			if(RD_FSM_REn_LOW == 0)
				begin
					if(REA_CNT <= 8'hFE)
						begin
							REA_CNT <= REA_CNT + 1;
						end
					else
						begin
							REA_CNT <= REA_CNT;
						end
				end
			else
				begin
					REA_CNT <= 0;
				end
		end
end


always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			RD_FSM_current <= RD_FSM_IDLE;
		end
	else
		begin
			RD_FSM_current <= RD_FSM_next;
		end
end 

always@(*)
begin
	if(RSTn == 0)
		begin
			RD_FSM_next = RD_FSM_IDLE;
		end
	else
		begin
			case(RD_FSM_current)
				RD_FSM_IDLE		 :
					begin
						if(Start == 1)
							begin
								RD_FSM_next = RD_FSM_REn_LOW;
							end
						else
							begin
								RD_FSM_next = RD_FSM_IDLE;
							end
					end
				RD_FSM_REn_LOW	 :
					begin
						if(REA_CNT >= tREA_cnt)
							begin
								RD_FSM_next = RD_FSM_REn_High;
							end
						else
							begin
								RD_FSM_next = RD_FSM_REn_LOW;
							end
					end
				RD_FSM_REn_High	 :
					begin
						RD_FSM_next = RD_FSM_OVER;
					end
				RD_FSM_OVER		 :
					begin
						RD_FSM_next = RD_FSM_IDLE;
					end
				default:
					begin
						RD_FSM_next = RD_FSM_IDLE;
					end
			endcase
		end
end

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			CLE <= 0;
			ALE <= 0;
			REn <= 1;
			Over <= 0;
		end
	else
		begin
			case(RD_FSM_current)
				RD_FSM_IDLE		:
					begin
						CLE <= 0;
						ALE <= 0;
						REn <= 1;
						Over <= 0;
					end
				RD_FSM_REn_LOW	:
					begin
						CLE <= 0;
						ALE <= 0;
						REn <= 0;
						Over <= 0;
					end
				RD_FSM_REn_High	:
					begin
						CLE <= 0;
						ALE <= 0;
						REn <= 1;
						Over <= 0;
					end
				RD_FSM_OVER		:
					begin
						CLE <= 0;
						ALE <= 0;
						REn <= 1;
						Over <= 1;
					end
				default:
					begin
						CLE <= 0;
						ALE <= 0;
						REn <= 1;
						Over <= 0;
					end
			endcase
		end
end

endmodule