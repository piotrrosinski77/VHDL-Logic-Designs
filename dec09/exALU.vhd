library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex is
    port (
        Z      : in STD_LOGIC; 
        GPIO   : out STD_LOGIC_VECTOR(7 downto 0); 
        CLK    : in STD_LOGIC;  
        RESET  : in STD_LOGIC  
    );
end;

architecture Behavioral of ex is

    -- 8-bitowy rejestr statusowy
    signal SREG : STD_LOGIC_VECTOR(7 downto 0) := "00000000"; 

    -- pamiec ram
    type ram_array is array (0 to 31) of std_logic_vector(7 downto 0);
    signal RAM: ram_array;

    -- rejestry ogolnego przeznaczenia
    type reg_array is array (0 to 7) of std_logic_vector(7 downto 0);
    signal R: reg_array;

    -- pamiec ROM
    type rom_t is array (0 to 31) of std_logic_vector(15 downto 0);

    type instruction_t is record
        opcode_mask : std_logic_vector(15 downto 0); -- pełna maska
    end record;

    type instruction_array_t is array (0 to 18) of instruction_t;
    constant INSTRUCTIONS: instruction_array_t := (
        (opcode_mask => "00001-----------"), 	-- LDI
        (opcode_mask => "0000000000------"), 	-- MOV
        (opcode_mask => "0000000110------"), 	-- ST
        (opcode_mask => "01110-----------"), 	-- STS
        (opcode_mask => "0000000010------"), 	-- LD
        (opcode_mask => "01010-----------"), 	-- LDS
        (opcode_mask => "00000011--------"), 	-- B
        (opcode_mask => "0000000111------"),	-- ADC
        (opcode_mask => "00011-----------"),	-- ADCI
        (opcode_mask => "0000001000------"), 	-- SBC
        (opcode_mask => "10000-----------"),	-- SBCI
        (opcode_mask => "00111-----------"),	-- MUL
        (opcode_mask => "01000-----------"),	-- MULS
        (opcode_mask => "01001-----------"),	-- AND
        (opcode_mask => "0000001011------"),	-- ANDI
        (opcode_mask => "01011-----------"), 	-- OR
        (opcode_mask => "0000001111------"),	-- ORI
        (opcode_mask => "01111-----------"),	-- XOR
        (opcode_mask => "0000011111------")		-- XORI
    );

    constant C_LDI  : std_logic_vector(4 downto 0) := "00001";
    constant C_MOV  : std_logic_vector(9 downto 0) := "0000000000";
    constant C_ST   : std_logic_vector(9 downto 0) := "0000000110";
    constant C_STS  : std_logic_vector(4 downto 0) := "01110";
    constant C_LD   : std_logic_vector(9 downto 0) := "0000000010";
    constant C_LDS  : std_logic_vector(4 downto 0) := "01010";

    -- zarzadzajace bitami (flagami) rejestru statusowego SREG
    constant BSET	: std_logic_vector(7 downto 0) := "00000001";
    constant BCLR	: std_logic_vector(7 downto 0) := "00000010";

    -- arytmetyczne
    constant C_ADC	: std_logic_vector(9 downto 0) := "0000000111";
    constant C_ADCI	: std_logic_vector(4 downto 0) := "00011";
    constant C_SBC	: std_logic_vector(9 downto 0) := "0000001000";
    constant C_SBCI	: std_logic_vector(4 downto 0) := "10000";
    constant C_MUL	: std_logic_vector(9 downto 0) := "0011100000";
    constant C_MULS	: std_logic_vector(9 downto 0) := "0100000000";

    -- logiczne
    constant C_AND	: std_logic_vector(4 downto 0) := "01001";
    constant C_ANDI	: std_logic_vector(9 downto 0) := "0000001011";
    constant C_OR	: std_logic_vector(4 downto 0) := "01011";
    constant C_ORI	: std_logic_vector(9 downto 0) := "0000001111";
    constant C_XOR	: std_logic_vector(4 downto 0) := "01111";
    constant C_XORI	: std_logic_vector(9 downto 0) := "0000011111";

    constant C_B 	: std_logic_vector(7 downto 0) := "00000011";

    -- pamiec ROM
    constant ROM: rom_t := (
        C_LDI & "001" & x"35", 		-- wpisuje wartosc 35 do rejestru R1
        C_LDI & "100" & x"79",		-- wpisuje wartosc 79 do rejestru R4

        C_ADC & "010" & "001",		-- dodanie zawartosci rejestru R1 do rejestru R2
        C_ADCI & "010" & x"21", 	-- dodanie stalej 21h do rejestru R2
		
		C_SBC & "010" & "001",  	-- odejmuje zawartosc rejestru R1 od R2
		C_LDI & "011" &	x"15",		-- wpisuje wartosc 15 do rejestru R3
		C_SBCI & "011" & x"13",		-- odejmuje od rejestru R3 wartosc 13		
		C_LDI & "101" & x"23",		-- wpisuje wartosc 23 do rejestru R5
		C_MUL & "011" & "101",		-- mnozy ze soba rejestry R3 i R5 bez znaku
		C_LDI & "111" & "11111110",	-- wpisuje wartosc -2 do rejestru R7
		C_MULS & "111" & "101",		-- mnozy ze soba rejestry R7 i R5 ze znakiem

        -- miejsce na przetestowanie pozostalych rozkazow
        -- sprawdzic wplyw flagi C, rozkazy BSET i BCLR
        
        -- instrukcje zarzadzajace bitami (flagami) rejestru statusowego SREG
        --1 BSET K, ustawia bity rejestru SREG w miejscach występowania jedynek w stalej K (SREG <- SREG or K)	
        --2 BCLR K, zeruje bity rejestru SREG w miejscach występowania jedynej w stałej K (SREG <- SREG and not K)
        
        -- instrukcje arytmetyczne
        --1 ADC Rd, Rs, dodaje do rejestru Rd rejestr Rs oraz bit przeniesienia C (Rd <- Rd + Rs + C)
        --2 ADCI Rd, K, dodaje do rejestru Rd stałą 8-bitową K i bit przeniesienia C (Rd <- Rd + K + C)
        --3 SBC Rd, Rs, odejmuje od rejestru Rd rejestr Rs i bit przeniesienia C (Rd <- Rd - Rs - C)
        --4 SBCI Rd, Rs, odejmuje od rejestru Rd stałą 8-bitową K i bit przeniesienia C (Rd <- Rd - K - C)
        --5 MUL Rd, Rs, mnozy bez znaku rejestry Rs i Rd a wynik zapisuje w rejestrach Rd+1:Rd (Rd+1:Rd <- Rd*Rs)
        --6 MULS Rd, Rs, mnozy ze znakiem rejestry Rs i Rd a wynik zapisuje w rejestrach Rd+1:Rd (Rd+1:Rd <- Rd*Rs)
        
        -- instruckje logiczne
        --1 AND Rd, Rs, iloczyn logiczny rejestrow Rs i Rd (Rd <- Rd and Rs)
        --2 ANDI Rd, K, iloczyn logiczny rejestru Rd i stałej 8-bitowej K (Rd <- Rd and K)
        --3 OR Rd, Rs, suma logiczna rejestrów Rs i Rd (Rd <- Rd or Rs)
        --4 ORI Rd, K, suma logiczna rejestru Rd i stałej 8-bitowej K (Rd <- Rd or K)
        --5 XOR Rd, Rs, alternatywa rozłączna rejestrow Rs i Rd (Rd <- Rd xor Rs)
        --6 XORI Rd, K, alternatywa rozłączna rejestru Rd i stałej 8-bitowej K (Rd <- Rd xor K)

        C_B & x"00", 
        others => x"0000"
    );

    -- stan maszyny (enum)
    type state_type is (S_FETCH, S_EX);
    signal state : state_type := S_FETCH;

    signal PC      : std_logic_vector(15 downto 0);		-- licznik programu
    signal IR      : std_logic_vector(15 downto 0);		-- aktualnie wykonywany rozkaz

