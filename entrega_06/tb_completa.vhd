---------------------------------------------------------------------------------------------------
------------MODULO BANCADA DE TESTE---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;
use std.textio.all;	

library work;
use work.tipos.all;

-- Bancada de teste do RISK-V Pipeline com todos os módulos que o compoem: estagio if, 
-- id, ex, mem e wb, módulos: hazard Detection, Forwarding,
-- RAM, Data RAM, ULA, Register File, unidade de controle.
-- Os arquivos de conteúdos das memória de instruçoes - imem.txt (Cache de instruçoes) e 
-- da de dados dmem.txt( cache de Dados) encontram-se definidos
-- na declaraçao da entidade fd_if_id_ex_mem_wb	e sao chamados: "imem.txt" e "dmem.txt"	
-- Esta bancada de teste possui o processo estatistica que coleta todos os índices 
-- necessários para avaliaç±ao de desempenho do processador
-- Este bancda de teste também possui um processo chamado estimulo para controlar o fim 
-- da simulaçao quando uma instruçao de halt for executada.

entity tb_if_id_ex_mem_wb is
    generic(
        imem_init_file: string := "imem.txt";-- Arquivo com programa a ser executado
        dmem_init_file: string := "dmem.txt" -- Arquivo memória de dados 
    );
end entity;

