module NAND_TOP
	#(
		
	)
	(
		input wire CLK,
		input wire RSTn,
		
		/////////Bridge Interface///////////////
		output wire[9:0] IN_BUF_ADDR,
		input wire[31:0] IN_BUF_DATA,
		
		output wire[9:0] OUT_BUF_ADDR,
		output wire[31:0] OUT_BUF_ADDR,
		output wire OUT_BUF_WEN,
		
		input wire[31:0] NAND_ADDR,
		input wire[15:0] NAND_CMD,
		input wire CMD_IS_NEW,
		////////NAND Interface///////////////
		output reg CEn,
		output reg WEn,
		output reg REn,
		output reg CLE,
		output reg ALE,
		output reg WPn,
		input wire RDY_BSYn,
		inout wire[7:0] IO
	);
	
	

parameter NAND_CMD_SDI_1			= 16'h8000;
parameter NAND_CMD_READ_2			= 16'h0030;
parameter NAND_CMD_CACISDO_2		= 16'h05E0;
parameter NAND_CMD_APP_2			= 16'h8010;
parameter NAND_CMD_CACISDI_1		= 16'h8500;
parameter NAND_CMD_MPP_a2			= 16'h8011;
parameter NAND_CMD_MPP_b2			= 16'h8110;
parameter NAND_CMD_RFCB_2			= 16'h0035;
parameter NAND_CMD_CBP_2			= 16'h8510;
parameter NAND_CMD_ABE_2			= 16'h60D0;
parameter NAND_CMD_IDR_1			= 16'h9000;
parameter NAND_CMD_STR_1			= 16'h7000;
parameter NAND_CMD_STRFMPPOMBE_1	= 16'h7100;
parameter NAND_CMD_RST_1			= 16'hFF00; 


parameter IO_DIR_OUT				= 1'b1;
parameter IO_DIR_IN					= 1'b0;
reg IO_DIR;

reg[7:0] IO_Out_reg;
reg[16:0] NAND_INTF_Select;

assign IO = (IO_DIR == IO_DIR_OUT)? IO_Out_reg : 8'hZZ;



reg[31:0] Schedule_FSM_current;
reg[31:0] Schedule_FSM_next;

parameter Schedule_FSM_IDLE				= 32'h0000_0000;
parameter Schedule_FSM_SDI				= 32'h0000_0001;
parameter Schedule_FSM_SDI_OVER			= 32'h0000_0002;
parameter Schedule_FSM_READ				= 32'h0000_0004;
parameter Schedule_FSM_READ_OVER		= 32'h0000_0008;
parameter Schedule_FSM_CACISDO			= 32'h0000_0010;
parameter Schedule_FSM_CACISDO_OVER		= 32'h0000_0020;
parameter Schedule_FSM_APP				= 32'h0000_0040;
parameter Schedule_FSM_APP_OVER			= 32'h0000_0080;
parameter Schedule_FSM_CACISDI			= 32'h0000_0100;
parameter Schedule_FSM_CACISDI_OVER		= 32'h0000_0200;
parameter Schedule_FSM_MPP_A			= 32'h0000_0400;
parameter Schedule_FSM_MPP_A_OVER		= 32'h0000_0800;
parameter Schedule_FSM_MPP_B			= 32'h0000_1000;
parameter Schedule_FSM_MPP_B_OVER		= 32'h0000_2000;
parameter Schedule_FSM_RFCB				= 32'h0000_4000;
parameter Schedule_FSM_RFCB_OVER		= 32'h0000_8000;
parameter Schedule_FSM_CBP				= 32'h0001_0000;
parameter Schedule_FSM_CBP_OVER			= 32'h0002_0000;
parameter Schedule_FSM_ABE				= 32'h0004_0000;
parameter Schedule_FSM_ABE_OVER			= 32'h0008_0000;
parameter Schedule_FSM_IDR				= 32'h0010_0000;
parameter Schedule_FSM_IDR_OVER			= 32'h0020_0000;
parameter Schedule_FSM_STR				= 32'h0040_0000;
parameter Schedule_FSM_STR_OVER			= 32'h0080_0000;
parameter Schedule_FSM_STRFMPPOMBE		= 32'h0100_0000;
parameter Schedule_FSM_STRFMPPOMBE_OVER	= 32'h0200_0000;
parameter Schedule_FSM_RST				= 32'h0400_0000;
parameter Schedule_FSM_RST_OVER			= 32'h0800_0000;


