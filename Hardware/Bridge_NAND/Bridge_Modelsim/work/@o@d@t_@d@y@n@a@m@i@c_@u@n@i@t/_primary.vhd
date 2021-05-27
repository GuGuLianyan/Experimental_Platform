library verilog;
use verilog.vl_types.all;
entity ODT_DYNAMIC_UNIT is
    generic(
        ODT_BANK        : integer := -1
    );
    port(
        Q               : out    vl_logic;
        QRDn            : out    vl_logic;
        ADn             : in     vl_logic;
        ALn             : in     vl_logic;
        CLK             : in     vl_logic;
        DRn             : in     vl_logic;
        DFn             : in     vl_logic;
        SDR             : in     vl_logic;
        LAT             : in     vl_logic;
        SD              : in     vl_logic;
        EN              : in     vl_logic;
        SLn             : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ODT_BANK : constant is 1;
end ODT_DYNAMIC_UNIT;