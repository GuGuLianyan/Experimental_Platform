library verilog;
use verilog.vl_types.all;
entity DFN1E1 is
    port(
        Q               : out    vl_logic;
        D               : in     vl_logic;
        CLK             : in     vl_logic;
        E               : in     vl_logic
    );
end DFN1E1;