library verilog;
use verilog.vl_types.all;
entity TPLSRAM_2112Byte_TPLSRAM_2112Byte_0_TPSRAM is
    port(
        WD              : in     vl_logic_vector(31 downto 0);
        RD              : out    vl_logic_vector(31 downto 0);
        WADDR           : in     vl_logic_vector(9 downto 0);
        RADDR           : in     vl_logic_vector(9 downto 0);
        WEN             : in     vl_logic;
        CLK             : in     vl_logic
    );
end TPLSRAM_2112Byte_TPLSRAM_2112Byte_0_TPSRAM;
