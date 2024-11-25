library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SUM1B is
  port (A,B,CIN: in STD_LOGIC;
        COUT, Y: out STD_LOGIC);
end SUM1B;

architecture Behavioral of SUM1B is
begin

COUT <= (CIN AND B) OR (CIN and A) OR (A and B);
Y <= A xor B xor CIN;

end Behavioral;