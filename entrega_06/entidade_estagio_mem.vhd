---------------------------------------------------------------------------------------------------
-----------MODULO ESTAGIO DE MEMORIA---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- O estágio de memória é responsável por implementar os acessos a memória de dados nas 
-- instruç±oes de load e Store.
-- Nas demais instruç±oes este estágio nao realiza nenhuma operaçao e passa simplesmente 
-- os dados recebidos para o estágio wb de forma a viabilizar
-- o armazenamento das informaçoes nos registradores do Banco de registradores.
-- Os sinais de entrada e saída deste estágio encontram-se definidos na declaraçao da 
-- entidade estagio_mem.

entity estagio_mem is
    generic(
        dmem_init_file: string := "dmem.txt"		  		-- Arquivo inicializar a memória de dados
    );
    port(
		-- Entradas
		clock		: in std_logic;						 	-- Base de tempo
        BMEM		: in std_logic_vector(115 downto 0); 	-- Informaçoes vindas do estágio ex
		COP_mem		: in instruction_type;					-- Mnemônico sendo processada no estágio mem
		
		-- Saídas
        BWB			: out std_logic_vector(103 downto 0) := (others => '0');-- Informaçoes para o wb
		COP_wb 		: out instruction_type := NOP;			-- Mnemônico a ser processada pelo estágio wb
		RegWrite_mem: out std_logic;						-- Escrita em regs no estágio mem
		MemRead_mem	: out std_logic;						-- Leitura da memória no estágio mem 
		MemWrite_mem: out std_logic;						-- Escrita na memoria de dados no estágio mem
		rd_mem		: out std_logic_vector(004 downto 0);	-- Destino nos regs. no estagio mem
		ula_mem		: out std_logic_vector(031 downto 0);	-- ULA no estágo mem para o estágio mem
		NPC_mem		: out std_logic_vector(031 downto 0);	-- Valor do NPC no estagio mem
		Memval_mem	: out std_Logic_vector(031 downto 0)	-- Saida da memória no estágio mem
		
    );
end entity;