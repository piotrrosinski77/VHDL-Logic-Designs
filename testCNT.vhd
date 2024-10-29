library ieee;
use ieee.std_logic_1164.all;
entity counter_tb is
end counter_tb;
architecture behavior of counter_tb is
component counter
port(
RESET : in std_logic;
CLK : in std_logic;
Y : out std_logic_vector(7 downto 0)
);
end component;
signal RESET : std_logic := '0';
signal CLK : std_logic := '0';
signal Y : std_logic_vector(7 downto 0);
-- Stała określająca okres zegara
constant CLK_period : time := 10 ns;
begin
uut: counter port map (
RESET => RESET,
CLK => CLK,
Y => Y
);
-- Proces generujący sygnał zegarowy
CLK_process :process
begin
CLK <= '0';
wait for CLK_period/2;
CLK <= '1';
wait for CLK_period/2;
end process;
-- Proces generujący sygnały sterujące
-- w tym przypadku tylko sygnał resetu
stim_proc: process
begin
RESET <= '1';
wait for 20 ns;
RESET <= '0';
-- W przypadku bardziej złożonego sterowania należy tutaj,
-- po kolejnych instrukcjach wait for …, zadawać wektory testowe
wait;
end process;
end;