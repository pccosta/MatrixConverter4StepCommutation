-----------------------------------------------------------------------
--  -Created by: Pedro Costa ------------------------------------------
--  -Date: 02/02/2021        ------------------------------------------
-----------------------------------------------------------------------  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Arm4StepCurrentCommutation is
  Port (  ClkComm : in    std_logic; 
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
end Arm4StepCurrentCommutation;

architecture BEHAVIORAL of Arm4StepCurrentCommutation is
-- Signals that describe the state of the arm
    signal OutputVector  :  std_logic_vector(5 downto 0) :="000000";
    signal PreviousOutputVector  :  std_logic_vector(5 downto 0):="000000";
    signal DesiredVector :  std_logic_vector(5 downto 0);
    signal PreviousDesiredVector :  std_logic_vector(5 downto 0):="000000";

    signal Step          :  std_logic_vector(1 downto 0) :="11";
    signal PreviousStep  :  std_logic_vector(1 downto 0) :="11";
    signal FlagComm      :  std_logic :='0';
    signal OutputVector1Composition : std_logic_vector(5 downto 0):="000000";
    signal OutputVector2Composition : std_logic_vector(5 downto 0):="000000";
    signal OutputVector3Composition : std_logic_vector(5 downto 0):="000000";
    signal OutputVector4Composition : std_logic_vector(5 downto 0):="000000";
begin

FlagCommOut<=FlagComm;
PreviousStep <=Step when  rising_edge(ClkComm);
PreviousDesiredVector <=DesiredVector when  rising_edge(ClkComm);
PreviousOutputVector <=  OutputVector when  rising_edge(ClkComm);

StepProcess : process (ClkComm)
begin
    if rising_edge(ClkComm) then
       if (DesiredVector /= PreviousDesiredVector and FlagComm ='0') then
        FlagComm <= '1';
        Step<="00";
       end if;
       
      if FlagComm = '1' and PreviousStep="00" then 
        Step <="01";
       elsif FlagComm = '1' and PreviousStep="01" then 
        Step <="10";
       elsif FlagComm = '1' and PreviousStep="10" then 
        Step <="11";
        FlagComm <= '0'; 
       end if;
     end if;
     
end process;

DesiredVector <=   S3 & S3 & S2 & S2 & S1 & S1 when  rising_edge(ClkComm);


OutputVector <= OutputVector1Composition when Step="00" else
                OutputVector2Composition when Step="01" else
                OutputVector3Composition when Step="10" else
                OutputVector4Composition;
-- Step 1 Open non-conducting semiconductors based on the current signal
OutputVector1Composition <= OutputVector and "010101" when SignC='1'and rising_edge(ClkComm) else
                            OutputVector and "101010"  when  rising_edge(ClkComm);
-- Step 2 Mantain the state of the output vector composed of  [s1n s1p ... ] and turn on the semiconductor that matches the current and the input switch
OutputVector2Composition <= (OutputVector or DesiredVector ) and "010101" when SignC='1' and rising_edge(ClkComm) else
                            (OutputVector or DesiredVector ) and "101010" when  rising_edge(ClkComm);
               
-- Step 3 Clear the vector with exeption of the semiconductor that matches the current and the input switch
OutputVector3Composition <= DesiredVector  and "010101" when SignC='1'and rising_edge(ClkComm) else
                            DesiredVector  and "101010"  when  rising_edge(ClkComm);
-- Step 4 
OutputVector4Composition <= DesiredVector  when  rising_edge(ClkComm);

S1n <= OutputVector(0);
S1p <= OutputVector(1);
S2n <= OutputVector(2);
S2p <= OutputVector(3);
S3n <= OutputVector(4);
S3p <= OutputVector(5);

end BEHAVIORAL;
