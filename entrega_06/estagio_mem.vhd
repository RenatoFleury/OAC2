---------------------------------------------------------------------------------------------------
-----------MODULO ESTAGIO DE MEMORIA---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all; 

library work;
use work.tipos.all;	

-- O est�gio de mem�ria � respons�vel por implementar os acessos a mem�ria de dados nas 
-- instru�oes de load e Store.
-- Nas demais instru�oes este est�gio nao realiza nenhuma opera�ao e passa simplesmente 
-- os dados recebidos para o est�gio wb de forma a viabilizar
-- o armazenamento das informa�oes nos registradores do Banco de registradores.
-- Os sinais de entrada e sa�da deste est�gio encontram-se definidos na declara�ao da 
-- entidade estagio_mem.

entity estagio_mem is
    generic(
        dmem_init_file: string := "dmem.txt"		  		-- Arquivo inicializar a mem�ria de dados
    );
    port(
		-- Entradas
		clock		: in std_logic;						 	-- Base de tempo
        BMEM		: in std_logic_vector(115 downto 0); 	-- Informa�oes vindas do est�gio ex
		COP_mem		: in instruction_type;					-- Mnem�nico sendo processada no est�gio mem
		
		-- Sa�das
        BWB			: out std_logic_vector(103 downto 0) := (others => '0');-- Informa�oes para o wb
		COP_wb 		: out instruction_type := NOP;			-- Mnem�nico a ser processada pelo est�gio wb
		RegWrite_mem: out std_logic;						-- Escrita em regs no est�gio mem
		MemRead_mem	: out std_logic;						-- Leitura da mem�ria no est�gio mem 
		MemWrite_mem: out std_logic;						-- Escrita na memoria de dados no est�gio mem
		rd_mem		: out std_logic_vector(004 downto 0);	-- Destino nos regs. no estagio mem
		ula_mem		: out std_logic_vector(031 downto 0);	-- ULA no est�go mem para o est�gio mem
		NPC_mem		: out std_logic_vector(031 downto 0);	-- Valor do NPC no estagio mem
		Memval_mem	: out std_Logic_vector(031 downto 0)	-- Saida da mem�ria no est�gio mem
		
    );
end entity;

architecture behavioral of estagio_mem is
	component data_ram is	 -- Esta � a mem�ria de dados -dmem
		generic(
			address_bits		: integer 	:= 32;		  -- Bits de end. da mem�ria de dados
			size				: integer 	:= 4099;	  -- Tamanho da mem�ria de dados em Bytes
			data_ram_init_file	: string 	:= "dmem.txt" -- Arquivo da mem�ria de dados
		);
		port (
			-- Entradas
			clock 		: in  std_logic;							    -- Base de tempo bancada de teste
			write 		: in  std_logic;								-- Sinal de escrita na mem�ria
			address 	: in  std_logic_vector(address_bits-1 downto 0);-- Entrada de endere�o da mem�ria
			data_in 	: in  std_logic_vector(address_bits-1 downto 0);-- Entrada de dados da mem�ria
			
			-- Sa�da
			data_out 	: out std_logic_vector(address_bits-1 downto 0)	-- Sa�da de dados da mem�ria
		);
	end component;
	
	signal MemWrite : std_logic := '0';
	signal dado_arma_ex,ula_ex,data_out : std_logic_vector(31 downto 0) := (others => '0');
	signal MemToReg_mem : std_logic_vector(1 downto 0) := (others => '0');
	

begin

	dado_arma_ex <= BMEM(46 downto 15);
	MemToReg_mem <= BMEM(115 downto 114);

	NPC_mem <= BMEM(110 downto 079);
	ula_mem <= BMEM(78 downto 47);
	rd_mem <= BMEM(4 downto 0);
	MemWrite_mem <= BMEM(112);
	MemRead_mem <= BMEM(111);
	RegWrite_mem <= BMEM(113);

	data_memory : data_ram port map(clock,MemWrite_mem,ula_mem,dado_arma_ex,data_out);
	memval_mem <= data_out;

	reg_BWB : process(clock) begin
		if (rising_edge(clock)) then
			BWB <= MemToReg_mem & RegWrite_mem & NPC_mem & ula_mem & memval_mem & rd_mem;
			COP_wb <= COP_mem;
		else
			BWB <= BWB;
			COP_wb <= COP_wb;
		end if;
	end process;

end architecture;