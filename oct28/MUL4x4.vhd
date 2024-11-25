library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUL4x4 is
  port (
    A, B: in STD_LOGIC_VECTOR(3 downto 0);
    Y: out STD_LOGIC_VECTOR(7 downto 0)
  );
end MUL4x4;

architecture Behavioral of MUL4x4 is

    signal AB: STD_LOGIC_VECTOR(14 downto 0);
    signal C: STD_LOGIC_VECTOR(11 downto 0);
    signal P: STD_LOGIC_VECTOR(11 downto 0);

    component SUM1B is
      port (
        A, B, CIN: in STD_LOGIC;
        COUT, Y: out STD_LOGIC
      ); 
    end component;

begin

    AB(0) <= A(0) and B(1);
    AB(1) <= A(1) and B(0);
	
    AB(2) <= A(1) and B(1);
    AB(3) <= A(2) and B(0);
	
    AB(4) <= A(2) and B(1);
    AB(5) <= A(3) and B(0);
	
    AB(6) <= A(3) and B(1);
    AB(7) <= A(0) and B(2);
    
	AB(8) <= A(1) and B(2);
    AB(9) <= A(2) and B(2);
    
	AB(10) <= A(3) and B(2);
    
	AB(11) <= A(0) and B(3);
    
	AB(12) <= A(1) and B(3);
    
	AB(13) <= A(2) and B(3);
    
	AB(14) <= A(3) and B(3);

    FA0: SUM1B port map(A => AB(0), B => AB(1), CIN => '0', COUT => C(0), Y => P(0));
    FA1: SUM1B port map(A => AB(2), B => AB(3), CIN => C(0), COUT => C(1), Y => P(1));
    FA2: SUM1B port map(A => AB(4), B => AB(5), CIN => C(1), COUT => C(2), Y => P(2));
    FA3: SUM1B port map(A => AB(6), B => '0', CIN => C(2), COUT => C(3), Y => P(3));
	
    FA4: SUM1B port map(A => AB(7), B => P(1), CIN => '0', COUT => C(4), Y => P(4));
    FA5: SUM1B port map(A => AB(8), B => P(2), CIN => C(4), COUT => C(5), Y => P(5));
    FA6: SUM1B port map(A => AB(9), B => P(3), CIN => C(5), COUT => C(6), Y => P(6));
    FA7: SUM1B port map(A => AB(10), B => C(3), CIN => C(6), COUT => C(7), Y => P(7));
	
    FA8: SUM1B port map(A => AB(11), B => P(5), CIN => '0', COUT => C(8), Y => P(8));
    FA9: SUM1B port map(A => AB(12), B => P(6), CIN => C(8), COUT => C(9), Y => P(9));
    FA10: SUM1B port map(A => AB(13), B => P(7), CIN => C(9), COUT => C(10), Y => P(10));
    FA11: SUM1B port map(A => AB(14), B => C(6), CIN => C(10), COUT => C(11), Y => P(11));

    Y(0) <= A(0) and B(0);
    Y(1) <= P(0);
    Y(2) <= P(4);
    Y(3) <= P(8);
    Y(4) <= P(9);
    Y(5) <= P(10);
    Y(6) <= P(11);
    Y(7) <= C(11);

end Behavioral;
