library verilog;
use verilog.vl_types.all;
entity ADC is
    generic(
        ADC_FSM_IDLE    : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        ADC_FSM_Slect_Channel: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        ADC_FSM_Wait_Switch: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        ADC_FSM_CS_Convert: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        ADC_FSM_CE_Convert: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0);
        ADC_FSM_Wait_STS_Low: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0);
        ADC_FSM_Wait_STS_High: vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        ADC_FSM_CS_Read : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        ADC_FSM_CE_Read : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        ADC_FSM_Read    : vl_logic_vector(0 to 15) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        RSTn            : in     vl_logic;
        CLK             : in     vl_logic;
        Read            : in     vl_logic;
        Channel_Select  : in     vl_logic_vector(3 downto 0);
        Resault         : out    vl_logic_vector(11 downto 0);
        RDY_BSYn        : out    vl_logic;
        ADC_DATA        : in     vl_logic_vector(11 downto 0);
        ADC_STS         : in     vl_logic;
        ADC_R_Cn        : out    vl_logic;
        ADC_CSn         : out    vl_logic;
        ADC_CE          : out    vl_logic;
        ADC_A0          : out    vl_logic;
        Analog_Switch   : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADC_FSM_IDLE : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_Slect_Channel : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_Wait_Switch : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_CS_Convert : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_CE_Convert : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_Wait_STS_Low : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_Wait_STS_High : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_CS_Read : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_CE_Read : constant is 1;
    attribute mti_svvh_generic_type of ADC_FSM_Read : constant is 1;
end ADC;
