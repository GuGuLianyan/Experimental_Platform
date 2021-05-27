module AHBLite_ADC_Bridge
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
////////////ADC Interface///////////////////////
            output reg Read,
            output reg[3:0] Channel_Select,
            input wire[11:0] Resault,
            input wire RDY_BSYn
        )/* synthesis syn_keep=1 */;
    
    reg[15:0] AHB_Lite_FSM_current;
	reg[15:0] AHB_Lite_FSM_next;
    parameter AHB_Lite_FSM_Get_ADDR     = 16'h0000;
    parameter AHB_Lite_FSM_Wait_Read    = 16'h0001;
    parameter AHB_Lite_FSM_Send         = 16'h0002;   
	
	
    always@(posedge HCLK or negedge HRESETn)
    begin
        if(HRESETn == 0)
            begin
                AHB_Lite_FSM_current <= AHB_Lite_FSM_Get_ADDR;
            end
        else
            begin
                AHB_Lite_FSM_current <= AHB_Lite_FSM_next;
            end
    end

    always @(*)
    begin
        if(HRESETn == 0)
            begin
                AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
            end
        else
            begin
                case(AHB_Lite_FSM_current)
                    AHB_Lite_FSM_Get_ADDR:
                        begin
                            if(
                                (HSEL == 1)
                                &&(HADDR[0] == 0)
                                &&(HWRITE == 0)
                            )
                                begin
                                    AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_Read;
                                end
                            else
                                begin
                                    AHB_Lite_FSM_next = AHB_Lite_FSM_Get_ADDR;
                                end
                        end
                    AHB_Lite_FSM_Wait_Read:
                        begin
                            if(RDY_BSYn == 1)
                                begin
                                    AHB_Lite_FSM_next = AHB_Lite_FSM_Send;
                                end
                            else
                                begin
                                    AHB_Lite_FSM_next = AHB_Lite_FSM_Wait_Read;
                                end
                        end
                    AHB_Lite_FSM_Send:
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

    reg[31:0] HADDR_continue;
    always@(posedge HCLK or negedge HRESETn)
    begin
        if(HRESETn == 0)
            begin
                HRDATA <= 0;
                HREADYOUT <= 1;
                HRESP <= 0;
                Read <= 0;
                Channel_Select <= 0;
            end
        else
            begin
                case(AHB_Lite_FSM_current)
                    AHB_Lite_FSM_Get_ADDR:
                        begin
                            HADDR_continue <= HADDR;
                            if(
                                (HSEL == 1)
                                &&(HADDR[0] == 0)
                                &&(HWRITE == 0)
                            )
                                begin
                                    Channel_Select <= HADDR[4:1];
                                    HRDATA <= 0;
                                    HREADYOUT <= 0;
                                    HRESP <= 0;
                                    Read <= 1;
                                end
                        end
                    AHB_Lite_FSM_Wait_Read:
                        begin
                            HREADYOUT <= 0;
                            HRESP <= 0;
                            Channel_Select <= Channel_Select;
                            if(RDY_BSYn == 1)
                                begin
                                    Read <= 0;
                                    if(HADDR_continue[1] == 0)
                                        begin
                                            HRDATA <= {20'h0_0000, Resault};
                                        end
                                    else
                                        begin
                                            HRDATA <= {4'h0,Resault, 16'h0_0000};
                                        end
                                end
                            else
                                begin
                                    HRDATA <= 0;
                                    Read <= 1;
                                end
                        end
                    AHB_Lite_FSM_Send:
                        begin
                            HREADYOUT <= 1;
                            HRESP <= 0;
                            Channel_Select <= 0;
                            Read <= 0;
                            HRDATA <= HRDATA;
                        end
                    default :
                        begin
                            HRDATA <= 0;
                            HREADYOUT <= 1;
                            HRESP <= 0;
                            Read <= 0;
                            Channel_Select <= 0;
                        end
                endcase
            end
    end


endmodule