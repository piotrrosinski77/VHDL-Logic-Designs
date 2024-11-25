library ieee;
use ieee.std_logic_1164.all;

entity testDET is
end testDET;

architecture behavior of testDET is
component sm
port (I : in STD_LOGIC;
O : out STD_LOGIC;
CLK : in STD_LOGIC;
RESET : in STD_LOGIC);
end component;

signal I : std_logic;
signal O : std_logic;
signal RESET : std_logic := '0';
signal CLK : std_logic := '0';

constant CLK_period : time := 10 ns;
begin
uut: sm port map (
RESET => RESET,
CLK => CLK,
I => I,
O => O
);

CLK_process :process
begin
CLK <= '0';
wait for CLK_period/2;
CLK <= '1';
wait for CLK_period/2;
end process;

stim_proc: process
begin
RESET <= '1';
wait for 10 ns;
RESET <= '0';
wait for 10 ns;

I <= '0';
wait for 10 ns;

I <= '1';
wait for 10 ns;

I <= '1';
wait for 10 ns;

I <= '0';
wait for 10 ns;

--wait;
end process;
end;
