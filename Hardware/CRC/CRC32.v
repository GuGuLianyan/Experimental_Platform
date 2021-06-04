module CRC32
	#(
		parameter Init_Value = 32'hFFFF_FFFF
	)
	(
		input wire CLK,
		input wire RSTn,
		
		input wire CRC_ENABLE,
		input wire CRC_Init,
		input wire DATA_Serial_Stream,
		
		output wire[31:0] CRC_Resault
	);
	
	reg[31:0] CRC_reg, CRC_reg_next;
	wire[31:0] CRC_new;
	
	assign CRC_new[0]  = CRC_reg[31] ^ DATA_Serial_Stream;
	assign CRC_new[1]  = CRC_reg[0]   ^ CRC_new[0];
	assign CRC_new[2]  = CRC_reg[1]   ^ CRC_new[0];
	assign CRC_new[3]  = CRC_reg[2]; 
	assign CRC_new[4]  = CRC_reg[3]   ^ CRC_new[0];
	assign CRC_new[5]  = CRC_reg[4]   ^ CRC_new[0];
	assign CRC_new[6]  = CRC_reg[5];
	assign CRC_new[7]  = CRC_reg[6]   ^ CRC_new[0];
	assign CRC_new[8]  = CRC_reg[7]   ^ CRC_new[0];
	assign CRC_new[9]  = CRC_reg[8];
	assign CRC_new[10] = CRC_reg[9]   ^ CRC_new[0];
	assign CRC_new[11] = CRC_reg[10]  ^ CRC_new[0];
	assign CRC_new[12] = CRC_reg[11]  ^ CRC_new[0];
	assign CRC_new[13] = CRC_reg[12];
	assign CRC_new[14] = CRC_reg[13];
	assign CRC_new[15] = CRC_reg[14];
	assign CRC_new[16] = CRC_reg[15]  ^ CRC_new[0];
	assign CRC_new[17] = CRC_reg[16];
	assign CRC_new[18] = CRC_reg[17];
	assign CRC_new[19] = CRC_reg[18];
	assign CRC_new[20] = CRC_reg[19];
	assign CRC_new[21] = CRC_reg[20];
	assign CRC_new[22] = CRC_reg[21]  ^ CRC_new[0];
	assign CRC_new[23] = CRC_reg[22]  ^ CRC_new[0];
	assign CRC_new[24] = CRC_reg[23];
	assign CRC_new[25] = CRC_reg[24];
	assign CRC_new[26] = CRC_reg[25]  ^ CRC_new[0];
	assign CRC_new[27] = CRC_reg[26];
	assign CRC_new[28] = CRC_reg[27];
	assign CRC_new[29] = CRC_reg[28];
	assign CRC_new[30] = CRC_reg[29];
	assign CRC_new[31] = CRC_reg[30];
	
	always@(*)
	begin
		if(CRC_Init == 1)
			begin
				CRC_reg_next = Init_Value;
			end
		else if(CRC_ENABLE == 1)
			begin
				CRC_reg_next = CRC_new;
			end
		else
			begin
				CRC_reg_next = CRC_reg;
			end
	end
	
	always@(posedge CLK or negedge RSTn)
	begin
		if(RSTn == 0)
			begin
				CRC_reg <= Init_Value;
			end
		else
			begin
				CRC_reg <= CRC_reg_next;
			end
	end
	
	assign CRC_Resault = CRC_new;
	
endmodule