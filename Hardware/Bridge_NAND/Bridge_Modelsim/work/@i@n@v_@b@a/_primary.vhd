library verilog;
use verilog.vl_types.all;
entity INV_BA is
    port(
        Y               : out    vl_logic;
        A               : in     vl_logic
    );
end INV_BA;