begin
    process(CLK, RESET)
        variable src1, src2: signed(7 downto 0);     		  -- dwa argumenty pochodzace z bloku rejestrow lub dekodera instrukcji
        variable res: signed(8 downto 0);             			  -- wynik operacji zapisywany do rejestrow ogolnego przeznaczenia
        variable temp_res: signed(15 downto 0);       		  -- 16-bitowy wynik dla mnożenia
        variable temp_R: reg_array;                   		  -- Tymczasowy rejestr R
		variable temp_sreg: std_logic_vector(7 downto 0); 	  -- zmienna do przechowywania wartości SREG
		
    begin
        if RESET = '1' then
            state <= S_FETCH;
            PC <= (others => '0');
            GPIO <= (others => '0');
            SREG <= "00000000";  -- Zresetowanie rejestru SREG
            R <= (others => "00000000");  -- Zresetowanie rejestrów ogólnego przeznaczenia
        
        elsif rising_edge(CLK) then
      
			--temp_sreg := SREG;
			
            case state is
            
                when S_FETCH =>
                    IR <= ROM(to_integer(unsigned(PC)));
                    state <= S_EX;

                when S_EX =>
                     temp_R := R;  -- Kopia rejestru R do zmiennej tymczasowej
					 temp_sreg := SREG;

                    for i in INSTRUCTIONS'range loop
                        if std_match(IR, INSTRUCTIONS(i).opcode_mask) then
                            case i is
                                when 0 =>  -- LDI
                                    R(to_integer(unsigned(IR(10 downto 8)))) <= IR(7 downto 0);
                                when 1 =>  -- MOV
                                    R(to_integer(unsigned(IR(5 downto 3)))) <= R(to_integer(unsigned(IR(2 downto 0))));
                                when 2 =>  -- ST
                                    RAM(to_integer(unsigned(R(to_integer(unsigned(IR(5 downto 3))))))) <= R(to_integer(unsigned(IR(2 downto 0))));
                                when 3 =>  -- STS
                                    RAM(to_integer(unsigned(IR(7 downto 0)))) <= R(to_integer(unsigned(IR(10 downto 8))));
                                when 4 =>  -- LD
                                    R(to_integer(unsigned(IR(5 downto 3)))) <= RAM(to_integer(unsigned(R(to_integer(unsigned(IR(2 downto 0)))))));
                                when 5 =>  -- LDS
                                    R(to_integer(unsigned(IR(10 downto 8)))) <= RAM(to_integer(unsigned(IR(7 downto 0))));
                                when 6 =>  -- B
                                    -- Implementacja instrukcji B
                                    null;

                                when 7 =>  -- ADC (Add with Carry)
                                    -- Rd <- Rd + Rs + C

                                    src1 := signed(temp_R(to_integer(unsigned(IR(5 downto 3)))));
									src2 := signed(temp_R(to_integer(unsigned(IR(2 downto 0)))));
									
                                    res := ("00000000" & temp_sreg(0));

                                    res := res + ('0' & src1) + ('0' & src2);

                                    temp_sreg(0) := res(8);

                                    temp_sreg(0) := (src1(7) and src2(7)) or (src1(7) and not res(7)) or (src2(7) and not res(7));

                                    if res(7 downto 0) = x"00" then
                                        temp_sreg(1) := '1';
                                    else
                                        temp_sreg(1) := '0';
                                    end if;	

                                    temp_R(to_integer(unsigned(IR(5 downto 3)))) := std_logic_vector(res(7 downto 0));
									R <= temp_R;
									SREG <= temp_sreg;

                                when 8 =>  -- ADCI (Add Immediate with Carry)

                                    src1 := signed(temp_R(to_integer(unsigned(IR(10 downto 8)))));
                                    src2 := signed(IR(7 downto 0));	
                                    
                                    res := ("00000000" & temp_sreg(0));

                                    res := res + ('0' & src1) + ('0' & src2);

                                    temp_sreg(0) := res(8);

                                    temp_sreg(0) := (src1(7) and src2(7)) or (src1(7) and not res(7)) or (src2(7) and not res(7));

                                    if res(7 downto 0) = x"00" then
                                        temp_sreg(1) := '1';
                                    else
                                        temp_sreg(1) := '0';
                                    end if;

                                    temp_R(to_integer(unsigned(IR(10 downto 8)))) := std_logic_vector(res(7 downto 0));
									R <= temp_R;
									SREG <= temp_sreg;

                                when 9 =>  -- SBC (Subtract with Carry)
								
                                    src1 := signed(temp_R(to_integer(unsigned(IR(5 downto 3)))));
                                    src2 := signed(temp_R(to_integer(unsigned(IR(2 downto 0)))));

                                    res := ("00000000" & temp_sreg(0));

                                    res := ('0' & src1) - ('0' & src2) - res;

                                    temp_sreg(0) := res(8);
									
                                    temp_sreg(0) := (not src1(7) and src2(7)) or (not src1(7) and res(7)) or (src2(7) and res(7));
									
                                    if res(7 downto 0) = x"00" then
                                        temp_sreg(1) := '1';
                                    else
                                        temp_sreg(1) := '0';
                                    end if;

                                    temp_R(to_integer(unsigned(IR(5 downto 3)))) := std_logic_vector(res(7 downto 0));
									R <= temp_R;
									SREG <= temp_sreg;

                                when 10 => -- SBCI (Subtract Immediate with Carry)

                                    src1 := signed(temp_R(to_integer(unsigned(IR(10 downto 8)))));
                                    src2 := signed((IR(7 downto 0)));

                                    res := ("00000000" & temp_sreg(0));

                                    res := ('0' & src1) - ('0' & src2) - res;

                                    temp_sreg(0) := res(8);

                                    temp_sreg(0) := (not src1(7) and src2(7)) or (not src1(7) and res(7)) or (src2(7) and 	res(7));

                                    if res(7 downto 0) = x"00" then
                                        temp_sreg(1) := '1';
                                    else
                                        temp_sreg(1) := '0';
                                    end if;

                                    temp_R(to_integer(unsigned(IR(10 downto 8)))) := std_logic_vector(res(7 downto 0));
									R <= temp_R;
									SREG <= temp_sreg;									
									
								when 11 => -- MUL (Multiply)

									src1 := signed(R(to_integer(unsigned(IR(5 downto 3)))));
									src2 := signed(R(to_integer(unsigned(IR(2 downto 0)))));

									temp_res := src1 * src2;

									temp_R(to_integer(unsigned(IR(5 downto 3)))) := std_logic_vector(temp_res(7 downto 0));
									
									if to_integer(unsigned(IR(5 downto 3))) + 1 < 8 then
										temp_R(to_integer(unsigned(IR(5 downto 3)) + 1)) := std_logic_vector(temp_res(15 downto 8));
									end if;
									
									R <= temp_R; 

								when 12 => -- MULS (Multiply Signed)

									src1 := signed(R(to_integer(unsigned(IR(5 downto 3)))));
									src2 := signed(R(to_integer(unsigned(IR(2 downto 0)))));

									temp_res := src1 * src2;
									
									temp_R(to_integer(unsigned(IR(5 downto 3)))) := std_logic_vector(temp_res(7 downto 0));
									
									if to_integer(unsigned(IR(5 downto 3))) + 1 < 8 then
										temp_R(to_integer(unsigned(IR(5 downto 3)) + 1)) := std_logic_vector(temp_res(15 downto 8));
									end if;
									
									R <= temp_R; 

								when 13 => -- AND

									temp_R(to_integer(unsigned(IR(5 downto 3)))) := R(to_integer(unsigned(IR(5 downto 3)))) and R(to_integer(unsigned(IR(2 downto 0))));
									R <= temp_R; 

								when 14 => -- ANDI

									temp_R(to_integer(unsigned(IR(10 downto 8)))) := R(to_integer(unsigned(IR(10 downto 8)))) and IR(7 downto 0);
									R <= temp_R; 

								when 15 => -- OR

									temp_R(to_integer(unsigned(IR(5 downto 3)))) := R(to_integer(unsigned(IR(5 downto 3)))) or R(to_integer(unsigned(IR(2 downto 0))));
									R <= temp_R; 

								when 16 => -- ORI

									temp_R(to_integer(unsigned(IR(10 downto 8)))) := R(to_integer(unsigned(IR(10 downto 8)))) or IR(7 downto 0);
									R <= temp_R; 

								when 17 => -- XOR

									temp_R(to_integer(unsigned(IR(5 downto 3)))) := R(to_integer(unsigned(IR(5 downto 3)))) xor R(to_integer(unsigned(IR(2 downto 0))));
									R <= temp_R; 

								when 18 => -- XORI

									temp_R(to_integer(unsigned(IR(10 downto 8)))) := R(to_integer(unsigned(IR(10 downto 8)))) xor IR(7 downto 0);
									R <= temp_R;

								when others => 
									null;
									
							end case;
							
                            PC <= std_logic_vector(to_unsigned(to_integer(unsigned(PC)) + 1, PC'length));
                            
							if unsigned(PC) >= 31 then
                                PC <= (others => '0');
                            end if;
                            
							state <= S_FETCH;
                            
							exit;
                        end if;
                    end loop;

                when others =>
                    null;
            end case;
        end if;
    end process;
end Behavioral;