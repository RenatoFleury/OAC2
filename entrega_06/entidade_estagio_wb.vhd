------------------------------------------------------------------------------------------------------------
------------MODULO ESTAGIO WRITE-BACK-----------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- Especificaç±ao do estágio WRITE-BACK - wb: Declaraçao de entidade
-- Este estágio  seleciona a informaç±ao que deve ser gravada nos registradores, 
-- cuja gravaçao será executada no estágio id
-- Os sinais de entrada e saída deste estágio encontram-es definidos nos comentários 
-- da declaraç±ao de entidade estagio_wb.


entity estagio_wb is
    port(
		-- Entradas
        BWB				: in std_logic_vector(103 downto 0); -- Informaçoes vindas do estagi mem
		COP_wb			: in instruction_type := NOP;		 -- Mnemônico da instruçao no estagio wb
		
		-- Saídas
        writedata_wb	: out std_logic_vector(31 downto 0); -- Valor a ser escrito emregistradores
        rd_wb			: out std_logic_vector(04 downto 0); -- Endereço do registrador a ser escrito
		RegWrite_wb		: out std_logic						 -- Sinal de escrita nos registradores
    );
end entity;