library verilog;
use verilog.vl_types.all;
entity BIBUF_DIFF is
    generic(
        IOSTD           : string  := ""
    );
    port(
        PADP            : inout  vl_logic;
        PADN            : inout  vl_logic;
        D               : in     vl_logic;
        E               : in     vl_logic;
        Y               : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IOSTD : constant is 1;
end BIBUF_DIFF;
