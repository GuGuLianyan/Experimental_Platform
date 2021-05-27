library verilog;
use verilog.vl_types.all;
entity RGB_NG is
    port(
        An              : in     vl_logic;
        ENn             : in     vl_logic;
        YL              : out    vl_logic;
        YR              : out    vl_logic
    );
end RGB_NG;
