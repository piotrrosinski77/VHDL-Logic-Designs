library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.STD_TEXTIO.ALL;
--use std.textio.all;  

entity ex is
        port (
        Z      : in STD_LOGIC; 
        GPIO      : out STD_LOGIC_VECTOR(7 downto 0); 
        CLK    : in STD_LOGIC;  
        RESET  : in STD_LOGIC  
        );
end ;

architecture Behavioral of ex is

--file output_file : text is out "output.txt";

-- pamiec ram
type ram_array is array (0 to 31) of std_logic_vector(7 downto 0);
signal RAM: ram_array;

-- rejestry ogolnego przeznaczenia
type reg_array is array (0 to 7) of std_logic_vector(7 downto 0);
signal R: reg_array;

-- pamiec ROM
type rom_t is array (0 to 31) of std_logic_vector(15 downto 0);

type instruction_t is record
    opcode_mask : std_logic_vector(15 downto 0); -- pełna maska
end record;

type instruction_array_t is array (0 to 6) of instruction_t;
constant INSTRUCTIONS: instruction_array_t := (
    (opcode_mask => "00001-----------"), 	-- LDI
    (opcode_mask => "0000000000------"), 	-- MOV
    (opcode_mask => "0000000110------"), 	-- ST
    (opcode_mask => "01110-----------"), 	-- STS
    (opcode_mask => "0000000010------"), 	-- LD
    (opcode_mask => "01010-----------"), 	-- LDS
    (opcode_mask => "00000011--------") 	-- B
);

constant C_LDI  : std_logic_vector(4 downto 0) := "00001";
constant C_MOV  : std_logic_vector(9 downto 0) := "0000000000";
constant C_ST   : std_logic_vector(9 downto 0) := "0000000110";
constant C_STS  : std_logic_vector(4 downto 0) := "01110";
constant C_LD   : std_logic_vector(9 downto 0) := "0000000010";
constant C_LDS  : std_logic_vector(4 downto 0) := "01010";
constant C_B 	: std_logic_vector(7 downto 0) := "00000011";


-- pamiec ROM
constant ROM: rom_t := (
C_LDI & "001" & x"35", 
C_LDI & "100" & x"79", 
C_MOV & "101" & "001", 
C_LDI & "001" & x"02", 
C_ST & "001" & "100", 
C_STS & "100" & x"05", 
C_LD & "110" & "001", 
C_LDS & "111" & x"05", 
C_B & x"00", 
others => x"0000");


-- stan maszyny (enum)
type state_type is (S_FETCH, S_EX);
signal state : state_type := S_FETCH;

signal PC      : std_logic_vector(15 downto 0);		-- licznik programu
signal IR      : std_logic_vector(15 downto 0);		-- aktualnie wykonywany rozkaz

begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            state <= S_FETCH;
            PC <= (others => '0');
            GPIO <= (others => '0');
        
    elsif rising_edge(CLK) then
        
        case state is
            
            when S_FETCH =>
                    IR <= ROM(to_integer(unsigned(PC)));
                    state <= S_EX;

            when S_EX =>
                for i in INSTRUCTIONS'range loop
                    if std_match(IR, INSTRUCTIONS(i).opcode_mask) then
                        case i is
                            when 0 =>  -- LDI
                                R(to_integer(unsigned(IR(10 downto 8)))) <= IR(7 downto 0);
                            when 1 =>  -- MOV
                                R(to_integer(unsigned(IR(5 downto 3)))) <= R(to_integer(unsigned(IR(2 downto 0))));
                            when 2 =>  -- ST
                                RAM(to_integer(unsigned(R(to_integer(unsigned(IR(5 downto 3))))))) <= R(to_integer(unsigned(IR(2 downto 0))));
                            when 3 =>  -- STS
                                RAM(to_integer(unsigned(IR(7 downto 0)))) <= R(to_integer(unsigned(IR(10 downto 8))));
                            when 4 =>  -- LD
                                R(to_integer(unsigned(IR(5 downto 3)))) <= RAM(to_integer(unsigned(R(to_integer(unsigned(IR(2 downto 0)))))));
                            when 5 =>  -- LDS
                                R(to_integer(unsigned(IR(10 downto 8)))) <= RAM(to_integer(unsigned(IR(7 downto 0))));
                            when others => 
                                null;
                        end case;
						--report "RAM value at index " & integer'image(to_integer(unsigned(IR(7 downto 0)))) & ": " & RAM(to_integer(unsigned(IR(7 downto 0)))) severity note;
                        PC <= std_logic_vector(to_unsigned(to_integer(unsigned(PC)) + 1, PC'length));
						if unsigned(PC) >= 31 then
							PC <= (others => '0');
						end if;
						report "PC value: " & integer'image(to_integer(unsigned(PC))) severity note;
                        state <= S_FETCH;
                        exit;
                    end if;
                end loop;

            when others =>
                null;
        end case;
    end if;
end process;
end Behavioral;