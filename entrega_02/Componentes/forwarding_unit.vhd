library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity forwarding_unit is
    port(
        Rs1E      in std_logic_vector(4 downto 0);
        Rs2E      in std_logic_vector(4 downto 0);
        RdM       in std_logic_vector(4 downto 0);
        RdW       in std_logic_vector(4 downto 0);
        RegWriteM in std_logic;
        RegWriteW in std_logic;
        -----------------------------------------
        ForwardA  out std_logic_vector(2 downto 0);
        ForwardB  out std_logic_vector(2 downto 0);
    );
end entity