`timescale 1ns/1ps

module bridge_tb();

reg CLK_50MHz;
always@(*)
	#10 CLK_50MHz <= ~CLK_50MHz;


reg restn, hsel, write, mastlock;
reg[31:0] addr, wdata;
reg[2:0] size, burts;
reg[3:0] port;
reg[1:0] trans;
wire ready;
wire[31:0] rdata;
reg[31:0] aa;

reg[31:0] data_table[0:4095], addr_table[0:4095];  

initial
begin
	$readmemh("data.txt", data_table);
	$readmemh("addr.txt", addr_table);
	CLK_50MHz = 0;
	restn = 0;
	hsel = 0;
	addr = 0;
	write = 0;
	wdata = 0;
	
	restn = 1;
	#100;
	@(posedge CLK_50MHz);
	AHBLite_Write(addr_table[0], data_table[0]);
	AHBLite_Write(addr_table[1], data_table[1]);
	AHBLite_Write(addr_table[2], data_table[2]);
	AHBLite_Write(addr_table[3], data_table[3]);
	AHBLite_Read(32'h0000_000F, aa);
end



AHBLite_NAND_Bridge bridge
(
	.HRESETn(restn),
	.HCLK(CLK_50MHz),
	.HSEL(hsel),
	.HADDR(addr),
	.HWRITE(write),
	.HSIZE(0),
	.HBURST(0),
	.HPROT(0),
	.HTRANS(0),
	.HMASTLOCK(0),
	.HREADY(0),
	.HWDATA(wdata),
	.HREADYOUT(ready),
	.HRDATA(rdata),
	
	.RAM_IN_RADDR(0),
	.RAM_OUT_WADDR(0),
	.RAM_OUT_WD(0),
	.RAM_OUT_WEN(0)
);

task AHBLite_Write;
	input[31:0] ahb_addr;
	input[31:0] ahb_data;
begin
	wait(ready == 1);
	@(posedge CLK_50MHz);
	addr = ahb_addr;
	write = 1;
	hsel = 1;
	wdata = 32'hXXXX_XXXX;
	@(posedge CLK_50MHz);
	addr = 32'hXXXX_XXXX;
	wdata = ahb_data;
	wait(ready == 1);
	hsel = 0;
end
endtask

task AHBLite_Read;
	input[31:0] ahb_addr;
	output[31:0] ahb_data;
begin
	wait(ready == 1);
	@(posedge CLK_50MHz);
	addr = ahb_addr;
	write = 0;
	hsel = 1;
	wait(ready == 0);
	wait(ready == 1);
	@(posedge CLK_50MHz);
	ahb_data = rdata;
	hsel = 0;
end	
endtask


endmodule