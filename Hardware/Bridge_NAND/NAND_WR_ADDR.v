module NAND_WR_ADDR_ALL
	#(
		parameter tWP_cnt = 1,
		parameter tWH_cnt = 1
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire[27:0] ADDR,
		input wire Start,
		output reg Over,
		
		output reg CLE,
		output reg WEn,
		output reg ALE,
		output reg[7:0] NAND_ADDR
	)

reg[15:0] WR_ADDR_FSM_current;
reg[15:0] WR_ADDR_FSM_next;
parameter WR_ADDR_FSM_IDLE			= 16'h0000;
parameter WR_ADDR_FSM_1_WEn_LOW		= 16'h0001;
parameter WR_ADDR_FSM_1_WEn_HIGH	= 16'h0002;
parameter WR_ADDR_FSM_2_WEn_LOW		= 16'h0004;
parameter WR_ADDR_FSM_2_WEn_HIGH	= 16'h0008;
parameter WR_ADDR_FSM_3_WEn_LOW		= 16'h0010;
parameter WR_ADDR_FSM_3_WEn_HIGH	= 16'h0020;
parameter WR_ADDR_FSM_4_WEn_LOW		= 16'h0040;
parameter WR_ADDR_FSM_4_WEn_HIGH	= 16'h0080;
parameter WR_ADDR_FSM_5_WEn_LOW		= 16'h0100;
parameter WR_ADDR_FSM_5_WEn_HIGH	= 16'h0200;
parameter WR_ADDR_FSM_Over			= 16'h0400;

