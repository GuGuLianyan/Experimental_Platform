`timescale 1ns/1ns

module Bridge_CAN_tb();


    reg HRESETn;
    reg HCLK;
    reg HSEL;
    reg[31:0] HADDR;
    reg HWRITE;
    reg[31:0] HWDATA;
    reg[31:0] HRDATA;

    reg CAN_RST;
    reg CAN_CLK;


    always #1 HCLK = ~HCLK;
    always #3 CAN_CLK = ~CAN_CLK;

    AHBLite_CAN_Bridge U1
    (
        .HRESETn(HRESETn),
        .HCLK(HCLK),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .CAN_CLK(CAN_CLK)
    );


    initial
        begin
            HRESETn = 0;
            HCLK = 0;
            HSEL = 0;
            HADDR = 0;
            HWRITE = 0;
            HWDATA = 0;
            HRDATA = 0;
            CAN_RST = 0;
            CAN_CLK = 0;
            #1 HRESETn = 1;
            CAN_RST = 1;

            #4 HSEL = 1;
            HADDR = 32'h3000_3001;
            HWDATA = 32'h0000_0001;
            HWRITE = 1;
            #2 HSEL = 0;
        end

endmodule