`timescale 1ns/1ns
module tb();

	reg RSTn;
	reg CLK;
	reg Read;
	reg[3:0] Channel_Select;
	reg[11:0] ADC_DATA;
	reg ADC_STS;
	
	ADC U1(
	.RSTn(RSTn),
	.CLK(CLK),
	
	.Read(Read),
	.Channel_Select(Channel_Select),
	.ADC_DATA(ADC_DATA),
	.ADC_STS(ADC_STS)
	);
	
	always #1 CLK = ~CLK;
	initial
	begin
		RSTn = 0;
		CLK = 0;
		Read = 0;
		Channel_Select = 0;
		ADC_DATA = 0;
		ADC_STS = 1;
		#3 RSTn = 1;
		ADC_DATA = 5;
		
		#10
		Channel_Select = 2;
		Read = 1;
		#600 ADC_STS = 0;
		
	end
	
endmodule