reg[7:0] WP_CNT;
reg[7:0] WH_CNT;
always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			WP_CNT <= 0;
			WH_CNT <= 0;
		end
	else
		begin
			if(
				(WR_ADDR_FSM_current == WR_ADDR_FSM_1_WEn_LOW)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_2_WEn_LOW)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_3_WEn_LOW)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_4_WEn_LOW)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_5_WEn_LOW)
			)
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
			
			if(
				(WR_ADDR_FSM_current == WR_ADDR_FSM_1_WEn_HIGH)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_2_WEn_HIGH)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_3_WEn_HIGH)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_4_WEn_HIGH)
				||(WR_ADDR_FSM_current == WR_ADDR_FSM_5_WEn_HIGH)
			)
				begin
					if(WH_CNT < 8'hFE)
						begin
							WH_CNT <= WH_CNT + 1;
						end
					else
						begin
							WH_CNT <= WH_CNT;
						end
				end
			else
				begin
					WH_CNT <= 0;
				end
		end
end

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			WR_ADDR_FSM_current <= WR_ADDR_FSM_IDLE;
		end
	else
		begin
			WR_ADDR_FSM_current <= WR_ADDR_FSM_next;
		end
end

always@(*)
begin
	if(RSTn == 0)
		begin
			WR_ADDR_FSM_next = WR_ADDR_FSM_IDLE;
		end
	else
		begin
			case(WR_ADDR_FSM_current)
				WR_ADDR_FSM_IDLE		  :
					begin
						if(Start == 1)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_1_WEn_LOW;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_IDLE;
							end
					end
				WR_ADDR_FSM_1_WEn_LOW	  :
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_1_WEn_HIGH;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_1_WEn_LOW;
							end
					end
				WR_ADDR_FSM_1_WEn_HIGH    :
					begin
						if(WH_CNT >= tWH_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_2_WEn_LOW;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_1_WEn_HIGH;
							end
					end
				WR_ADDR_FSM_2_WEn_LOW	  :
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_2_WEn_HIGH;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_2_WEn_LOW;
							end
					end
				WR_ADDR_FSM_2_WEn_HIGH    :
					begin
						if(WH_CNT >= tWH_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_3_WEn_LOW;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_2_WEn_HIGH;
							end
					end
				WR_ADDR_FSM_3_WEn_LOW	  :
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_3_WEn_HIGH;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_3_WEn_LOW;
							end
					end
				WR_ADDR_FSM_3_WEn_HIGH    :
					begin
						if(WH_CNT >= tWH_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_4_WEn_LOW;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_3_WEn_HIGH;
							end
					end
				WR_ADDR_FSM_4_WEn_LOW	  :
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_4_WEn_HIGH;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_4_WEn_LOW;
							end
					end
				WR_ADDR_FSM_4_WEn_HIGH    :
					begin
						if(WH_CNT >= tWH_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_5_WEn_LOW;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_4_WEn_HIGH;
							end
					end
				WR_ADDR_FSM_5_WEn_LOW	  :
					begin
						if(WP_CNT >= tWP_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_5_WEn_HIGH;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_5_WEn_LOW;
							end
					end
				WR_ADDR_FSM_5_WEn_HIGH    :
					begin
						if(WH_CNT >= tWH_cnt)
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_Over;
							end
						else
							begin
								WR_ADDR_FSM_next = WR_ADDR_FSM_5_WEn_HIGH;
							end
					end
				WR_ADDR_FSM_Over		  :
					begin
						WR_ADDR_FSM_next = WR_ADDR_FSM_IDLE;
					end
				default:
					begin
						WR_ADDR_FSM_next = WR_ADDR_FSM_IDLE;
					end
			endcase
		end
end

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			CLE <= 0;
			WEn <= 1;
			ALE <= 0;
			NAND_ADDR <= 0;
			Over <= 0;
		end
	else
		begin
			case(WR_ADDR_FSM_current)
				WR_ADDR_FSM_IDLE		 :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
						//NAND_ADDR <= 0;
						NAND_ADDR <= NAND_ADDR;
						Over <= 0;
					end
				WR_ADDR_FSM_1_WEn_LOW	 :
					begin
						CLE <= 0;
						WEn <= 0;
						ALE <= 1;
						NAND_ADDR <= ADDR[7:0];
						Over <= 0;
					end
				WR_ADDR_FSM_1_WEn_HIGH   :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 1;
						NAND_ADDR <= ADDR[7:0];
						Over <= 0;
					end
				WR_ADDR_FSM_2_WEn_LOW	 :
					begin
						CLE <= 0;
						WEn <= 0;
						ALE <= 1;
						NAND_ADDR <= {4'h0, ADDR[11:8]};
						Over <= 0;
					end
				WR_ADDR_FSM_2_WEn_HIGH   :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 1;
						NAND_ADDR <= {4'h0, ADDR[11:8]};
						Over <= 0;
					end
				WR_ADDR_FSM_3_WEn_LOW	 :
					begin
						CLE <= 0;
						WEn <= 0;
						ALE <= 1;
						NAND_ADDR <= ADDR[19:12];
						Over <= 0;
					end
				WR_ADDR_FSM_3_WEn_HIGH   :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 1;
						NAND_ADDR <= ADDR[19:12];
						Over <= 0;
					end
				WR_ADDR_FSM_4_WEn_LOW	 :
					begin
						CLE <= 0;
						WEn <= 0;
						ALE <= 1;
						NAND_ADDR <= ADDR[27:20];
						Over <= 0;
					end
				WR_ADDR_FSM_4_WEn_HIGH   :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 1;
						NAND_ADDR <= ADDR[27:20];
						Over <= 0;
					end
				WR_ADDR_FSM_5_WEn_LOW	 :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 1;
						NAND_ADDR <= {7'h00, ADDR[28:28]};
						Over <= 0;
					end
				WR_ADDR_FSM_5_WEn_HIGH   :
					begin
						CLE <= 0;
						WEn <= ;
						ALE <= 1;
						NAND_ADDR <= {7'h00, ADDR[28:28]};
						Over <= 0;
					end
				WR_ADDR_FSM_Over		 :
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
						//NAND_ADDR <= 0;
						NAND_ADDR <= NAND_ADDR;
						Over <= 1;
					end
				default:
					begin
						CLE <= 0;
						WEn <= 1;
						ALE <= 0;
						NAND_ADDR <= 0;
						Over <= 0;
					end
			endcase
		end
end


endmodule