architecture tb_arch of tb_if_id_ex_mem_wb is
	-- Estagio de Busca de instruçoes - if com buffer de saída - BID
    component estagio_if
        generic(
            imem_init_file: string := "imem.txt"
        );
        port(
			-- Entradas
			clock			: in 	std_logic;	-- Base de tempo vinda da bancada de teste
        	id_hd_hazard	: in 	std_logic;	-- Sinal de controle que carrega 0's na parte do RI do 
												-- registrador de saída do if_stage
			id_Branch_nop	: in 	std_logic;	-- Sinal que indica inser4çao de NP devido a desviou pulo
			id_PC_Src		: in 	std_logic;	-- Seleçao do mux da entrada do PC
			id_Jump_PC		: in 	std_logic_vector(31 downto 0) := x"00000000";-- Endereço do Jump
			keep_simulating	: in	Boolean := True;-- Sinal de continue a simulaçao
			
			-- Saídas
			--Registrador de saída do if_stage-if_id
        	BID				: out 	std_logic_vector(63 downto 0) := x"0000000000000000"
        );
    end component;
	
	-- Estágio de decodificaçao e leitura de registradores -id com buffer BEX
    component estagio_id
        port(
			-- Entradas
			clock				: in 	std_logic; 						--  Base de tempo
			BID					: in 	std_logic_vector(063 downto 0);	-- Informaçoes vindas do if
			MemRead_ex			: in	std_logic;						-- Leitura de memória no ex
			rd_ex				: in	std_logic_vector(004 downto 0);	-- Destino noa regs. no ex
			ula_ex				: in 	std_logic_vector(031 downto 0);	-- ULA no estágio Ex
			MemRead_mem			: in	std_logic;						-- Leitura na memória no mem
			rd_mem				: in	std_logic_vector(04 downto 0);	-- Escrita nos regs. no mem	
			ula_mem				: in 	std_logic_vector(031 downto 0);	-- ULA no estágio Mem
			NPC_mem				: in	std_logic_vector(031 downto 0);	-- NPC no estagio mem
        	RegWrite_wb			: in 	std_logic; 						-- Escrita no RegFile vindo de wb
        	writedata_wb		: in 	std_logic_vector(031 downto 0);	-- Escrito no RegFile vindo de wb
        	rd_wb				: in 	std_logic_vector(004 downto 0);	-- Registrador escrito
        	ex_fw_A_Branch		: in 	std_logic_vector(001 downto 0);	-- Seleçao de Branch forwardA
        	ex_fw_B_Branch		: in 	std_logic_vector(001 downto 0);	-- Seleçao de Branch forwardB
			
			-- Saídas
			-- Endereço destino do JUmp ou Desvio
			id_Jump_PC			: out	std_logic_vector(031 downto 0) := x"00000000";		
			id_PC_src			: out	std_logic := '0';				-- Seleciona a entrado do PC
			id_hd_hazard		: out	std_logic := '0';				-- Preserva o BID nao inc. o PC
			id_Branch_nop		: out	std_logic := '0';				-- Inserçao de NOP devido Branch  
																		-- limpa o if_id.ri
			rs1_id_ex			: out	std_logic_vector(004 downto 0);	-- Endereço rs1 no estágio id
			rs2_id_ex			: out	std_logic_vector(004 downto 0);	-- Endereço rs2 no estágio id
			BEX					: out 	std_logic_vector(151 downto 0) := (others => '0'); 	-- ID > EX 
			COP_id				: out	instruction_type := NOP;-- Instrucao no id
			COP_ex				: out 	instruction_type := NOP	-- Instruçao no EX
		);
    end component;
	
	-- Estágio de execuçao e calculo de endereços - ex, combuffer de saída para o estágiomem chamado BMEM
	component estagio_ex
		port (
			clock				: in 	std_logic;					  		-- Relógio do Sistema
      		BEX					: in 	std_logic_vector (151 downto 0);  	-- Dados vindos do ide
			COP_ex				: in 	instruction_type;				  	-- Mnemônico no estágio ex
			ula_mem				: in 	std_logic_vector (031 downto 0);	-- ULA no mem
			rs1_id_ex			: in	std_logic_vector (004 downto 0);    -- rs1 no id passado para o ex
			rs2_id_ex			: in	std_logic_vector (004 downto 0);    -- rs2 no id passado para o ex
			MemRead_mem			: in 	std_logic;					  		-- Leitura na memória no mem
			RegWrite_mem		: in 	std_logic;					  		-- Escrita nos regs. no mem
			rd_mem				: in 	std_logic_vector (04 downto 0);		-- Destino nos regs. no mem
			writedata_wb		: in 	std_logic_vector (031 downto 0);	-- Dado escrito no reg. destino
			RegWrite_wb			: in	Std_logic;							-- Escrita nos regs no  wb
			rd_wb				: in	std_logic_vector (004 downto 0);	-- Destino no rges no  wb
			MemVal_mem			: in	std_logic_vector (031 downto 0);	-- Saída da memória no mem
		
			-- Saídas
			MemRead_ex			: out	std_logic;							-- Leitura da memória no ex 
			rd_ex				: out	std_logic_vector(04 downto 0);		-- Destino dos regs no ex
			ula_ex				: out	std_logic_vector(31 downto 0);		-- ULA no estágio ex
			ex_fw_A_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado comparado em A no id 
																			-- em desvios com forward
        	ex_fw_B_Branch		: out 	std_logic_vector (001 downto 0);	-- Dado a ser comparado 
																			-- no id em desvios forward
        	BMEM				: out 	std_logic_vector (115 downto 0) := (others => '0'); -- Saída mem
			COP_mem				: out 	instruction_type := NOP			  	-- Mnemônico \no mem
		);
	end component; 
	
	-- Estágio de Memória mem, com buffer de saída para o estágio wb chamado BWB
	component estagio_mem
		generic(
        	dmem_init_file: string := "dmem.txt"		  -- Nome do arquivo inicializar memória de dados
    	);
    	port(
        	clock		: in std_logic;						 	-- Base de tempo
        	BMEM		: in std_logic_vector(115 downto 0); 	-- Informaçoes vindas do estágio ex
			COP_mem		: in instruction_type;					-- Mnemônico processada no mem
		
			-- Saídas
        	BWB			: out std_logic_vector(103 downto 0) := (others => '0');-- Informaçoes para wb
			COP_wb 		: out instruction_type := NOP;			-- Mnemônico dprocessada pelo  wb
			RegWrite_mem: out std_logic;						-- Escrita em regs no  mem
			MemRead_mem	: out std_logic;						-- Leitura da memória de dados no mem 
			MemWrite_mem: out std_logic;						-- Escrita na memoria de dados no mem
			MemVal_mem	: out std_logic_vector(031 downto 0);	-- memória no estágio mem
			rd_mem		: out std_logic_vector(004 downto 0);	-- Destino nos regs. no  mem
			ula_mem		: out std_logic_vector(031 downto 0);	-- ULA no mem para o mem
			NPC_mem		: out std_logic_vector(031 downto 0)	-- NPC no  mem
		);
	end component;
	
	-- Estagio de Write-Back - wb cominformaçoes de saida para os demais estágios \
	component estagio_wb
		port (
			-- Entradas
			BWB				: in std_logic_vector(103 downto 0); -- Informaçoes vindas do mem
			COP_wb			: in instruction_type;				 -- Mnemônico da instruçao no wb
		
			-- Saídas
        	writedata_wb	: out std_logic_vector(31 downto 0); -- Valor a ser escrito em reg.
        	rd_wb			: out std_logic_vector(04 downto 0); -- Registrador a ser escrito
			RegWrite_wb		: out std_logic						 -- Escrita nos registradores
		);
	end component;

    --Sinais internos para conexao das portas de if
	signal clock			: std_logic := '1';	-- Base de tempo fornecida pela bancad de teste
    signal id_hd_hazard		: std_logic := '0';	-- Sinal de controle que carrega 0's em RI 
												-- do registrador de saída do if_stage
	signal id_Branch_nop	: std_logic := '0';	-- Sinal de inserçao de nop devido 
												-- a desvio ou pulo
	signal id_PC_Src		: std_logic := '0';	-- Seleçao do mux do PC
	signal id_Jump_PC		: std_logic_vector(31 downto 0) := x"00000000";	-- Endereço Jump
     
	
	-- Período do relógio do Pipeline
	constant clock_period		: time := 10 ns;

    --buffers entre os estágios da pipeline
    signal BID: 	std_logic_vector(063 downto 0) := (others => '0');
    signal BEX: 	std_logic_vector(151 downto 0) := (others => '0');
	signal BMEM: 	std_logic_vector(115 downto 0) := (others => '0');
	signal BWB: 	std_logic_vector(103 downto 0) := (others => '0'); 
	
	-- Sinais para auxilio da depuraçao
	signal 		COP_id		: instruction_type 	:= NOP;
	signal 		COP_ex		: instruction_type 	:= NOP;
	signal 		COP_mem		: instruction_type 	:= NOP;
	signal 		COP_wb		: instruction_type 	:= NOP; 
 

    --sinais que conectam saída dos estágios aos buffers 
	signal writedata_wb		: std_logic_vector(031 downto 0) := (others => '0');
	signal Memval_mem		: std_logic_vector(031 downto 0) := (others => '0');
    signal rd_wb			: std_logic_vector(004 downto 0) := (others => '0'); 
	signal RegWrite_wb		: std_logic;
	signal ula_mem			: std_logic_vector(31 downto 0);
	signal NPC_mem			: std_logic_vector(31 downto 0);
	signal MemRead_ex		: std_logic;
	signal rd_ex			: std_logic_vector(04 downto 0);
	signal rs1_id_ex		: std_logic_vector(04 downto 0);
	signal rs2_id_ex		: std_logic_vector(04 downto 0);
	signal ula_ex			: std_logic_vector(31 downto 0);
	signal ex_fw_A_branch	: std_logic_vector(01 downto 0);
	signal ex_fw_B_branch	: std_logic_vector(01 downto 0);
	signal MemRead_mem		: std_logic;
	signal MemWrite_mem		: std_logic;
	signal RegWrite_mem		: std_logic;
	signal rd_mem			: std_logic_vector(04 downto 0); 
	signal keep_simulating	: boolean := True; 
	signal eof           	:	std_logic 	:= '0';
