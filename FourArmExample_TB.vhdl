-----------------------------------------------------------------------
--  -Created by: Pedro Costa ------------------------------------------
--  -Date: 02/02/2021        ------------------------------------------
-----------------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FourArmExample_TB is
end FourArmExample_TB;

architecture Behavioral of FourArmExample_TB is
 Component FourArmExample 
 Port   (S1_IN		: in 	std_logic_vector(2 downto 0); -- Logic Signals for state of Arm A [S13 S12 S11]
		  S2_IN		: in 	std_logic_vector(2 downto 0); -- Logic Signals for state of Arm B
		  S3_IN		: in 	std_logic_vector(2 downto 0); -- Logic Signals for state of Arm C
		  S4_IN		: in 	std_logic_vector(2 downto 0); -- Logic Signals for state of Arm Neutral
		  
		  -- Input Currents Signals
		  Current_Signals_IN : in std_logic_vector(3 downto 0); -- Current Signals From A to Neutral - 1 means positive current
		  
		  -- 6 Possition Output vector
		  -- [ 5 | 4 | 3 | 2 | 1 | 0 ] 
		  -- [Sx3n|Sx3p|Sx2n|Sx2p|Sx1n|Sx1p]
		  S1_OUT		: out std_logic_vector(5 downto 0); -- Gate Attack Signals for Arm A
		  S2_OUT		: out std_logic_vector(5 downto 0); -- Gate Attack Signals for Arm B
		  S3_OUT		: out std_logic_vector(5 downto 0); -- Gate Attack Signals for Arm C
		  S4_OUT		: out std_logic_vector(5 downto 0); -- Gate Attack Signals for Arm Neutral
		  
		  --Clock Signal (Select Freuency):
		  clk_high_speed : in std_logic; -- High Speed clock to latch input signals
		  clk_commutation_speed : in std_logic; -- Clock that paces the commutation process
		  
		  -- Arm Selection
		  enable_vector : in std_logic_vector(3 downto 0) -- Vector to enable each arm (1110 means that the neutral arm is disabled);
 );
 end Component;
 
 constant clk_period_commutation : time := 500 ns; -- period of the steps
 constant clk_period_high_speed : time := 10 ns; -- period of the steps
 signal clk_commutation : std_logic;
 signal clk_high_speed : std_logic;
 
 signal S1_OUT :	std_logic_vector(5 downto 0);
 signal S2_OUT :	std_logic_vector(5 downto 0);
 signal S3_OUT :	std_logic_vector(5 downto 0);
 signal S4_OUT :	std_logic_vector(5 downto 0);   
 
 signal S1_IN :	std_logic_vector(2 downto 0);
 signal S2_IN :	std_logic_vector(2 downto 0);
 signal S3_IN :	std_logic_vector(2 downto 0);
 signal S4_IN :	std_logic_vector(2 downto 0); 
 
 signal currentSignals : std_logic_vector(3 downto 0);
 
begin

clk_commutation_process :process
   begin
		clk_commutation <= '0';
		wait for clk_period_commutation/2;
		clk_commutation <= '1';
		wait for clk_period_commutation/2;
   end process;
   
clk_high_speed_process :process
   begin
		clk_high_speed <= '0';
		wait for clk_period_high_speed/2;
		clk_high_speed <= '1';
		wait for clk_period_high_speed/2;
   end process;

uut: FourArmExample Port Map (
    S1_IN => S1_IN,	
    S2_IN => S2_IN,
    S3_IN => S3_IN,
	S4_IN => S4_IN,
    Current_Signals_IN => currentSignals,
    S1_OUT => S1_OUT,
	S2_OUT => S2_OUT,
	S3_OUT => S3_OUT,
	S4_OUT => S4_OUT,
    clk_high_speed => clk_high_speed,
    clk_commutation_speed => clk_commutation,
    enable_vector => "1111"
);

stim_proc: process
   begin
   S1_IN <= "001";
   S2_IN <= "010";
   S3_IN <= "100";
   S4_IN <= "001";
   currentSignals <= "1100";
   wait for 10us;
  S1_IN <= "010";
   S2_IN <= "010";
   S3_IN <= "010";
   S4_IN <= "001";
   currentSignals <= "0110";
   wait for 10us;
   S1_IN <= "100";
   S2_IN <= "001";
   S3_IN <= "010";
   S4_IN <= "100";
   currentSignals <= "0101";
   wait for 10us;
   S1_IN <= "001";
   S2_IN <= "100";
   S3_IN <= "100";
   S4_IN <= "001";
   currentSignals <= "1100";
   wait for 10us;
   S1_IN <= "010";
   S2_IN <= "010";
   S3_IN <= "010";
   S4_IN <= "010";
   currentSignals <= "1000";
   wait;
   end process;

end Behavioral;
