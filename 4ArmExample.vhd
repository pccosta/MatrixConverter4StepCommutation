-----------------------------------------------------------------------
--  -Created by: Pedro Costa ------------------------------------------
--  -Date: 02/02/2021        ------------------------------------------
-----------------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity FourArmExample is
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
end FourArmExample;

architecture Behavioral of FourArmExample is
Component Arm4StepCurrentCommutation
 Port (ClkComm : in    std_logic; 
          SignC   : in    std_logic; -- Sign of the current flowing in this arm (1 is positive, 0 is negative)
          S1      : in    std_logic; -- State of Switch S1 (1 is closed, 0 is open)
          S2      : in    std_logic; -- State of Switch S2
          S3      : in    std_logic; -- State of Switch S3
          S1n     : out   std_logic; -- Output State of semiconductor n of Switch S1
          S1p     : out   std_logic; -- Output State of semiconductor p of Switch S1
          S2n     : out   std_logic; -- Output State of semiconductor n of Switch S2
          S2p     : out   std_logic; -- Output State of semiconductor p of Switch S2
          S3n     : out   std_logic; -- Output State of semiconductor n of Switch S3
          S3p     : out   std_logic; -- Output State of semiconductor p of Switch S3
          FlagCommOut : out std_logic);  -- Flag signaling a commutation process is on-going
 end Component;
    -- Signals for latching the input values
    signal S1_IN_L :	std_logic_vector(2 downto 0);
	signal S2_IN_L :	std_logic_vector(2 downto 0);
	signal S3_IN_L :	std_logic_vector(2 downto 0);
	signal S4_IN_L :	std_logic_vector(2 downto 0);
	
	signal S1_OUT_L :	std_logic_vector(5 downto 0);
	signal S2_OUT_L :	std_logic_vector(5 downto 0);
	signal S3_OUT_L :	std_logic_vector(5 downto 0);
	signal S4_OUT_L :	std_logic_vector(5 downto 0);
	
	signal CommFlag :   std_logic_vector(3 downto 0);
begin

-- Latch the input signals so that a new commutation can only start after the previous one had finished
S1_IN_L<= S1_IN when rising_edge(clk_high_speed) and CommFlag(0) = '0';
S2_IN_L<= S2_IN when rising_edge(clk_high_speed) and CommFlag(1) = '0';
S3_IN_L<= S3_IN when rising_edge(clk_high_speed) and CommFlag(2) = '0';
S4_IN_L<= S4_IN when rising_edge(clk_high_speed) and CommFlag(3) = '0';

-- Declare one instance of the single Arm commutator per each arm

Arm1 : Arm4StepCurrentCommutation Port Map(
        ClkComm  => clk_commutation_speed,
          SignC  => Current_Signals_IN(0),
          S1     => S1_IN_L(0),
          S2     => S1_IN_L(1), 
          S3     => S1_IN_L(2),
          S1n    => S1_OUT_L(0),
          S1p    => S1_OUT_L(1), 
          S2n    => S1_OUT_L(2),
          S2p    => S1_OUT_L(3),
          S3n    => S1_OUT_L(4),
          S3p    => S1_OUT_L(5),
          FlagCommOut => CommFlag(0));
          
Arm2 : Arm4StepCurrentCommutation Port Map(
        ClkComm  => clk_commutation_speed,
          SignC  => Current_Signals_IN(1),
          S1     => S2_IN_L(0),
          S2     => S2_IN_L(1), 
          S3     => S2_IN_L(2),
          S1n    => S2_OUT_L(0),
          S1p    => S2_OUT_L(1), 
          S2n    => S2_OUT_L(2),
          S2p    => S2_OUT_L(3),
          S3n    => S2_OUT_L(4),
          S3p    => S2_OUT_L(5),
          FlagCommOut => CommFlag(1));   
                 
Arm3 : Arm4StepCurrentCommutation Port Map(
        ClkComm  => clk_commutation_speed,
          SignC  => Current_Signals_IN(2),
          S1     => S3_IN_L(0),
          S2     => S3_IN_L(1), 
          S3     => S3_IN_L(2),
          S1n    => S3_OUT_L(0),
          S1p    => S3_OUT_L(1), 
          S2n    => S3_OUT_L(2),
          S2p    => S3_OUT_L(3),
          S3n    => S3_OUT_L(4),
          S3p    => S3_OUT_L(5),
          FlagCommOut => CommFlag(2));
          
Arm4 : Arm4StepCurrentCommutation Port Map(
        ClkComm  => clk_commutation_speed,
          SignC  => Current_Signals_IN(3),
          S1     => S4_IN_L(0),
          S2     => S4_IN_L(1), 
          S3     => S4_IN_L(2),
          S1n    => S4_OUT_L(0),
          S1p    => S4_OUT_L(1), 
          S2n    => S4_OUT_L(2),
          S2p    => S4_OUT_L(3),
          S3n    => S4_OUT_L(4),
          S3p    => S4_OUT_L(5),
          FlagCommOut => CommFlag(3));
          
-- Output the signals based on the enabled vectors
S1_OUT <= ( S1_OUT_L) when enable_vector(0) ='1' else 
            "000000"; 
S2_OUT <= ( S2_OUT_L) when enable_vector(1) ='1' else 
            "000000"; 
S3_OUT <= ( S3_OUT_L) when enable_vector(2) ='1' else 
            "000000"; 
S4_OUT <= ( S4_OUT_L) when enable_vector(3) ='1' else 
            "000000";
end Behavioral;
