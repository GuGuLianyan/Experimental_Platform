//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Tue May 25 11:47:23 2021
// Version: v11.9 11.9.0.4
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// TPLSRAM_2112Byte
module TPLSRAM_2112Byte(
    // Inputs
    CLK,
    RADDR,
    WADDR,
    WD,
    WEN,
    // Outputs
    RD
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input         CLK;
input  [9:0]  RADDR;
input  [9:0]  WADDR;
input  [31:0] WD;
input         WEN;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output [31:0] RD;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire          CLK;
wire   [9:0]  RADDR;
wire   [31:0] RD_0;
wire   [9:0]  WADDR;
wire   [31:0] WD;
wire          WEN;
wire   [31:0] RD_0_net_0;
//--------------------------------------------------------------------
// TiedOff Nets
//--------------------------------------------------------------------
wire          GND_net;
//--------------------------------------------------------------------
// Constant assignments
//--------------------------------------------------------------------
assign GND_net = 1'b0;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign RD_0_net_0 = RD_0;
assign RD[31:0]   = RD_0_net_0;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------TPLSRAM_2112Byte_TPLSRAM_2112Byte_0_TPSRAM   -   Actel:SgCore:TPSRAM:1.0.101
TPLSRAM_2112Byte_TPLSRAM_2112Byte_0_TPSRAM TPLSRAM_2112Byte_0(
        // Inputs
        .WD    ( WD ),
        .WADDR ( WADDR ),
        .RADDR ( RADDR ),
        .WEN   ( WEN ),
        .CLK   ( CLK ),
        // Outputs
        .RD    ( RD_0 ) 
        );


endmodule
