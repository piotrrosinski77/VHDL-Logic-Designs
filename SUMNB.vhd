library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SUMNB is
  generic (N: natural := 8);
  Port (A,B: in STD_LOGIC_VECTOR(N-1 downto 0);
		CIN: in STD_LOGIC;
		COUT: out STD_LOGIC;
		Y: out STD_LOGIC_VECTOR(N-1 downto 0)
		);
end SUMNB;

architecture Behavioral of SUMNB is

component SUM1B is
  port (A,B,CIN: in STD_LOGIC;
        COUT, Y: out STD_LOGIC); 
end component;

signal net: std_logic_vector(N-1 downto 0);

begin

g: for i in 0 to N-1 generate
    begin
      i0: if i = 0 generate
        s1: SUM1B port map (A => a(i), B => b(i), CIN => CIN, COUT => net(i), Y => Y(i));
      end generate i0;
      i1: if i > 0 and i < N-1 generate
        s2: SUM1B port map (A => a(i), B => b(i), CIN => net(i-1), COUT => net(i), Y => Y(i));
      end generate i1;
      i2: if i=N-1 generate 
        s3: SUM1B port map (A => a(i), B => b(i), CIN => net(i-1), COUT => COUT, Y => Y(i));
      end generate i2;
    end generate g;
    
end Behavioral;