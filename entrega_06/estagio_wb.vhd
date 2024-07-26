------------------------------------------------------------------------------------------------------------
------------MODULO ESTAGIO WRITE-BACK-----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- Especifica�ao do est�gio WRITE-BACK - wb: Declara�ao de entidade
-- Este est�gio  seleciona a informa�ao que deve ser gravada nos registradores, 
-- cuja grava�ao ser� executada no est�gio id
-- Os sinais de entrada e sa�da deste est�gio encontram-es definidos nos coment�rios 
-- da declara�ao de entidade estagio_wb.


entity estagio_wb is
    port(
		-- Entradas
        BWB				: in std_logic_vector(103 downto 0); -- Informa�oes vindas do estagi mem
		COP_wb			: in instruction_type := NOP;		 -- Mnem�nico da instru�ao no estagio wb
		
		-- Sa�das
        writedata_wb	: out std_logic_vector(31 downto 0); -- Valor a ser escrito emregistradores
        rd_wb			: out std_logic_vector(04 downto 0); -- Endere�o do registrador a ser escrito
		RegWrite_wb		: out std_logic						 -- Sinal de escrita nos registradores
    );
end entity;

architecture behavioral of estagio_wb is
    signal memval_wb,NPC_wb,ula_wb : std_logic_vector(31 downto 0) := (others => '0');
    signal MemToReg_wb : std_logic_vector(1 downto 0) := (others => '0');
    
begin
    rd_wb <= BWB(4 downto 0);
    RegWrite_wb <= BWB(101);

    MemToReg_wb <= BWB(103 downto 102);
    NPC_wb <= BWB(100 downto 69);
    ula_wb <= BWB(68 downto 37);
    memval_wb <= BWB(36 downto 5);

    mux_wb : process(NPC_wb,ula_wb,memval_wb,MemToReg_wb) begin
        if (MemToReg_wb = "10") then
            writedata_wb <= NPC_wb;
        elsif(MemToReg_wb = "01") then
            writedata_wb <= memval_wb;
        else
            writedata_wb <= ula_wb;
        end if;
    end process;
end architecture;