--    file fptr				: 	text;
--	file fptr1				:	text;
	-- Para execucao com numero diferente de elementos deve mudar o nome do arquivo na linha seguinte e recompilar
	constant C_FILE_NAME_indices 	:	string  	:= "IndicesOut10.txt";
	constant C_FILE_NAME_perfil		:	string		:= "PerfilOut10.txt";
	
begin
	-- Conectando os sinais do estágio if
    fetch : estagio_if 
        generic map(
            imem_init_file => "imem.txt"
        )
        port map(
			-- Entradas
			clock				=> clock,
        	id_hd_hazard		=> id_hd_hazard,
			id_Branch_nop		=> id_Branch_nop,
			id_PC_Src			=> id_PC_Src,
			id_Jump_PC			=> id_Jump_PC,
			keep_simulating		=> keep_simulating,
			
			-- Saída
        	BID					=> BID
        );
	
	-- Conectando os sinais do estágio id
    decode : estagio_id 
        port map(
			-- Entradas
			clock				=> clock, 						--  Base de tempo
			BID					=> BID,							-- Informaçoes vindas  Busca
			MemRead_ex			=> MemRead_ex,					-- Leitura de memória no ex
			rd_ex				=> rd_ex,						-- Destino noa regs. no ex
			ula_ex				=> ULA_ex,						-- ULA no estágio Ex
			MemRead_mem			=> MemRead_mem,					-- Leitura na memória no mem
			rd_mem				=> rd_mem,						-- Escrita nos regs no mem
			ula_mem				=> ULA_mem,						-- Saída da ULA no estágio Mem 
			NPC_mem				=> NPC_mem,
        	RegWrite_wb			=> RegWrite_wb,					-- Escrita no RegFile no wb
        	writedata_wb		=> writedata_wb,				-- Escrito no RegFile no wb
        	rd_wb				=> rd_wb,						-- Registrador escrito
        	ex_fw_A_Branch		=> ex_fw_A_Branch,				-- Seleçao de Branch forwardA
        	ex_fw_B_Branch		=> ex_fw_B_Branch,				-- Seleçao de Branch forwardB 
			
			-- Saídas
			id_Jump_PC			=> id_Jump_PC,					-- Endereço destino do JUmp/Desvio
			id_PC_src			=> id_PC_src,					-- Seleciona a entrado do PC
			id_hd_hazard		=> id_hd_hazard,				-- Preserva o if_id e nao inc. PC
			id_Branch_nop		=> id_Branch_nop,				-- Sinaliza a inserçao de um NOP 
																-- devido ao Branch. limpa o if_id.ri	
			rs1_id_ex			=> rs1_id_ex,					-- Endereço rs1 no estágio id
			rs2_id_ex			=> rs2_id_ex,					-- Endereço rs2 no estágio id
			BEX					=> BEX,							-- Saída do ID para o EX
			COP_id				=> COP_id,						-- Instrucao no estágio id
			COP_ex				=> COP_ex						-- Instruçao passada para EX
        );
		
	-- Conectando os sinais do estágio ex	
	executa: estagio_ex
		port map(
			-- Entradas
			clock				=> clock,			-- Relógio do Sistema
      		BEX					=> BEX, 			-- Dados vindos do estágio Decode
			COP_ex				=> COP_ex,			-- Mnemônico no estágio ex
			ula_mem				=> ula_mem,			-- ULA no estágio de Memória
			rs1_id_ex			=> rs1_id_ex,   	-- rs1 no id passado o ex
			rs2_id_ex			=> rs2_id_ex,   	-- rs2 no id passado o ex
			MemRead_mem			=> MemRead_mem,		-- Leitura na memória no estágio mem
			RegWrite_mem		=> RegWrite_mem,	-- Escrita nos regs. no estágio mem
			rd_mem				=> rd_mem,			-- Destino nos regs. no estágio mem
			writedata_wb		=> writedata_wb,	-- Dado a ser escrito no reg. destino
			MemVal_mem			=> MemVal_mem,		-- Saída da memória no mem
			RegWrite_wb			=> RegWrite_wb,		-- Sinal de escrita nos regs no wb
			rd_wb				=> rd_wb,			-- endereço de destino no rges no wb
		
			-- Saídas
			MemRead_ex			=> MemRead_ex,		-- Leitura da memória no ex 
			rd_ex				=> rd_ex,			-- Destino dos regs no ex
			ULA_ex				=> ULA_ex,			-- Saída da ULA no estágio ex
			ex_fw_A_Branch		=> ex_fw_A_Branch,	-- Comparado em A no id-desvios-forward
        	ex_fw_B_Branch		=> ex_fw_B_Branch,	-- Dado comparado em B no id desvios-forward
        	BMEM				=> BMEM, 			-- Saída para o estágio de Memória
			COP_mem				=> COP_mem			 -- Mnemônico da instruçao mem
		);
		
	-- Conectando os sinais do estágio mem	
	memoria:estagio_mem
		generic map (
        	dmem_init_file  => "dmem.txt" -- Nome do arquivo para inicializar a memória de dados
    	)
   		port map (
		   	-- Entradas
		   	clock			=> clock,		-- Base de tempo
        	BMEM			=> BMEM,		-- Informaçoes vindas do estágio ex
			COP_mem			=> COP_mem,		-- Mnemônico da instruç±ao sendo processada no estágio mem
		
			-- Saídas
       	 	BWB				=> BWB,			-- Informaçoes sendo enviadas para o estágio wb
			COP_wb 			=> COP_wb,		-- Mnemônico da instruçao a ser processada pelo estágio wb
			RegWrite_mem 	=> RegWrite_mem,-- Sinal de escrita em regs no estágio mem
			MemRead_mem		=> MemRead_mem,	-- Sinal de leitura da memória de daods no estágio mem 
			MemWrite_mem	=> MemWrite_mem, -- Sinal de escrita na memoria de dados no estagio mem
			MemVal_mem		=> MemVal_mem,	-- Saída da memória no estagio mem
			rd_mem			=> rd_mem,		-- Endereço de destino nos rges. no estágio mem
			ula_mem			=> ula_mem,		-- Saída da ULA no estágo mem para o estágio mem
			NPC_mem			=> NPC_mem		-- Valor do NPC no estagio mem
    	);
		
	-- Conectando os sinais do estágio wb	
	writeback: estagio_wb
		port map (
			-- Entradas
			BWB				=> BWB, 			-- Informaçoes vindas do estagi mem
			COP_wb			=> COP_wb,			-- Mnemônico da instruçao no estagio wb
			
			-- Saídas
        	writedata_wb	=> writedata_wb, 	-- Valor a ser escrito emregistradores
        	rd_wb			=> rd_wb, 			-- Endereço do registrador a ser escrito
			RegWrite_wb		=> RegWrite_wb		-- Sinal de escrita nos registradores
		);
	
	-- Relógio do Pipeline comperíodo definido pela constnate clock_period
 	clock <= not clock after clock_period / 2 when Keep_simulating = true else
		     clock after clock_period;
 
