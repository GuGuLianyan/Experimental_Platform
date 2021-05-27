module NAND_READ
	#(
		parameter tWP = 2,
		parameter tWH = 1,
		parameter tHOLD = 1,
		parameter tREA = 2,
		parameter IO_DIR_OUT = 1,
		parameter IO_DIR_IN = 0,
		parameter IS_OVER = 1,
		parameter IS_NOT_OVER = 0,
		parameter IS_CMD_NEW = 1,
		parameter IS_CMD_NOT_NEW = 0
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire CMD_IS_NEW,
		output reg IO_DIR,
		output reg[31:0] DATA_OUT,
		output reg[9:0] DATA_OUT_ADDR,
		output reg Operate_IS_OVER,
		output reg DATA_OUT_WEn,
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
reg[15:0] Read_CNT;

reg CMD_Send_Start;
wire CMD_Send_Over;
reg CMD_Send_CLE, CMD_Send_WEn, CMD_Send_ALE;
NAND_WR_CMD
	#(
		.tWP_cnt(tWP),
		.tHOLD_cnt(tHOLD)
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
	

reg isRead_Success;
reg[7:0] Read_Status;
parameter Read_Success		= 1'b0;
parameter Read_Fail			= 1'b1;

reg[7:0] IO_OUT_REG;

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
						if(CMD_IS_NEW == IS_CMD_NEW)
							begin
								R_FSM_next = R_FSM_SEND_CMD_1st;
							end
						else
							begin
								R_FSM_next = R_FSM_IDLE;
							end
					end
				R_FSM_SEND_CMD_1st  :
					begin
						if(CMD_Send_Over == 1)
							begin
								R_FSM_next = R_FSM_SEND_ADDR;
							end
						else
							begin
								R_FSM_next = R_FSM_SEND_CMD_1st;
							end
					end
				R_FSM_SEND_ADDR	    :
					begin
						if(ADDR_Send_Over == 1)
							begin
								R_FSM_next = R_FSM_SEND_CMD_2nd;
							end
						else
							begin
								R_FSM_next = R_FSM_SEND_ADDR;
							end
					end
				R_FSM_SEND_CMD_2nd  :
					begin
						if(CMD_Send_Over == 1)
							begin
								R_FSM_next = R_FSM_Wait_RDY;
							end
						else
							begin
								R_FSM_next = R_FSM_SEND_CMD_2nd;
							end
					end
				R_FSM_Wait_RDY	    :
					begin
						if(RDY_BSYn == 1)
							begin
								R_FSM_next = R_FSM_Wait_RDY;
							end
						else
							begin
								R_FSM_next = R_FSM_Wait_BSY;
							end
					end
				R_FSM_Wait_BSY	    :
					begin
						if(RDY_BSYn == 1)
							begin
								R_FSM_next = R_FSM_SEND_CMD_3rd;
							end
						else
							begin
								R_FSM_next = R_FSM_Wait_BSY;
							end
					end
				R_FSM_SEND_CMD_3rd  :
					begin
						if(CMD_Send_Over == 1)
							begin
								R_FSM_next = R_FSM_READ_ST;
							end
						else
							begin
								R_FSM_next = R_FSM_SEND_CMD_3rd;
							end
					end
				R_FSM_READ_ST		:
					begin
						if(RD_DATA_Over == 1)
							begin
								if(isRead_Success == Read_Success)
									begin
										R_FSM_next = R_FSM_SEND_CMD_4th;
									end
								else
									begin
										R_FSM_next = R_FSM_OVER;
									end
							end
						else
							begin
								R_FSM_next = R_FSM_READ_ST;
							end
					end
				R_FSM_SEND_CMD_4th  :
					begin
						if(CMD_Send_Over == 1)
							begin
								R_FSM_next = R_FSM_READ_DATA;
							end
						else
							begin
								R_FSM_next = R_FSM_SEND_CMD_4th;
							end
					end
				R_FSM_READ_DATA	    :
					begin
						if(Read_CNT >= 2112)
							begin
								R_FSM_next = R_FSM_OVER;
							end
						else
							begin
								R_FSM_next = R_FSM_READ_DATA;
							end
					end
				R_FSM_OVER		    :
					begin
						R_FSM_next = R_FSM_IDLE;
					end
				default:
					begin
						R_FSM_next = R_FSM_IDLE;
					end
			endcase
		end
end




