library verilog;
use verilog.vl_types.all;
entity GB_NG is
    port(
        An              : in     vl_logic;
        ENn             : in     vl_logic;
        YNn             : out    vl_logic;
        YSn             : out    vl_logic
    );
end GB_NG;