always@(posedge CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			Schedule_FSM_current <= Schedule_FSM_IDLE;
		end
	else
		begin
			Schedule_FSM_current <= Schedule_FSM_next;
		end
end

always@(*)
begin
	if(RSTn == 0)
		begin
			Schedule_FSM_next = Schedule_FSM_IDLE;
		end
	else
		begin
			case(Schedule_FSM_current)
				Schedule_FSM_IDLE:
					begin
						if(CMD_IS_NEW == 1)
							begin
								case(NAND_CMD)
									NAND_CMD_SDI_1		    :
										begin
											Schedule_FSM_next = Schedule_FSM_SDI;
										end
									NAND_CMD_READ_2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_READ;
										end
									NAND_CMD_CACISDO_2	    :
										begin
											Schedule_FSM_next = Schedule_FSM_CACISDO;
										end
									NAND_CMD_APP_2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_APP;
										end
									NAND_CMD_CACISDI_1	    :
										begin
											Schedule_FSM_next = Schedule_FSM_CACISDI;
										end
									NAND_CMD_MPP_a2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_MPP_A;
										end
									NAND_CMD_MPP_b2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_MPP_B;
										end
									NAND_CMD_RFCB_2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_RFCB;
										end
									NAND_CMD_CBP_2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_CBP;
										end
									NAND_CMD_ABE_2		    :
										begin
											Schedule_FSM_next = Schedule_FSM_ABE;
										end
									NAND_CMD_IDR_1		    :
										begin
											Schedule_FSM_next = Schedule_FSM_IDR;
										end
									NAND_CMD_STR_1		    :
										begin
											Schedule_FSM_next = Schedule_FSM_STR;
										end
									NAND_CMD_STRFMPPOMBE_1  :
										begin
											Schedule_FSM_next = Schedule_FSM_STRFMPPOMBE;
										end
									NAND_CMD_RST_1		    :
										begin
											Schedule_FSM_next = Schedule_FSM_RST;
										end
									default:
										begin
											Schedule_FSM_next = Schedule_FSM_IDLE;
										end
								endcase
							end
						else
							begin
								Schedule_FSM_next = Schedule_FSM_IDLE;
							end
					end
				Schedule_FSM_SDI				:
					begin
						Schedule_FSM_next = Schedule_FSM_SDI_OVER;
					end
				Schedule_FSM_SDI_OVER			:
					begin
					end
				Schedule_FSM_READ				:
					begin
					end
				Schedule_FSM_READ_OVER		    :
					begin
					end
				Schedule_FSM_CACISDO			:
					begin
					end
				Schedule_FSM_CACISDO_OVER		:
					begin
					end
				Schedule_FSM_APP				:
					begin
					end
				Schedule_FSM_APP_OVER			:
					begin
					end
				Schedule_FSM_CACISDI			:
					begin
					end
				Schedule_FSM_CACISDI_OVER		:
					begin
					end
				Schedule_FSM_MPP_A			    :
					begin
					end
				Schedule_FSM_MPP_A_OVER		    :
					begin
					end
				Schedule_FSM_MPP_B			    :
					begin
					end
				Schedule_FSM_MPP_B_OVER		    :
					begin
					end
				Schedule_FSM_RFCB				:
					begin
					end
				Schedule_FSM_RFCB_OVER		    :
					begin
					end
				Schedule_FSM_CBP				:
					begin
					end
				Schedule_FSM_CBP_OVER			:
					begin
					end
				Schedule_FSM_ABE				:
					begin
					end
				Schedule_FSM_ABE_OVER			:
					begin
					end
				Schedule_FSM_IDR				:
					begin
					end
				Schedule_FSM_IDR_OVER			:
					begin
					end
				Schedule_FSM_STR				:
					begin
					end
				Schedule_FSM_STR_OVER			:
					begin
					end
				Schedule_FSM_STRFMPPOMBE		:
					begin
					end
				Schedule_FSM_STRFMPPOMBE_OVER	:
					begin
					end
				Schedule_FSM_RST				:
					begin
					end
				Schedule_FSM_RST_OVER	        :
					begin
					end
				default:
					begin
					end

				
				
			endcase
		end
end













endmodule