--processo de coleta de estatísticas
estatisticas: process (clock)
	-- Para execucoes com numero diferente de elemento deve mudar o vakir da variavel na linha seguinte e recompilar
	variable numelementos					: 	integer :=  10;
	variable num_inst						: 	integer :=  0;
	variable num_ciclos						:	integer := 	0;
	variable num_acessos_leitura_dmem		:	integer := 	0;
	variable num_acessos_escrita_dmem		:	integer := 	0;
	variable num_bolhas						:	integer := -4;
	variable num_add						:	integer := 	0;
	variable num_addi						:	integer := 	0;
	variable num_slli						:	integer := 	0;
	variable num_slti						:	integer := 	0;
	variable num_srli						:	integer := 	0; 
	variable num_srai						:	integer := 	0;
	variable num_slt						:	integer := 	0;
	variable num_beq						:	integer := 	0; 
	variable num_bne						:	integer := 	0;
	variable num_blt						:	integer := 	0;
	variable num_lw							:	integer := 	0;
	variable num_sw							:	integer := 	0;
	variable num_jal						:	integer := 	0;
	variable num_jalr						:	integer := 	0;
	variable num_nop						:	integer := -4;
	variable num_halt						:	integer :=  0;
	variable CPI_medio						:	real	:= 0.0;	
	variable fstatus       					:	file_open_status;
    variable file_line     					:	line;
	variable virgula						:	string (1 to 2)	:= ", ";	
	
    
	
	
