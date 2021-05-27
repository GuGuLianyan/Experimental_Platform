library verilog;
use verilog.vl_types.all;
entity GBM_NG is
    port(
        An              : in     vl_logic;
        ENn             : in     vl_logic;
        YEn             : out    vl_logic;
        YWn             : out    vl_logic
    );
end GBM_NG;
