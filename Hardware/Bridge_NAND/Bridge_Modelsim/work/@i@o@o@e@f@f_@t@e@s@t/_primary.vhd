library verilog;
use verilog.vl_types.all;
entity IOOEFF_TEST is
    port(
        Q               : out    vl_logic;
        QRDn            : out    vl_logic;
        ADn             : in     vl_logic;
        ALn             : in     vl_logic;
        CLK             : in     vl_logic;
        DR              : in     vl_logic;
        DF              : in     vl_logic;
        SDR             : in     vl_logic;
        LAT             : in     vl_logic;
        SD              : in     vl_logic;
        EN              : in     vl_logic;
        SLn             : in     vl_logic
    );
end IOOEFF_TEST;