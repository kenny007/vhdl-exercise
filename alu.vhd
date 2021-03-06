library ieee;
use ieee.std_logic_1164.all;

entity alu is
    port (
        n          : in  std_logic_vector (3 downto 0);
        m          : in  std_logic_vector (3 downto 0);
        opcode     : in  std_logic_vector (1 downto 0);
        d          : out std_logic_vector (3 downto 0);
        cout       : out std_logic
    );
end alu;

architecture behavioral of alu is
    component carry_ripple_adder
        port (
            a    : in  std_logic_vector (3 downto 0);
            b    : in  std_logic_vector (3 downto 0);
            ci   : in  std_logic;
            s    : out std_logic_vector (3 downto 0);
            co   : out std_logic
        );
    end component;

    signal m_inverted        : std_logic_vector (3 downto 0);
    signal nand_result       : std_logic_vector (3 downto 0);
    signal nor_result        : std_logic_vector (3 downto 0);
    signal adder_result      : std_logic_vector (3 downto 0);
    signal adder_carry_out   : std_logic;
    signal operation_type    : std_logic; 
    signal sub               : std_logic;

begin
    -- Make sense from control bits
    operation_type   <=   opcode(1);   -- Are we doing logical or arithmetic operation?
    sub              <=   opcode(0);   -- Are we doing addition/NAND or subtraction/NOR?


    -- Here we calculate inverted bits for subtraction if necessary
   

    m_inverted <= (not m) when sub = '1' else m;
    -- Addition 
    adder_instance: carry_ripple_adder
        port map(
            a => n,
            b => m_inverted,
            ci => sub,
            s => adder_result,
            co => adder_carry_out
        );
        
    -- Logical NAND operation
    nand_result(0) <= m(0) nand n(0);
    nand_result(1) <= m(1) nand n(1);
    nand_result(2) <= m(2) nand n(2);
    nand_result(3) <= m(3) nand n(3);

    -- Logical NOR operation
    nor_result(0) <=  m(0) nor n(0);
    nor_result(1) <=  m(1) nor n(1);
    nor_result(2) <=  m(2) nor n(2);
    nor_result(3) <= m(3) nor n(3);

    -- Select output based on which operation was requested
    d <=   nand_result when opcode ="10" else
           nor_result when opcode ="11" else
           adder_result;

    -- Carry out bit
    cout <= (adder_carry_out xor sub) when operation_type = '0' else
           '0';
end;

