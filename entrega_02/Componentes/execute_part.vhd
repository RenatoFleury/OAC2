library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity execute_part is
    port(
        clk : in std_logic;
        -- Entradas oriundas do ID:
        BEX :           in std_logic_vector(214 downto 0);
        ExFlush :       in std_logic;
        -- Entradas oriundas do ME:
        ALUResultM :    in std_logic_vector(31 downto 0);
        RdM :           in std_logic_vector(4 downto 0);
        RegWriteM :     in std_logic;
        -- Entradas oriundas do WB:
        ResultW :       in std_logic_vector(31 downto 0);
        RdW :           in std_logic_vector(4 downto 0);
        RegWriteW:      in std_logic;
        -- Saidas para o ME:
        BME :           out std_logic_vector(136 downto 0);
        -- Saidas para o ID:
        MemWriteE :     out std_logic;
        AluResultE :    out std_logic_vector(31 downto 0);
        Rs1E :          out std_logic_vector(4 downto 0);
        Rs2E :          out std_logic_vector(4 downto 0);
        RdE :           out std_logic_vector(4 downto 0);
        -----------------------
        -- BEX:
        -- BEX[214] == RegWriteE
        -- BEX[213:212] == ResultSrcE
        -- BEX[211] == MemWriteE
        -- BEX[210] == ALUSrcE
        -- BEX[209:207] == ALUOpE
        -- BEX[206:175] == PcE
        -- BEX[174:143] == Rd1E
        -- BEX[142:111] == Rd2E
        -- BEX[110:79] == ImmExtE
        -- BEX[78:74] == Rs1E
        -- BEX[73:69] == Rs2E
        -- BEX[68:37] == PCPlus4
        -- BEX[36:5] == InstruE
        -- BEX[4:0] == RdE
        ------------------------
        -- BME:
        -- BME[136] == RegWriteM
        -- BME[135:134] == ResultSrcM
        -- BME[133] == MemWriteM
        -- BME[132:101] == ALUResultM
        -- BME[100:69] == WriteDataM
        -- BME[68:37] == PCPlus4
        -- BME[36:5] == InstruM
        -- BME[4:0] == RdM
    );
end entity