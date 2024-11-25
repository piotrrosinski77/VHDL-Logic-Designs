library ieee;
use ieee.std_logic_1164.all;

entity sm is
port (I : in STD_LOGIC;
O : out STD_LOGIC;
CLK : in STD_LOGIC;
RESET : in STD_LOGIC);
end sm;

architecture Behavioral of sm is
 signal state: std_logic_vector(2 downto 0);
begin

process(RESET, CLK)
begin

if RESET = '1' then
state <= "000";
O <= '0';


elsif rising_edge(CLK) then

case state is

when "000" =>
if I = '0' then
state <= "001";
else
state <= "000";
end if;
O <= '0';

when "001" =>
if I = '1' then
state <= "010";
else
state <= "001";
end if;
O <= '0';

when "010" =>
if I = '1' then
state <= "100";
else
state <= "000";
end if;
O <= '0';

when "100" =>
if I = '0' then
O <= '1';
end if;
state <= "000";

when others =>
state <= "000";
O <= '0';
end case;

end if;

end process;
end Behavioral;