always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			CMD_reg <= 0;
			Operate_IS_OVER <= IS_NOT_OVER;
			NAND_ADDR_reg <= 0;
			DATA_OUT_WEn <= 0;
			Read_CNT <= 0;
		end
	else
		begin
			case(R_FSM_current)
				R_FSM_IDLE			:
					begin
						CMD_reg <= 0;
						Operate_IS_OVER <= Operate_IS_OVER;
						Read_CNT <= 0;
						DATA_OUT_WEn <= 0;
						if(CMD_IS_NEW == IS_CMD_NEW)
							begin
								NAND_ADDR_reg <= NAND_ADDR;
							end
						else
							begin
								NAND_ADDR_reg <= 0;
							end
					end
				R_FSM_SEND_CMD_1st  :
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_SEND_ADDR	    :
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_SEND_CMD_2nd  :
					begin
						CMD_reg <= 8'h30;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_Wait_RDY	    :
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_Wait_BSY	    :
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_SEND_CMD_3rd  :
					begin
						CMD_reg <= 8'h70;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
					end
				R_FSM_READ_ST		:
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
						Read_Status <= IO;
					end
				R_FSM_SEND_CMD_4th  :
					begin
						CMD_reg <= 8'h00;
						Operate_IS_OVER <= IS_NOT_OVER;
						NAND_ADDR_reg <= NAND_ADDR_reg;
						Read_Status <= IO;
					end
				R_FSM_READ_DATA	    :
					begin
						DATA_OUT_WEn <= 1;
						if(RD_DATA_Over == 1)
							begin
								Read_CNT <= Read_CNT + 1;
								DATA_OUT_ADDR <= Read_CNT[10:2];
							end
						else
							begin
								Read_CNT <= Read_CNT;
							end
					end
				R_FSM_OVER		    :
					begin
						DATA_OUT_WEn <= 0;
						Read_CNT <= 0;
						DATA_OUT_ADDR <= 0;
						CMD_reg <= 0;
						Operate_IS_OVER <= 1;
					end
				default:
					begin
						DATA_OUT_WEn <= 0;
						Read_CNT <= 0;
						DATA_OUT_ADDR <= 0;
						CMD_reg <= 0;
						Operate_IS_OVER <= 0;
					end
			endcase
		end
end



assign IO = (IO_DIR == IO_DIR_OUT)? IO_OUT_REG : 8'hZZ;
always@(*)
begin
	if(RSTn == 0)
		begin
			IO_DIR = IO_DIR_IN;
			IO_OUT_REG  = 0;
		end
	else
		begin
			case(R_FSM_current)
				R_FSM_SEND_CMD_1st, R_FSM_SEND_CMD_2nd, 
				R_FSM_SEND_CMD_3rd, R_FSM_SEND_CMD_4th:
					begin
						IO_DIR = IO_DIR_OUT;
						IO_OUT_REG = CMD_reg;
					end
				R_FSM_SEND_ADDR:
					begin
						IO_DIR = IO_DIR_OUT;
						IO_OUT_REG = NAND_ADDR_WR;
					end
				default:
					begin
						IO_DIR = IO_DIR_IN;
					end
			endcase
		end
end


always@(*)
begin
	if(IO[0:0] == 1)
		begin
			isRead_Success = Read_Fail;
		end
	else
		begin
			isRead_Success = Read_Success;
		end
end

always@(*)
begin
	if(RSTn == 0)
		begin
			CEn = 1;
			WEn = 1;
			REn = 1;
			CLE = 0;
			ALE = 0;
			WPn = 1;
		end
	else
		begin
			case(R_FSM_current)
				R_FSM_IDLE			:
					begin
						CEn = 1;
						WEn = 1;
						REn = 1;
						CLE = 0;
						ALE = 0;
						WPn = 1;
					end
				R_FSM_SEND_CMD_1st , R_FSM_SEND_CMD_2nd,
				R_FSM_SEND_CMD_3rd, R_FSM_SEND_CMD_4th:
					begin
						CEn = 0;
						WEn = CMD_Send_WEn;
						REn = 1;
						CLE = CMD_Send_CLE;
						ALE = CMD_Send_ALE;
						WPn = 1;
					end
				R_FSM_SEND_ADDR	    :
					begin
						CEn = 0;
						WEn = ADDR_Send_WEn;
						REn = 1;
						CLE = ADDR_Send_CLE;
						ALE = ADDR_Send_ALE;
						WPn = 1;
					end
				R_FSM_Wait_RDY, R_FSM_Wait_BSY    :
					begin
						CEn = 1;
						WEn = 1;
						REn = 1;
						CLE = 0;
						ALE = 0;
						WPn = 1;
					end
				R_FSM_READ_ST,R_FSM_READ_DATA	:
					begin
						CEn = 0;
						WEn = 1;
						REn = RD_Data_REn;
						CLE = RD_Data_CLE;
						ALE = RD_Data_ALE;
						WPn = 1;
					end
				R_FSM_OVER		    :
					begin
						CEn = 1;
						WEn = 1;
						REn = 1;
						CLE = 0;
						ALE = 0;
						WPn = 1;
					end
				default:
					begin
						CEn = 1;
						WEn = 1;
						REn = 1;
						CLE = 0;
						ALE = 0;
						WPn = 1;
					end
			endcase
		end
end












endmodule