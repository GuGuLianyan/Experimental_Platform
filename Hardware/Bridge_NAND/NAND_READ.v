module NAND_READ
	#(
		parameter tWP = 2,
		parameter tWH = 1,
		parameter tHOLD = 1,
		parameter tREA = 2
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire CMD_IS_NEW,
		output reg IO_DIR,
		output reg[31:0] DATA_OUT,
		output reg Operate_IS_OVER,
		input wire[27:0] NAND_ADDR,
		//////NAND Flash Interface////////
		output reg CEn,
		output reg WEn,
		output reg REn,
		output reg CLE,
		output reg ALE,
		output reg WPn,
		input wire RDY_BSYn,
		inout wire[7:0] IO
	);


reg[27:0] NAND_ADDR_reg;
reg[7:0] CMD_reg;


reg CMD_Send_Start;
wire CMD_Send_Over;
reg CMD_Send_CLE, CMD_Send_WEn, CMD_Send_ALE;
NAND_WR_CMD
	#(
		.tWP_cnt(tWP),
		.tHOLD_cnt(tHOLD),
	)
	WR_CMD(
		.CLK(CLK),
		.RSTn(RSTn),
		.Start(CMD_Send_Start),
		.Over(CMD_Send_Over),
		.CLE(CMD_Send_CLE),
		.WEn(CMD_Send_WEn),
		.ALE(CMD_Send_ALE)
	);

reg ADDR_Send_Start;
wire ADDR_Send_Over;
reg ADDR_Send_CLE, ADDR_Send_WEn, ADDR_Send_ALE;
wire[7:0] NAND_ADDR_WR;
NAND_WR_ADDR_ALL
	#(
		.tWP_cnt(tWP),
		.tWH_cnt(tWH)
	)
	WR_ADDR(
		.CLK(CLK),
		.RSTn(RSTn),
		.ADDR(NAND_ADDR_reg),
		.Start(ADDR_Send_Start),
		.Over(ADDR_Send_Over),
		.CLE(ADDR_Send_CLE),
		.WEn(ADDR_Send_WEn),
		.ALE(ADDR_Send_ALE),
		.NAND_ADDR(NAND_ADDR_WR)
	);

reg RD_DATA_Start;
wire RD_DATA_Over;
reg RD_Data_CLE, RD_Data_ALE, RD_Data_REn;
NAND_RD
	#(
		.tREA_cnt(tREA)
	)
	RD_DATA
	(
		.CLK(CLK),
		.RSTn(RSTn),
		.Start(RD_DATA_Start),
		.Over(RD_DATA_Over),
		.CLE(RD_Data_CLE),
		.REn(RD_Data_REn),
		.ALE(RD_Data_ALE)
	);
	
	
reg[15:0] R_FSM_current;
reg[15:0] R_FSM_next;

parameter R_FSM_IDLE				= 16'h0000;
parameter R_FSM_SEND_CMD_1st		= 16'h0001;
parameter R_FSM_SEND_ADDR			= 16'h0002;
parameter R_FSM_SEND_CMD_2nd		= 16'h0004;
parameter R_FSM_Wait_RDY			= 16'h0008;
parameter R_FSM_Wait_BSY			= 16'h0010;
parameter R_FSM_SEND_CMD_3rd		= 16'h0020;
parameter R_FSM_READ_ST				= 16'h0040;
parameter R_FSM_SEND_CMD_4th		= 16'h0080;
parameter R_FSM_READ_DATA			= 16'h0100;
parameter R_FSM_OVER				= 16'h0200;

always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			R_FSM_current <= R_FSM_IDLE;
		end
	else
		begin
			R_FSM_current <= R_FSM_next;
		end
end

always@(*)
begin
	if(RSTn == 0)
		begin
			R_FSM_next = R_FSM_IDLE;
		end
	else
		begin
			case(R_FSM_current)
				R_FSM_IDLE			:
					begin
						if(Start == 1)
							begin
							end
					end
				R_FSM_SEND_CMD_1st  :
					begin
						
					end
				R_FSM_SEND_ADDR	    :
					begin
						
					end
				R_FSM_SEND_CMD_2nd  :
					begin
						
					end
				R_FSM_Wait_RDY	    :
					begin
						
					end
				R_FSM_Wait_BSY	    :
					begin
						
					end
				R_FSM_SEND_CMD_3rd  :
					begin
						
					end
				R_FSM_READ_ST		:
					begin
						
					end
				R_FSM_SEND_CMD_4th  :
					begin
						
					end
				R_FSM_READ_DATA	    :
					begin
						
					end
				R_FSM_OVER		    :
					begin
						
					end
			endcase
		end
end



endmodule