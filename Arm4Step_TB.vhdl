-----------------------------------------------------------------------
--  -Created by: Pedro Costa ------------------------------------------
--  -Date: 02/02/2021        ------------------------------------------
-----------------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Arm4Step_TB is
end Arm4Step_TB;

architecture Behavioral of Arm4Step_TB is
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
 -- Inputs for testing
 signal InputVector  : std_logic_vector(2 downto 0);
 signal OutputVector : std_logic_vector(5 downto 0);
 
 constant clk_period : time := 500 ns; -- period of the steps
 signal currentSignal : std_logic;
 signal clk : std_logic;
 signal FlagComm : std_logic;
begin
 clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


uut : Arm4StepCurrentCommutation Port Map(
        ClkComm  => clk,
          SignC  => currentSignal,
          S1     => InputVector(0),
          S2     => InputVector(1), 
          S3     => InputVector(2),
          S1n    => OutputVector(0),
          S1p    => OutputVector(1), 
          S2n    => OutputVector(2),
          S2p    => OutputVector(3),
          S3n    => OutputVector(4),
          S3p    => OutputVector(5),
          FlagCommOut => FlagComm);
   stim_proc: process
   begin
    currentSignal <= '1';
    InputVector <= "001";
    wait for 6us;
    currentSignal <= '1';
    InputVector <= "010";
    wait for 6us;
    currentSignal <= '1';
    InputVector <= "100";
    wait for 6us;
    currentSignal <= '0';
    InputVector <= "010";
    wait for 6us;
    currentSignal <= '0';
    InputVector <= "001";
    wait;
   end process; 
          
end Behavioral;
