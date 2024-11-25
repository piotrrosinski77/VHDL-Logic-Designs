library ieee;
use ieee.std_logic_1164.all;

entity seqTEST is
end seqTEST;

architecture Behavioral of seqTEST is

    component sd is
        port (
            I      : in  STD_LOGIC;
            O      : out STD_LOGIC;
            CLK    : in  STD_LOGIC;
            RESET  : in  STD_LOGIC
        );
    end component;

    signal I_tb      : STD_LOGIC;
    signal O_tb      : STD_LOGIC;         
    signal CLK_tb    : STD_LOGIC;
    signal RESET_tb  : STD_LOGIC; 

    constant CLK_PERIOD : time := 10 ns;
	constant RESET_PERIOD : time := 20 ns;

begin

    uut: sd
        port map (
            I      => I_tb,
            O      => O_tb,
            CLK    => CLK_tb,
            RESET  => RESET_tb
        );
	
	CLK_process :process
	begin
	CLK_tb <= '0';
	wait for CLK_period/2;
	CLK_tb <= '1';
	wait for CLK_period/2;
	end process;


    stimulus_process: process
    begin

        RESET_tb <= '1';
        
		wait for RESET_PERIOD;
		
        RESET_tb <= '0';
        
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for CLK_PERIOD;
        I_tb <= '1'; wait for CLK_PERIOD;
        I_tb <= '0'; wait for CLK_PERIOD;  -- powinno byc 1
		
		
		I_tb <= '0'; wait for CLK_PERIOD;
		
		
		I_tb <= '1'; wait for CLK_PERIOD;
		I_tb <= '0'; wait for CLK_PERIOD;
		I_tb <= '1'; wait for CLK_PERIOD;
		I_tb <= '0'; wait for CLK_PERIOD; -- powinno byc 1
		
		I_tb <= '1'; wait for CLK_PERIOD;
		I_tb <= '0'; wait for CLK_PERIOD; -- powinno byc nadal 1

        wait;
    end process;

end Behavioral;
