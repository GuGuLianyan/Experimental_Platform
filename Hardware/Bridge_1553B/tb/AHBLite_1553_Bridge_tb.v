`timescale 1ns/1ps

module AHBLite_1553_Bridge_tb();

    reg HRSTn;
    reg HCLK;
    reg HSEL;
    reg HWRITE;
    reg[31:0] HADDR;
    reg[31:0] HWDATA;
    reg CLK_16MHz;
    reg B1553_RDYn;

    always #1 HCLK = ~HCLK;
    always #3 CLK_16MHz = ~CLK_16MHz;

    AHBLite_1553_Bridge U1
        (
            .HRESETn(HRSTn),
            .HCLK(HCLK),
            .HSEL(HSEL),
            .HADDR(HADDR),
            .HWRITE(HWRITE),
            .HWDATA(HWDATA),

            .CLK_16MHz(CLK_16MHz),
            .B1553_RDYn(B1553_RDYn)
        );

    initial begin
        HRSTn = 0;
        HCLK = 0;
        HSEL = 0;
        HWRITE = 0;
        HADDR = 0;
        HWDATA = 0;
        CLK_16MHz = 0;
        B1553_RDYn = 1;
        #1 HRSTn = 1;
        #6 HADDR = 32'h4000_1002;
        HWDATA = 0;
        HSEL = 1;
        HWRITE = 0;
        #2 HWDATA = 32'h0000_0001;
        #1 HSEL = 0;
        #22 B1553_RDYn = 0;
		
    end

endmodule