begin
	
		if clock'event and clock = '1' then	
			if COP_wb /= NOP then 
				num_inst 		:= num_inst 	+ 1;
			end if;
			num_ciclos 		:= num_ciclos 	+ 1; 			
			if MemRead_mem = '1' 	then 
				num_acessos_leitura_dmem := num_acessos_leitura_dmem + 1; 	
			end if;
			if MemWrite_mem = '1'then
				num_acessos_escrita_dmem := num_acessos_escrita_dmem + 1;
			end if;
			if COP_wb = NOP	 then num_bolhas:= num_bolhas 	+ 1; end if;	
			if COP_wb = ADD  then num_add  	:= num_add 		+ 1; end if;
			if COP_wb = addi then num_addi 	:= num_addi 	+ 1; end if;
			if COP_wb = slli then num_slli 	:= num_slli 	+ 1; end if;
			if COP_wb = slti then num_slti 	:= num_slti 	+ 1; end if;
			if COP_wb = srli then num_srli 	:= num_srli 	+ 1; end if;
			if COP_wb = srai then num_srai 	:= num_srai 	+ 1; end if;
			if COP_wb = slt  then num_slt  	:= num_slt 		+ 1; end if;
			if COP_wb = beq  then num_beq  	:= num_beq 		+ 1; end if;
			if COP_wb = bne  then num_bne  	:= num_bne 		+ 1; end if;
			if COP_wb = blt  then num_blt  	:= num_blt 		+ 1; end if;
			if COP_wb = lw	 then num_lw   	:= num_lw 		+ 1; end if;
			if COP_wb = sw	 then num_sw   	:= num_sw 		+ 1; end if;
			if COP_wb = jal  then num_jal  	:= num_jal 		+ 1; end if;
			if COP_wb = jalr then num_jalr 	:= num_jalr 	+ 1; end if; 
			if COP_wb = nop  then num_nop	:= num_nop		+ 1; end if;
			if COP_wb = halt then num_halt  := num_halt		+ 1; end if;
		else
			null;
		end if;
		if num_inst > 0 then 
			CPI_medio := real(real(num_ciclos)/real(num_inst)); 
		else 
			CPI_medio := 0.0;
		end if;	
		-- Registro em arquivo CVS dos dados de desempenho edo processador e do perfil de instru'c~oes executadas
