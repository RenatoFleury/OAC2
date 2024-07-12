----------------------------------------------------------------------------------------------------
-------------MODULO ESTAGIO DE EXECUÇAO-------------------------------------------------------------
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;

-- Especificaçao do estagio Executa - ex: declaraçao de entidade
-- Neste estágio sao executadas as instruçoes do tipo RR e calculado os endereços 
-- das instruçoes de load e store.
-- O módulo que implementa a antecipaçao de valores (Forwarding) é feita neste estágio 
-- num módulo separado dentro do estágio ex.
-- A unidade lógica e aritmética - ULA - fica neste estágio.
-- Os multiplexadores de estrada da ULA que selecionam os valores corretos dependendo 
-- da antecipaç±ao ficam neste estágio.
-- A definiç±ao do sinais de entrada e saída do estágio EX encontram-se na declaraçao 
-- da entidade estágio_ex e sao passados pelo registrador BEX

entity estagio_ex is
    port(
		-- Entradas
		clock				: in 	std_logic;					  		-- Relógio do Sistema
      	BEX					: in 	std_logic_vector (151 downto 0);  	-- Dados vindos do id
		COP_ex				: in 	instruction_type;				  	-- Mnemônico no estágio ex
		ula_mem				: in 	std_logic_vector (031 downto 0);	-- ULA no estágio de Memória
		rs1_id_ex			: in	std_logic_vector (004 downto 0);    -- rs1 no estágio id para o ex
		rs2_id_ex			: in	std_logic_vector (004 downto 0);    -- rs2 no estágio id para o ex
		MemRead_mem			: in 	std_logic;					  		-- Leitura na memória no  mem
		RegWrite_mem		: in 	std_logic;					  		-- Escrita nos regs. no  mem
		rd_mem				: in 	std_logic_vector (004 downto 0);	-- Destino nos regs. mem
		RegWrite_wb			: in	Std_logic;							-- Escrita nos regs no estagio wb
		rd_wb				: in	std_logic_vector (004 downto 0);	-- Destino no rges no estágio wb
		writedata_wb		: in 	std_logic_vector (031 downto 0);	-- Dado a ser escrito no regs.
		Memval_mem			: in	std_logic_vector (031 downto 0);	-- Saída da memória no mem
		
		-- Saídas
		MemRead_ex			: out	std_logic;							-- Leitura da memória no ex 
		rd_ex				: out	std_logic_vector (004 downto 0);	-- Destino dos regs no ex
		ULA_ex				: out	std_logic_vector (031 downto 0);	-- ULA no estágio ex
		ex_fw_A_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em A no id 
																		-- em desvios com forward
        ex_fw_B_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em B no id 
																		-- em desvios com forward
        BMEM				: out 	std_logic_vector (115 downto 0) := (others => '0'); -- dados para mem
		COP_mem				: out 	instruction_type := NOP			  	-- Mnemônico no estágio mem
		
		);
end entity;

architecture behavioral of estagio_ex is
	
component alu is
    port(
		-- Entradas
		in_a		: in 	std_logic_vector(31 downto 0);
        in_b		: in 	std_logic_vector(31 downto 0);
        ALUOp		: in 	std_logic_vector(02 downto 0);
		
		-- Saídas
        ULA			: out 	std_logic_vector(31 downto 0);
        zero		: out 	std_logic
    );
end component;

	signal mux_immem_out,muxA_out,muxB_out,ULA_out : std_logic_vector(31 downto 0) := (others => '0'); 
	signal ALUop : std_logic_vector(2 downto 0) := (others => '1');
	signal zero,ALUsrc : std_logic := '0';
	signal rs1_ex,rs2_ex : std_logic_vector(4 downto 0) := (others => '1');
	signal forwardA,forwardB : std_logic_vector(1 downto 0):=(others => '0');
	
begin
	ALUop <= BEX(145 downto 143);
	ALUsrc <= BEX(146);
	rs1_ex <= BEX(132 downto 128);
	rs2_ex <= BEX(137 downto 133);
	-- saidas straightforward
	rd_ex <= BEX(142 downto 138);
	MemRead_ex <= BEX(147); 
	
	
	-- Muxs
	mux_immem : process(ALUsrc, BEX)
	begin
		if (ALUsrc = '1') then 
			mux_immem_out <= BEX(95 downto 64); -- Imem_id
		else
			mux_immem_out <= muxB_out; --RB_id
		end if;
	end process;

	mux_forwardA : process(BEX, forwardA, ula_mem,memval_mem,writedata_wb)
	begin
		case forwardA is
			when "00" =>
			when "01" => 
			when "10" =>
			when "11" =>
		end case;
	end process;

	mux_forwardB : process(...)
	begin
	end process;

	--ULA
	ULA : alu port map(mux_immem_out,muxA_out, ALUop, ULA_out, zero);

	--Forwarding Unit pode adiantar valores da ula_mem, memval_mem, writedata_wb, condicionais sendo memread_mem, regwrite_mem, regwrite_wb
	Forwarding_Unit : process(rd_wb,rd_mem,BEX,regwrite_wb,memread_mem,regwrite_mem)	
	begin
		if (rd_wb = rs1_ex and regwrite_wb = '1') then
		    forwardA <= "01";
		elsif(rd_mem = rs1_ex and (memread_mem = '1' and regwrite_mem = '1'))
		    forwardA <= "10";
		elsif(rd_mem = rs1_ex and (memread_mem = '0' and regwrite_mem = '0'))
		    forwardA <= "11";
		else
		    forwardA <= "00";
		end if;

		if (rd_wb = rs2_ex and regwrite_wb = '1') then
		    forwardB <= "01";
		elsif(rd_mem = rs2_ex and (memread_mem = '1' and regwrite_mem = '1'))
		    forwardB <= "10";
		elsif(rd_mem = rs2_ex and (memread_mem = '0' and regwrite_mem = '0'))
		    forwardB <= "11";
		else
		    forwardB <= "00";
		end if;

	--inserir logica ex_fw_a_branch
	end process;

end architecture;