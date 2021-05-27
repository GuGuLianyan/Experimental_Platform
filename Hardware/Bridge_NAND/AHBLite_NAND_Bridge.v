`include "AHBLite_NAND_Bridge_CFG.v"

module AHBLite_NAND_Bridge
	#(
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
		//////////NAND TOP Interface/////////////////
		input wire[9:0] RAM_IN_RADDR,
		output wire[31:0] RAM_IN_RD,
		
		input wire[9:0] RAM_OUT_WADDR,
		input wire[31:0] RAM_OUT_WD,
		input wire RAM_OUT_WEN,
		
		output reg[31:0] NAND_ADDR,
		output reg[15:0] NAND_CMD,
		output reg CMD_IS_NEW
		
	);



reg[9:0] IN_DATA_CNT;
reg[9:0] OUT_DATA_CNT;
reg RAM_IN_WEN;
wire[31:0] RAM_OUT_RD;


TPLSRAM_2112Byte RAM_IN
	(
		.CLK(HCLK),
		.RADDR(RAM_IN_RADDR),
		.WADDR(IN_DATA_CNT),
		.WD(HWDATA),
		.WEN(RAM_IN_WEN),
		.RD(RAM_IN_RD)
	);
TPLSRAM_2112Byte RAM_OUT
	(
		.CLK(HCLK),
		.RADDR(OUT_DATA_CNT),
		.WADDR(RAM_OUT_WADDR),
		.WD(RAM_OUT_WD),
		.WEN(RAM_OUT_WEN),
		.RD(RAM_OUT_RD)
	);



reg[31:0] NAND_Operate_Over_Resault;
/*
 NAND_Operate_Over_Resault:
 bit0:
 bit1:
 */


reg[7:0] HRDATA_Src_Select;
parameter HRDATA_Src_Operate_Over_Resault	= 8'h00;
parameter HRDATA_Src_RAM_OUT				= 8'h01;

always@(*)
begin
	case(HRDATA_Src_Select)
		HRDATA_Src_Operate_Over_Resault:
			begin
				HRDATA = NAND_Operate_Over_Resault;
			end
		HRDATA_Src_RAM_OUT:
			begin
				HRDATA = RAM_OUT_RD;
			end
		default:
			begin
				HRDATA = NAND_Operate_Over_Resault;
			end
	endcase
end



reg[31:0] AHB_Lite_FSM_current;
reg[31:0] AHB_Lite_FSM_next;

parameter AHB_Lite_FSM_Get_ADDR 			= 16'h0000;
parameter AHB_Lite_FSM_NAND_Bridge_ADDR		= 16'h0001;
parameter AHB_Lite_FSM_NAND_Bridge_CMD      = 16'h0002;
parameter AHB_Lite_FSM_NAND_Bridge_DATA     = 16'h0004;
parameter AHB_Lite_FSM_IN_DATA_CNT          = 16'h0010;
parameter AHB_Lite_FSM_Operate_Over_Resault = 16'h0020;
parameter AHB_Lite_FSM_OUT_DATA_CNT         = 16'h0040;
parameter AHB_Lite_FSM_OUT_DATA				= 16'h0080;

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
								if(HADDR == `NAND_Bridge_ADDR)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_NAND_Bridge_ADDR;
									end
								else if(HADDR == `NAND_Bridge_DATA)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_NAND_Bridge_DATA;
									end
								else if(HADDR == `NAND_Bridge_CMD)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_NAND_Bridge_CMD;
									end
								else if(HADDR == `NAND_Bridge_Operate_Over_Resaultreg)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_Operate_Over_Resault;
									end
								else if(HADDR == `NAND_Bridge_IN_DATA_CNT_reg)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_IN_DATA_CNT;
									end
								else if(HADDR == `NAND_Bridge_OUT_DATA_CNT_reg)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_OUT_DATA_CNT;
									end
								else if(HADDR == `NAND_Bridge_OUT_DATA)
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_OUT_DATA;
									end
								else
									begin
										AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
									end
							end
						else
							begin
								AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
							end
					end
				AHB_Lite_FSM_NAND_Bridge_ADDR:
					begin
						AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
					end
				AHB_Lite_FSM_NAND_Bridge_DATA:
					begin
						AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
					end
				AHB_Lite_FSM_NAND_Bridge_CMD:
					begin
						AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
					end
				AHB_Lite_FSM_Operate_Over_Resault:
					begin
						AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
					end
				AHB_Lite_FSM_IN_DATA_CNT:
					begin
						AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
					end
				AHB_Lite_FSM_OUT_DATA_CNT:
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
			HREADYOUT <= HREADYOUT_RDY;
			HRESP <= HRESP_OKAY;
			RAM_IN_WEN <= 0;
			HRDATA_Src_Select <= HRDATA_Src_Operate_Over_Resault;
			CMD_IS_NEW <= 0;
		end
	else
		begin
			case(AHB_Lite_FSM_current)
				AHB_Lite_FSM_Get_ADDR:
					begin
						if(HSEL == 1'b1)
							begin
								HREADYOUT <= HREADYOUT_BSY;
								
							end
						else
							begin
								HREADYOUT <= HREADYOUT_RDY;
							end
						HRESP <= HRESP_OKAY;
						RAM_IN_WEN <= 0;
						CMD_IS_NEW <= 0;
					end
				AHB_Lite_FSM_NAND_Bridge_ADDR:
					begin
						NAND_ADDR <= HWDATA;
						
						HRESP <= HRESP_OKAY;
						HREADYOUT <= HREADYOUT_RDY;
					end
				AHB_Lite_FSM_NAND_Bridge_DATA:
					begin
						IN_DATA_CNT <= IN_DATA_CNT + 1;
						RAM_IN_WEN <= 1;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				AHB_Lite_FSM_NAND_Bridge_CMD:
					begin
						NAND_CMD <= HWDATA;
						CMD_IS_NEW <= 1;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				AHB_Lite_FSM_Operate_Over_Resault:
					begin
						HRDATA_Src_Select <= HRDATA_Src_Operate_Over_Resault;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				AHB_Lite_FSM_IN_DATA_CNT:
					begin
						IN_DATA_CNT <= 0;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				AHB_Lite_FSM_OUT_DATA_CNT:
					begin
						OUT_DATA_CNT <= 0;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				AHB_Lite_FSM_OUT_DATA:
					begin
						HRDATA_Src_Select <= HRDATA_Src_RAM_OUT;
						
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
				default:
					begin
						HREADYOUT <= HREADYOUT_RDY;
						HRESP <= HRESP_OKAY;
					end
			endcase
		end
end


















endmodule