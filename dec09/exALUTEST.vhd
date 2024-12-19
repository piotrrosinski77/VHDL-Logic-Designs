library ieee;
use ieee.std_logic_1164.all;

entity exTEST is
end exTEST;

architecture Behavioral of exTEST is

    component ex is
        port (
        Z      : in STD_LOGIC; 
        GPIO      : out STD_LOGIC_VECTOR(7 downto 0); 
        CLK    : in STD_LOGIC;  
        RESET  : in STD_LOGIC  
        );
    end component;



    signal Z      : STD_LOGIC;
    signal GPIO      : STD_LOGIC_VECTOR(7 downto 0);         
    signal CLK_tb    : STD_LOGIC;
    signal RESET_tb  : STD_LOGIC; 

    constant CLK_PERIOD : time := 10 ns;  
begin

    uut: ex
        port map (
            Z     => Z,
            GPIO  => GPIO,
            CLK   => CLK_tb,
            RESET => RESET_tb
        );

    clock_process: process
    begin
        while true loop
            CLK_tb <= '0';
            wait for CLK_PERIOD / 2;
            CLK_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


    stimulus_process: process
    begin

        RESET_tb <= '1';
        wait for 20 ns;
        RESET_tb <= '0';

		z <= '1';
		wait for 20 ns;
		
        wait;
    end process;

end Behavioral;
