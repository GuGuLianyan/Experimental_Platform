`include "AHBLite_1553_Bridge_CFG.v"

module AHBLite_1553_Bridge
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
////////1553B interface////////////////////////
		output reg B1553_DATA_DIR,
		input wire CLK_16MHz,
		
		output reg[11:0] B1553_ADDR,
		inout wire[15:0] B1553_DATA,
		output reg B1553_RSTn,
		output reg B1553_CSn,
		output reg B1553_MEM_REGn,
		output reg B1553_RD_WRn,
		input wire B1553_RDYn
		
	);
	
	parameter Interrupt_Mask_reg_RW			= 8'h00;
	parameter Config_reg_1_RW				= 8'h01;
	parameter Config_reg_2_RW				= 8'h02;
	parameter Start_Reset_reg_WO			= 8'h03;
	parameter RT_CMD_Stack_Point_reg_RO		= 8'h03;
	parameter RT_SubAddr_CTRL_Word_reg_RW	= 8'h04;
	parameter TimeScale_reg_RW				= 8'h05;
	parameter Interrupt_State_reg_RO		= 8'h06;
	parameter Config_reg_3_RW				= 8'h07;
	parameter Config_reg_4_RW				= 8'h08;
	parameter Config_reg_5_RW				= 8'h09;
	parameter RT_Data_Stack_Addr_reg_RW		= 8'h0A;
	parameter RT_Last_CMD_Word_reg_RW		= 8'h0D;
	parameter RT_State_Word_reg_RO			= 8'h0E;
	parameter RT_BIT_reg_RO					= 8'h0F;
	
	reg[15:0] AHB_Lite_FSM_current;
	reg[15:0] AHB_Lite_FSM_next;
	parameter AHB_Lite_FSM_Get_ADDR			= 16'h0000;
	parameter AHB_Lite_FSM_Get_Data			= 16'h0001;
	parameter AHB_Lite_FSM_Wait_1553_Write	= 16'h0002;
	parameter AHB_Lite_FSM_Wait_1553_Read	= 16'h0004;
	parameter AHB_Lite_FSM_Send_Data		= 16'h0008;
	
	reg[31:0] HADDR_Continue;
	reg Operate_1553_isOver;
	
	reg[15:0] B1553_Data;
	reg[15:0] B1553_Addr;
	
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
									if((HADDR >= `Bridge_1553_Register_BASE_ADDR)
									&&(HADDR < (`Bridge_1553_Register_BASE_ADDR + `Bridge_1553_Register_Num)))
										begin
											case(HADDR-`Bridge_1553_Register_BASE_ADDR)
												Interrupt_Mask_reg_RW,
                                                Config_reg_1_RW,
                                                Config_reg_2_RW,
                                                RT_SubAddr_CTRL_Word_reg_RW,
                                                TimeScale_reg_RW,
                                                Config_reg_3_RW,
                                                Config_reg_4_RW,
                                                Config_reg_5_RW,
                                                RT_Data_Stack_Addr_reg_RW,
                                                RT_Last_CMD_Word_reg_RW:
													begin
														if(HWRITE == 1'b1)
															begin
																	AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data;
															end
														else
															begin
																	AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Read;
															end
													end
												Start_Reset_reg_WO:
													begin
														if(HWRITE == 1'b1)
															begin
																AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data;
															end
														else
															begin
																AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
															end
													end
												RT_CMD_Stack_Point_reg_RO, Interrupt_State_reg_RO, 
												RT_State_Word_reg_RO, RT_BIT_reg_RO:
													begin
														if(HWRITE == 1'b1)
															begin
																AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
															end
														else
															begin
																AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Read;
															end
													end
												default :
													begin
														AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
													end
											endcase
										end
									else if(
										(HADDR >= `Bridge_1553_RAM_BASE_ADDR)
										&&(HADDR < (`Bridge_1553_RAM_BASE_ADDR + `Bridge_1553_RAM_LENGTH))
									)
										begin
											if(HWRITE == 1'b1)
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Get_Data;
												end
											else
												begin
													AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Read;
												end
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
					AHB_Lite_FSM_Get_Data:
						begin
							AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Write;
						end
					AHB_Lite_FSM_Wait_1553_Write:
						begin
							if(Operate_1553_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Write;
								end
						end
					AHB_Lite_FSM_Wait_1553_Read:
						begin
							if(Operate_1553_isOver == 1'b1)
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Send_Data;
								end
							else
								begin
									AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_1553_Read;
								end
						end
					AHB_Lite_FSM_Send_Data:
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
				HADDR_Continue <= 0;
				B1553_Data <= 0;
				B1553_Addr <= 0;
				HREADYOUT <= HREADYOUT_RDY;
				HRESP <= HRESP_OKAY;
			end
		else
			begin
				case(AHB_Lite_FSM_current)
					AHB_Lite_FSM_Get_ADDR:
						begin
							if(HSEL == 1'b1)
								begin
									HADDR_Continue <= HADDR;
									B1553_Data <= 0;
									HREADYOUT <= HREADYOUT_BSY;
									HRESP <= HRESP_OKAY;
									if(HADDR >= `Bridge_1553_RAM_BASE_ADDR)
										begin
											B1553_Addr <= HADDR - `Bridge_1553_RAM_BASE_ADDR;
										end
									else
										begin
											B1553_Addr <= HADDR - `Bridge_1553_Register_BASE_ADDR;
										end
								end
							else
								begin
									HADDR_Continue <= 0;
									B1553_Data <= 0;
									B1553_Addr <= 0;
									HREADYOUT <= HREADYOUT_RDY;
									HRESP <= HRESP_OKAY;
								end
						end
					AHB_Lite_FSM_Get_Data:
						begin
							HADDR_Continue <= HADDR_Continue;
							B1553_Addr <= B1553_Addr;
							B1553_Data <= HWDATA;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_1553_Write:
						begin
							HADDR_Continue <= HADDR_Continue;
							B1553_Addr <= B1553_Addr;
							B1553_Data <= B1553_Data;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Wait_1553_Read:
						begin
							HADDR_Continue <= HADDR_Continue;
							B1553_Addr <= B1553_Addr;
							B1553_Data <= B1553_Data;
							HREADYOUT <= HREADYOUT_BSY;
							HRESP <= HRESP_OKAY;
						end
					AHB_Lite_FSM_Send_Data:
						begin
							HADDR_Continue <= HADDR_Continue;
							B1553_Addr <= B1553_Addr;
							B1553_Data <= B1553_Data;
							HREADYOUT <= HREADYOUT_RDY;
							HRESP <= HRESP_OKAY;
						end
					default :
						begin
							HADDR_Continue <= 0;
							B1553_Data <= 0;
							B1553_Addr <= 0;
							HREADYOUT <= HREADYOUT_RDY;
							HRESP <= HRESP_OKAY;
						end
				endcase
			end
	end
	
	reg[15:0] B1553_FSM_current;
	reg[15:0] B1553_FSM_next;
	parameter B1553_FSM_IDLE			= 16'h0000;
	parameter B1553_FSM_CS				= 16'h0001;
	parameter B1553_FSM_Write			= 16'h0002;
	parameter B1553_FSM_Read			= 16'h0004;
	parameter B1553_FSM_Wait_RDY		= 16'h0008;
	parameter B1553_FSM_Over			= 16'h0010;

	parameter B1553_DATA_DIR_IN			= 1'h0;
	parameter B1553_DATA_DIR_OUT		= 1'h1;

	always@(posedge CLK_16MHz or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				B1553_FSM_current <= B1553_FSM_IDLE;
			end
		else
			begin
				B1553_FSM_current <= B1553_FSM_next;
			end
	end

	always@(*)
	begin
		if(HRESETn == 1'b0)
			begin
				B1553_FSM_next = B1553_FSM_IDLE;
			end
		else
			begin
				case (B1553_FSM_current)
					B1553_FSM_IDLE:
						begin
							if(
								(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_1553_Write)
								||(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_1553_Read)
							)
								begin
									B1553_FSM_next = B1553_FSM_CS;
								end
							else
								begin
									B1553_FSM_next = B1553_FSM_IDLE;
								end
						end
					B1553_FSM_CS:
						begin
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_1553_Write)
								begin
									B1553_FSM_next = B1553_FSM_Write;
								end
							else if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_1553_Read)
								begin
									B1553_FSM_next = B1553_FSM_Read;
								end
							else
								begin
									B1553_FSM_next = B1553_FSM_IDLE;
								end
						end
					B1553_FSM_Write:
						begin
							B1553_FSM_next = B1553_FSM_Wait_RDY;
						end
					B1553_FSM_Read:
						begin
							B1553_FSM_next = B1553_FSM_Wait_RDY;
						end
					B1553_FSM_Wait_RDY:
						begin
							if(B1553_RDYn == 1'b0)
								begin
									B1553_FSM_next = B1553_FSM_Over;
								end
							else
								begin
									B1553_FSM_next = B1553_FSM_Wait_RDY;
								end
						end
					B1553_FSM_Over:
						begin
							B1553_FSM_next = B1553_FSM_IDLE;
						end
					default :
						begin
							B1553_FSM_next = B1553_FSM_IDLE;
						end
				endcase
			end
	end
	
	assign B1553_DATA = (B1553_DATA_DIR == 1'b1)? B1553_Data : 16'hZZZZ;
	always@(posedge CLK_16MHz or negedge HRESETn)
	begin
		if(HRESETn == 1'b0)
			begin
				Operate_1553_isOver <= 1'b0;
				B1553_DATA_DIR <= B1553_DATA_DIR_IN;
				B1553_ADDR <= 0;
				B1553_RSTn <= 0;
				B1553_CSn <= 1;
				B1553_MEM_REGn <= 0;
				B1553_RD_WRn <= 1;
				HRDATA <= 0;
			end
		else
			begin
				case(B1553_FSM_current)
					B1553_FSM_IDLE:
						begin
							Operate_1553_isOver <= 1'b0;
							B1553_DATA_DIR <= B1553_DATA_DIR_IN;
							B1553_ADDR <= 0;
							B1553_RSTn <= 1;
							B1553_CSn <= 1;
							B1553_MEM_REGn <= 0;
							B1553_RD_WRn <= 1;
							HRDATA <= 0;
						end
					B1553_FSM_CS:
						begin
							Operate_1553_isOver <= 1'b0;
							B1553_ADDR <= B1553_Addr;
							B1553_RSTn <= 1;
							B1553_CSn <= 0;
							HRDATA <= 0;
							if(AHB_Lite_FSM_current == AHB_Lite_FSM_Wait_1553_Write)
								begin
									B1553_DATA_DIR <= 1'b1;
									B1553_RD_WRn <= 0;
								end
							else
								begin
									B1553_DATA_DIR <= 1'b0;
									B1553_RD_WRn <= 1;
								end
							
							if(HADDR_Continue >= `Bridge_1553_RAM_BASE_ADDR)
								begin
									B1553_MEM_REGn <= 1;
								end
							else
								begin
									B1553_MEM_REGn <= 0;
								end
						end
					B1553_FSM_Read, B1553_FSM_Write:
						begin
							Operate_1553_isOver <= Operate_1553_isOver;
							B1553_ADDR <= B1553_ADDR;
							B1553_RSTn <= 1'b1;
							B1553_CSn <= 1'b0;
							B1553_DATA_DIR <= B1553_DATA_DIR;
							B1553_RD_WRn <= B1553_RD_WRn;
							B1553_MEM_REGn <= B1553_MEM_REGn;
							HRDATA <= 0;
						end
					B1553_FSM_Wait_RDY:
						begin
							Operate_1553_isOver <= Operate_1553_isOver;
							B1553_ADDR <= B1553_ADDR;
							B1553_RSTn <= 1'b1;
							B1553_CSn <= 1'b0;
							B1553_DATA_DIR <= B1553_DATA_DIR;
							B1553_RD_WRn <= B1553_RD_WRn;
							B1553_MEM_REGn <= B1553_MEM_REGn;
							HRDATA <= 0;
						end
					B1553_FSM_Over:
						begin
							Operate_1553_isOver <= 1'b1;
							B1553_ADDR <= 0;
							B1553_RSTn <= 1'b1;
							B1553_CSn <= 1'b1;
							B1553_DATA_DIR <= B1553_DATA_DIR_IN;
							B1553_RD_WRn <= 1'b1;
							B1553_MEM_REGn <= 0;
							if(HADDR_Continue[1:0] == 2'b00)
								begin
									HRDATA <= {16'h0000, B1553_DATA};
								end
							else if(HADDR_Continue[1:0] == 2'b10)
								begin
									HRDATA <= {B1553_DATA, 16'h0000};
								end
							else
								begin
									HRDATA <= 32'hFFFF_FFFF;
								end
						end
					default:
						begin
							Operate_1553_isOver <= 1'b0;
							B1553_DATA_DIR <= B1553_DATA_DIR_IN;
							B1553_ADDR <= 0;
							B1553_RSTn <= 1;
							B1553_CSn <= 1;
							B1553_MEM_REGn <= 0;
							B1553_RD_WRn <= 1;
							HRDATA <= 0;
						end
				endcase
			end
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
endmodule