--		if COP_wb = HALT then
			-- Abre o arquivo para escrever os indices de desempenho
--			file_open(fstatus, fptr,  C_FILE_NAME_indices, write_mode);
--			file_open(fstatus, fptr1, C_FILE_NAME_perfil, write_mode);
--			For i in 1	to 1 loop
--				-- primeira linha do arquivo com o nomes das variaveis de desempenho
--				write(file_line, "num_elementos" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_inst" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_ciclos" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_bolhas" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_acessos_leitura" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_acessos_escrita" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "CPI_medio" , right, 2);
--				write(file_line, virgula, right, 2);
--				writeline(fptr, file_line);
--				-- segunda linha do arquivo agora com os dados
--	 	 		write(file_line, to_string(numelementos), right, 2);
--	  			write(file_line, virgula, right, 2);
--      			write(file_line, to_string(num_inst), right, 2);
--	  			write(file_line, virgula, right, 2);
--      			write(file_line, to_string(num_ciclos), right, 2);
--	  			write(file_line, virgula, right, 2);
--	  			write(file_line, to_string(num_bolhas), right, 2);
--	  			write(file_line, virgula, right, 2);
--	  			write(file_line, to_string(num_acessos_leitura_dmem), right, 2);
--	  			write(file_line, virgula, right, 2);
--	  			write(file_line, to_string(num_acessos_escrita_dmem), right, 2);
--	  			write(file_line, virgula, right, 2);
--      			write(file_line, to_string(CPI_medio), right, 2);
--	  			write(file_line, virgula, right, 2);
--      			writeline(fptr, file_line);
--			   -- primeira linha do arquivo de perfil de instrucoes
--			    write(file_line, "num_elementos" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_add" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_addi" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_slli" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_slti" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_srli" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_srai" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_slt" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_beq" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_bne" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_blt" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_lw" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_sw" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_jal" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_jalr" , right, 2);
--				write(file_line, virgula, right, 2);
--				write(file_line, "num_halt" , right, 2);
--				write(file_line, virgula, right, 2);
--				writeline(fptr1, file_line);	
--				-- escreve a segunda linha do arquivo de perfil de instrucoes
--				write(file_line, to_string(numelementos), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_add), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_addi), right, 2);
--	  			write(file_line, virgula, right, 2); 
--				write(file_line, to_string(num_slli), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_slti), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_srli), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_srai), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_slt), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_beq), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_bne), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_blt), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_lw), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_sw), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_jal), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_jalr), right, 2);
--	  			write(file_line, virgula, right, 2);
--				write(file_line, to_string(num_halt), right, 2);
--	  			write(file_line, virgula, right, 2);
--				writeline(fptr1, file_line);	
--   			end loop;
--		end if;
--   		eof       <= '1';
--   		file_close(fptr);
--		file_close(fptr1);   
end process; 

estimulos: process

variable inicio: boolean := true;

begin
	wait until clock'event and clock = '1';
	if inicio then
		inicio := false;
	else
		assert false report "Inicie execuçao."severity note;
		keep_simulating 	<= true;
		wait for 4*clock_Period;
		wait until COP_wb = HALT;
		wait for clock_period;
		keep_simulating 	<= false;
		assert false report "Para execuçao." severity note;	
		wait for clock_period;
		wait; 
	end if;
end process;
    
end architecture;