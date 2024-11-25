architecture Behavioral of sm2 is
 signal state, nstate: std_logic_vector(2 downto 0);
begin

process(RESET, CLK)
begin

if RESET = '1' then
state <= "000";

elsif rising_edge(CLK) then
state <= nstate;
end if;

end process;

process(I, state)
begin

case state is

when "000" =>
if I = '0' then
nstate <= "001";
else
nstate <= "000";
end if;
O <= '0';

when "001" =>
if I = '0' then
nstate <= "001";
else
nstate <= "010";
end if;
O <= '0';
-- Kod dla pozostałych stanów
...
when others =>
nstate <= "000";
O <= '0';
end case;
end process;
end Behavioral;
