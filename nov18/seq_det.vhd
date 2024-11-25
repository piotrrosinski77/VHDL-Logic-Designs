library ieee;
use ieee.std_logic_1164.all;

entity sd is
    port (
        I      : in  STD_LOGIC; 
        O      : out STD_LOGIC; 
        CLK    : in  STD_LOGIC;  
        RESET  : in  STD_LOGIC  
    );
end sd;

architecture Behavioral of sd is

    type state_t is (s0, s1, s2, s3, s4, s5);
    signal state : state_t;

begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            state <= s0;
            O <= '0';
        
        elsif rising_edge(CLK) then
            
			case state is
                
				when s0 =>
                    if I = '1' then
                        state <= s1;
                    else
                        state <= s0;
                    end if;
                    O <= '0';
                
				when s1 =>
                    if I = '0' then
                        state <= s2;
                    else
                        state <= s1;
                    end if;
                    O <= '0';

                when s2 =>
                    if I = '1' then
                        state <= s3;
                    else
                        state <= s2;
                    end if;
                    O <= '0';

                when s3 =>
                    if I = '0' then
                        state <= s4;
                    else
                        state <= s2;
                    end if;
                    O <= '0';

                when s4 =>
                    state <= s5;
                    O <= '1';

                when s5 =>
                    if I = '1' then
                        state <= s1;
                        O <= '0';
                    elsif I = '0' then
                        state <= s2;
                        O <= '1';
                    else
                        state <= s5;
                        O <= '0';
                    end if;
                    
                when others =>
                    state <= s0;
            end case;
        end if;
    end process;

end Behavioral;
