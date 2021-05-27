module ADC(
    input wire RSTn,
    input wire CLK,

    input wire Read,
    input wire[3:0] Channel_Select,
    output reg[11:0] Resault /* synthesis preserve = 1 */,
    output reg RDY_BSYn,

    input wire[11:0] ADC_DATA /* synthesis keep="1" */,
    input wire ADC_STS,
    output reg ADC_R_Cn,
    output reg ADC_CSn,
    output reg ADC_CE,
    output reg ADC_A0,
	
    output reg[3:0] Analog_Switch
);


reg[7:0] ADC_CLK_CNT;
reg ADC_CLK;
always@(posedge CLK or negedge RSTn)
begin
    if(RSTn == 0)
        begin
            ADC_CLK <= 0;
            ADC_CLK_CNT <= 0;
        end
    else
        begin
            if(ADC_CLK_CNT >= 15)
                begin
                    ADC_CLK_CNT <= 0;
                    ADC_CLK <= ~ADC_CLK;
                end
            else
                begin
                    ADC_CLK_CNT <= ADC_CLK_CNT + 1;
                end
        end
end

reg[7:0] Analog_Switch_Wait_CNT;
reg Analog_Switch_Wait_CMD;
always@(posedge ADC_CLK or negedge RSTn)
begin
	if(RSTn == 0)
		begin
			Analog_Switch_Wait_CNT <= 0;
		end
	else
		begin
			if(Analog_Switch_Wait_CMD == 1)
				begin
					Analog_Switch_Wait_CNT <= Analog_Switch_Wait_CNT + 1;
				end
			else
				begin
					Analog_Switch_Wait_CNT <= 0;
				end
		end
end



reg[11:0] ADC_DATA_ALL[15:0] /* synthesis syn_keep=1 */;

reg[15:0] ADC_FSM_current;
reg[15:0] ADC_FSM_next;
parameter ADC_FSM_IDLE              = 16'h0000;
parameter ADC_FSM_Slect_Channel     = 16'h0001;
parameter ADC_FSM_Wait_Switch       = 16'h0002;
parameter ADC_FSM_CS_Convert        = 16'h0004;
parameter ADC_FSM_CE_Convert        = 16'h0008;
parameter ADC_FSM_Wait_STS_Low      = 16'h0010;
parameter ADC_FSM_Wait_STS_High     = 16'h0020;
parameter ADC_FSM_CS_Read           = 16'h0040;
parameter ADC_FSM_CE_Read           = 16'h0080;
parameter ADC_FSM_Read              = 16'h0100;

always@(posedge ADC_CLK or negedge RSTn)
begin
    if(RSTn == 0)
        begin
            ADC_FSM_current <= ADC_FSM_IDLE;
        end
    else
        begin
            ADC_FSM_current <= ADC_FSM_next;
        end
end

always@(*)
begin
    if(RSTn == 0)
        begin
            ADC_FSM_next = ADC_FSM_IDLE;
        end
    else
        begin
            case(ADC_FSM_current)
                ADC_FSM_IDLE:
                    begin
                        ADC_FSM_next = ADC_FSM_Slect_Channel;
                    end
                ADC_FSM_Slect_Channel:
                    begin
                        ADC_FSM_next = ADC_FSM_Wait_Switch;
                    end
                ADC_FSM_Wait_Switch:
                    begin
						if(Analog_Switch_Wait_CNT >= 10)
							begin
								ADC_FSM_next = ADC_FSM_CS_Convert;
							end
						else
							begin
								ADC_FSM_next = ADC_FSM_Wait_Switch;
							end
                    end
                ADC_FSM_CS_Convert:
                    begin
                        ADC_FSM_next = ADC_FSM_CE_Convert;
                    end
                ADC_FSM_CE_Convert:
                    begin
                        ADC_FSM_next = ADC_FSM_Wait_STS_Low;
						//ADC_FSM_next = ADC_FSM_Wait_STS_High;
                    end
                ADC_FSM_Wait_STS_Low:
                    begin
                        if(ADC_STS == 0)
                            begin
                                ADC_FSM_next = ADC_FSM_Wait_STS_Low;
                            end
                        else
                            begin
                                ADC_FSM_next = ADC_FSM_Wait_STS_High;
                            end
                    end
                ADC_FSM_Wait_STS_High:
                    begin
                        if(ADC_STS == 0)
                            begin
                                //ADC_FSM_next = ADC_FSM_CS_Read;
								ADC_FSM_next = ADC_FSM_CE_Read;
                            end
                        else
                            begin
                                ADC_FSM_next = ADC_FSM_Wait_STS_High;
                            end
                    end
                ADC_FSM_CS_Read:
                    begin
                        ADC_FSM_next = ADC_FSM_CE_Read;
                    end
                ADC_FSM_CE_Read:
                    begin
                        ADC_FSM_next = ADC_FSM_Read;
                    end
                ADC_FSM_Read:
                    begin
                        ADC_FSM_next = ADC_FSM_IDLE;
                    end
                default:
                    begin
                        ADC_FSM_next = ADC_FSM_IDLE;
                    end
            endcase
        end
end

reg[11:0] ADC_DATA_reg;
always @(posedge ADC_CLK or negedge RSTn) 
begin
    if(RSTn == 0)
        begin
            ADC_R_Cn <= 1;
            ADC_CSn <= 0;
            ADC_CE <= 0;
            ADC_A0 <= 0;
            Analog_Switch <= 0;
        end
    else
        begin
            case(ADC_FSM_current)
                ADC_FSM_IDLE:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
						Analog_Switch_Wait_CMD <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_Slect_Channel:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch + 1;
                    end
                ADC_FSM_Wait_Switch:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
						Analog_Switch_Wait_CMD <= 1;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_CS_Convert:
                    begin
                        ADC_R_Cn <= 0;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
						Analog_Switch_Wait_CMD <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_CE_Convert:
                    begin
                        ADC_R_Cn <= 0;
                        ADC_CSn <= 0;
                        ADC_CE <= 1;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_Wait_STS_Low:
                    begin
                        ADC_R_Cn <= 0;
                        ADC_CSn <= 0;
                        ADC_CE <= 1;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_Wait_STS_High:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_CS_Read:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_CE_Read:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 1;
                        ADC_A0 <= 0;
                        Analog_Switch <= Analog_Switch;
                    end
                ADC_FSM_Read:
                    begin
                        ADC_DATA_ALL[~Analog_Switch] <= ADC_DATA;
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
						Analog_Switch <= Analog_Switch;
                    end
                default:
                    begin
                        ADC_R_Cn <= 1;
                        ADC_CSn <= 0;
                        ADC_CE <= 0;
                        ADC_A0 <= 0;
                        Analog_Switch <= 0;
                    end
            endcase
        end
end


always @(posedge CLK or negedge RSTn) 
begin
    if(RSTn == 0)
        begin
            Resault <= 0;
            RDY_BSYn <= 0;
        end
    else
        begin
            if(Read == 1)
                begin
                    if(ADC_FSM_current == ADC_FSM_Read)
                        begin
                            Resault <= 0;
                            RDY_BSYn <= 0;
                        end
                    else
                        begin
                            Resault <= ADC_DATA_ALL[Channel_Select];
                            RDY_BSYn <= 1;
                        end
                end
            else
                begin
                    Resault <= 0;
                    RDY_BSYn <= 0;
                end
        end
end



endmodule