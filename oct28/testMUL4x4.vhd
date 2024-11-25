library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testMUL4x4 is
end testMUL4x4;

architecture Behavioral of testMUL4x4 is
    component MUL4x4 is
        port (A, B: in STD_LOGIC_VECTOR(3 downto 0);
              Y: out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    signal A, B: STD_LOGIC_VECTOR(3 downto 0);
    signal Y: STD_LOGIC_VECTOR(7 downto 0);

begin
    uut: MUL4x4 port map(A => A, B => B, Y => Y);

    stim_proc: process
    begin
        A <= "1011";  
        B <= "1101";  
        wait for 10 ns;
		
		A <= "0001";  
        B <= "0001";  
        wait for 10 ns;
		
		A <= "0001";  
        B <= "0010";  
        wait for 10 ns;
		
	wait;
    end process;

end Behavioral;
