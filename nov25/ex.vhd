library ieee;
use ieee.std_logic_1164.all;

entity ex is
    port (
        Z      : in STD_LOGIC; 
        GPIO      : out STD_LOGIC_VECTOR(7 downto 0); 
        CLK    : in STD_LOGIC;  
        RESET  : in STD_LOGIC  
    );
end ex;

architecture Behavioral of ex is

    type state_t is (s0, s1, s2, s3, s4);
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
                        state <= s0;
                    end if;
                    O <= '0';

                when s3 =>
                    if I = '0' then
                        state <= s4;
                    else
                        state <= s1;
                    end if;
                    O <= '0';

                when s4 =>	
                    state <= s0; 
                    O <= '1';
                    
                when others =>
                    state <= s0;
            end case;
        end if;
    end process;

end Behavioral;
