library verilog;
use verilog.vl_types.all;
entity AHBLite_NAND_Bridge is
    port(
        HRESETn         : in     vl_logic;
        HCLK            : in     vl_logic;
        HSEL            : in     vl_logic;
        HADDR           : in     vl_logic_vector(31 downto 0);
        HWRITE          : in     vl_logic;
        HSIZE           : in     vl_logic_vector(2 downto 0);
        HBURST          : in     vl_logic_vector(2 downto 0);
        HPROT           : in     vl_logic_vector(3 downto 0);
        HTRANS          : in     vl_logic_vector(1 downto 0);
        HMASTLOCK       : in     vl_logic;
        HREADY          : in     vl_logic;
        HWDATA          : in     vl_logic_vector(31 downto 0);
        HRDATA          : out    vl_logic_vector(31 downto 0);
        HREADYOUT       : out    vl_logic;
        HRESP           : out    vl_logic;
        RAM_IN_RADDR    : in     vl_logic_vector(9 downto 0);
        RAM_IN_RD       : out    vl_logic_vector(31 downto 0);
        RAM_OUT_WADDR   : in     vl_logic_vector(9 downto 0);
        RAM_OUT_WD      : in     vl_logic_vector(31 downto 0);
        RAM_OUT_WEN     : in     vl_logic;
        NAND_ADDR       : out    vl_logic_vector(31 downto 0);
        NAND_CMD        : out    vl_logic_vector(15 downto 0);
        CMD_IS_NEW      : out    vl_logic
    );
end AHBLite_NAND_Bridge;
