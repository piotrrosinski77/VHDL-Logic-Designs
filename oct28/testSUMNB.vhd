library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testSUMNB is
end testSUMNB;

architecture Behavioral of testSUMNB is

  component SUMNB is
    generic (N: natural := 8);
	Port (A,B: in STD_LOGIC_VECTOR(N-1 downto 0);
		CIN: in STD_LOGIC;
		COUT: out STD_LOGIC;
		Y: out STD_LOGIC_VECTOR(N-1 downto 0):="00000000"
		);
  end component;

  signal CIN: STD_LOGIC;
  signal COUT: STD_LOGIC;
  signal Y: STD_LOGIC_VECTOR(7 downto 0);
  signal A, B: STD_LOGIC_VECTOR(7 downto 0);

begin

  uut: SUMNB
    generic map (N => 8)
    port map (
      A => A,
      B => B,
      CIN => CIN,
      COUT => COUT,
      Y => Y
    );


  stim_proc: process
  begin
    CIN <= '0';
    A <= "00000001";  -- 1
    B <= "00000001";  -- 1
    wait for 20 ns;

    CIN <= '0';
    A <= "10101010";  -- 170
    B <= "01010101";  -- 85
    wait for 20 ns;

    CIN <= '1';
    A <= "11111111";  -- 255
    B <= "00000001";  -- 1
    wait for 20 ns;
 
    wait;
  end process;

end Behavioral;