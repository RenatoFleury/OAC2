library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tipos.all;

entity estagio_id is
	port(
	-- Entradas
	clock          : in std_logic; 						          -- Base de tempo- bancada de teste
	BID            : in std_logic_vector(063 downto 0);	-- Informaçoes vindas estágio Busca
	MemRead_ex     : in std_logic;						          -- Leitura de memória no estagio ex
	rd_ex          : in std_logic_vector(004 downto 0);	-- Destino nos regs. no estágio ex
	ula_ex         : in std_logic_vector(031 downto 0);	-- Saída da ULA no estágio Ex
	MemRead_mem    : in std_logic;						          -- Leitura na memória no estágio mem
	rd_mem         : in std_logic_vector(004 downto 0);	-- Escrita nos regs. no est'agio mem
	ula_mem        : in std_logic_vector(031 downto 0);	-- Saída da ULA no estágio Mem 
	NPC_mem        : in std_logic_vector(031 downto 0); -- Valor do NPC no estagio mem
	RegWrite_wb    : in std_logic; 						          -- Escrita no RegFile vindo de wb
	writedata_wb   : in std_logic_vector(031 downto 0);	-- Valor escrito no RegFile - wb
	rd_wb          : in std_logic_vector(004 downto 0);	-- Endereço do registrador escrito
	ex_fw_A_Branch : in std_logic_vector(001 downto 0);	-- Seleçao de Branch forwardA
	ex_fw_B_Branch : in std_logic_vector(001 downto 0);	-- Seleçao de Branch forwardB 
		
	-- Saídas
	id_Jump_PC     : out std_logic_vector(031 downto 0) := x"00000000";     -- Destino JUmp/Desvio
	id_PC_src      : out std_logic := '0';				                          -- Seleciona a entrado do PC
	id_hd_hazard   : out std_logic := '0';				                          -- Preserva o if_id e nao inc. PC
	id_Branch_nop  : out std_logic := '0';				                          -- Inserçao de um NOP devido ao Branch. 
		-- limpa o if_id.ri
	rs1_id_ex      : out std_logic_vector(004 downto 0);	                  -- Endereço rs1 no estágio id
	rs2_id_ex			 : out std_logic_vector(004 downto 0);	                  -- Endereço rs2 no estágio id
	BEX					   : out std_logic_vector(151 downto 0) := (others => '0'); -- Saída do ID > EX
	COP_id				 : out instruction_type := NOP;		                      -- Instrucao no estagio id
	COP_ex				 : out instruction_type := NOP			                      -- Instruçao no estágio id passada> EX
	);
end entity;

architecture behavioral of estagio_id is

	component regfile is
		port(
		-- Entradas
		clock			     : in std_logic;						          -- Base de tempo - Bancada de teste
		RegWrite		   : in std_logic; 					           	-- Sinal de escrita no RegFile
		read_reg_rs1	 : in std_logic_vector(04 downto 0);  -- Endereço do registrador na saída RA
		read_reg_rs2	 : in std_logic_vector(04 downto 0);  -- Endereço do registrador na saída RB
		write_reg_rd	 : in std_logic_vector(04 downto 0);  -- Endereço do registrador a ser escrito
		data_in			   : in std_logic_vector(31 downto 0);  -- Valor a ser escrito no registrador
			
		-- Saídas
		data_out_a     : out std_logic_vector(31 downto 0); -- Valor lido pelo endereço rs1
		data_out_b		 : out std_logic_vector(31 downto 0)  -- Valor lido pelo endercço rs2
		);
	end component;
      
	-- lembrar de inicializar com 0 ou valores equivalentes a um NOP
	signal rs1           : std_logic_vector(4 downto 0)  := (others => '0'); 
	signal rs2           : std_logic_vector(4 downto 0)  := (others => '0'); 
	signal rd            : std_logic_vector(4 downto 0)  := (others => '0');
	
	signal RA_id         : std_logic_vector(31 downto 0) := (others => '0'); 
	signal RB_id         : std_logic_vector(31 downto 0) := (others => '0'); 
	signal data_out_a    : std_logic_vector(31 downto 0) := (others => '0'); 
	signal data_out_b    : std_logic_vector(31 downto 0) := (others => '0');
	
	signal op            : std_logic_vector(6 downto 0)  := (others => '0');
	signal funct7        : std_logic_vector(6 downto 0)  := (others => '0');
	signal funct3        : std_logic_vector(2 downto 0)  := (others => '0');

	signal invalid_instr : std_logic := '0';
	signal RegWrite_id   : std_logic := '0';
	signal MemtoReg_id   : std_logic_vector(1 downto 0)  := (others => '0');
	signal MemWrite_id   : std_logic := '0';
	signal ALUSrcD       : std_logic := '0';
	signal AluOp         : std_logic_vector(2 downto 0)  := (others => '0');
	signal MemRead_id    : std_logic := '0';
	signal stallD        : std_logic := '0';

	signal PC_plus4      : std_logic_vector(31 downto 0) := (others => '0');
	signal immext        : std_logic_vector(31 downto 0) := (others => '0');
	signal is_jal        : std_logic;
	signal instrEx       : std_logic_vector(31 downto 0) := (others =>'0');

begin	
	--Campos relevantes das instruções
	rs2       <= BID(24 downto 20);
	rs1       <= BID(19 downto 15);
	rd        <= BID(11 downto 7);
	
	op        <= BID(6 downto 0);
	funct7    <= BID(31 downto 25);
	funct3    <= BID(14 downto 12);
	
	PC_plus4  <= std_logic_vector(unsigned(BID(63 downto 32)) + 4);
	
	rs1_id_ex <= rs1;
	rs2_id_ex <= BID(24 downto 20);

	COP_ID    <= get_instruction_type(BID(31 downto 0));

	--Instanciação da Memória
	registers : regfile 
		port map(
			clock => clock,
			RegWrite => RegWrite_wb,
			read_reg_rs1 => rs1,
			read_reg_rs2 => rs2,
			write_reg_rd => rd_wb,
			data_in => writedata_wb,
			data_out_a => data_out_a,
			data_out_b => data_out_b
		);

	process(BID,op,funct3,funct7) begin
		case op is
		when "0110011" => --R type

			immext <= (others => '0');
		        if (funct7 = "0000000" and funct3 = "000") then
				invalid_instr <= '0';
				AluOP <= "000";
			elsif (funct7 = "0000000" and funct3 = "010") then
				invalid_instr <= '0';
				AluOP <= "010";
			
			else 
				invalid_instr <= '1';
			end if; 
			
		when "0010011" => --I type
			if (funct3 = "000") then
				immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
				invalid_instr <= '0';
				AluOP <= "000";
			elsif(funct3 = "010") then
				immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
				invalid_instr <= '0';
				AluOP <= "101";	

			elsif  (funct3 = "001"  and funct7 = "0000000") then 
				immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
				invalid_instr <= '0';
				ALUOP <= "011"; 

			elsif  (funct3 = "001"  and funct7 = "0000000") then 
				immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
				invalid_instr <= '0';
				if(BID(31 downto 0) = x"00001013") then
					ALUOP <= "000";
				else
					ALUOP <= "100";
				end if;		
		
			elsif (funct3 = "101" and funct7 = "0100000") then
				immext <= (31 downto 5 => BID(24)) & BID(24 downto 20); -- Checar isso
				invalid_instr <= '0';
				ALUOP <= "101";
			else
				invalid_instr <= '1';
			end if;
		when "0000011" =>	--lw

			immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
			if (funct3 = "010") then
				invalid_instr <= '0';
			else
				invalid_instr <= '1';
			end if;
		when "0100011" => -- sw

			immext <= (31 downto 12 => BID(31)) & BID(31 downto 25) & BID(11 downto 7);
			if (funct3 = "010") then
				invalid_instr <= '0';			
			else
				invalid_instr <= '1';
			end if;
		when "1100011" => -- Branch

			immext <= (31 downto 12 => BID(31)) & BID(7) & BID(30 downto 25) & BID(11 downto 8) & '0';
			if (funct3 = "000" or funct3 = "001" or funct3 = "100") then -- beq, bne, blt
		      		invalid_instr <= '0';
			else
				invalid_instr <= '1';
			end if;
		when "1101111" => -- Branch and link
			 immext <= (31 downto 20 => BID(31)) & BID(19 downto 12) & BID(20) & BID(30 downto 21) & '0';
			 invalid_instr <= '0';
			 is_jal <= '1';
		when "1100111" => -- Jalr
			 immext <= (31 downto 13 => BID(31)) & BID(31 downto 20) & '0';
			 if (funct3 = "000") then
				invalid_instr <= '0';
			 else
				invalid_instr <= '1';
			 end if;
		when "0000000" => -- kind of nop
			 immext <= (others => '0');
			 if (BID(31 downto 0) = x"00000000") then
				invalid_instr <= '0';
			 end if;
		when others =>
			 invalid_instr <= '1';

		end case;
	end process;
	
	-- mesma coisa ano passado?
   	with op select 
        ALUSrcD <= '1' when "0000011", --lw
                   '1' when "0100011", --sw
                   '0' when "0110011", --R type
                   '0' when "1100011", --beq
                   '1' when "0010011", --I type
                   '0' when "1101111", --jal
		   '1' when "1100111", --jalr
		   '0' when others;
   	with op select 
        RegWrite_id <= '1' when "0000011", --lw
                   '0' when "0100011", --sw
                   '1' when "0110011", --R type
                   '0' when "1100011", --beq
                   '1' when "0010011", --I type
                   '1' when "1101111", --jal
		   '1' when "1100111", --jalr
                   '0' when others;
    	with op select 
        MemWrite_id <= '1' when "0100011", --sw
                     '0' when others;

    	with op select 
        MemRead_id  <= '1' when "0000011", --lw
                     '0' when others;

    	with op select 
        MemtoReg_id <= "01" when "0000011", --lw
                      "00" when "0100011", --sw
                      "00" when "0110011", --R type
                      "00" when "1100011", --beq
                      "00" when "0010011", --I type
                      "10" when "1101111", --jal
                      "10" when "1100111", --jalr
                      "00" when others;

	
	-- Branch and jump and link
	
	process(BID,op,immext,RA_id,RB_id,funct3,invalid_instr)
	if(invalid_instr = '1') then
			id_jump_pc <= x"00000400"; -- checar qual a posição certa de erro
			id_pc_src <= '1';
			id_branch_nop <= '1';
	
	elsif (op = "1100011") then
		if(funct3 = "000" and RA_id = RB_id) then 
			id_Jump_PC <= std_logic_vector(unsigned(BID(63 downto 32)) + unsigned(immext));
			id_PC_src <= '1';
			id_branch_nop <= '1';
		elsif(funct3 = "001" and not(to_integer(signed(RA_id)) = to_integer(signed(RB_id)))) then
			id_Jump_PC <= std_logic_vector(unsigned(BID(63 downto 32)) + unsigned(immext));
			id_PC_src <= '1';
			id_branch_nop <= '1';
		elsif(funct3 = "100" and (to_integer(signed(RA_id)) < to_integer(signed(RB_id)))) then
			id_Jump_PC <= std_logic_vector(unsigned(BID(63 downto 32)) + unsigned(immext));
			id_PC_src <= '1';
			id_branch_nop <= '1';
		else 
			id_jump_pc <= x"00000000"; -- checar qual a posição certa de erro
			id_pc_src <= '0';
			id_branch_nop <= '0';
		end if;
	elsif(op = "1101111") then
		id_Jump_PC <= std_logic_vector(unsigned(BID(63 downto 32)) + unsigned(immext));
		id_PC_src <= '1';
		id_branch_nop <= '1';
	else 
			id_jump_pc <= x"00000000"; -- checar qual a posição certa de erro
			id_pc_src <= '0';
			id_branch_nop <= '0';
			
        end if;
	end process;	

	-- Hazard Detection Unit. Provavelmente vai ser necessário realizar o stall também quando MemRead_mem = '1', pois o forwarding vem de ula_mem.
	process(MemRead_ex, MemRead_mem, rd_ex,rd_mem,rs1,rs2) begin
	if (MemRead_ex = '1' and (rd_ex = rs1 or rd_ex = rs2)) then
		id_hd_hazard <= '1';
		stallD <= '1';
	elsif (MemRead_mem = '1' and (rd_mem = rs1 or rd_mem = rs2)) then
		id_hd_hazard <= '1';
		stallD <= '1';
	else
		id_hd_hazard <= '0';
		stallD <= '0';
	end if;

	end process; 
	--Forwarding, verificar Páginas 319 e 320. No forwarding da mem, escrever ula_mem ou npc_mem?
	process(ex_fw_A_Branch, data_out_a,ula_ex,ula_mem) begin
		if (ex_fw_A_Branch = "01") then 
			RA_id <= ula_mem;
		elsif (ex_fw_A_Branch = "10") then 
			RA_id <= ula_ex;
		elsif(ex_fw_A_Branch = "11") then
			RA_id <= NPC_mem;
		else
			RA_id <= data_out_a;
		end if;
	end process;

	process(ex_fw_B_Branch, data_out_b,ula_ex,ula_mem) begin
		if (ex_fw_B_Branch = "01") then
			RB_id <= ula_mem;
		elsif (ex_fw_B_Branch = "10") then
			RB_id <= ula_ex;
		elsif(ex_fw_B_Branch = "11") then
			RB_id <= NPC_mem;
		else
			RB_id <= data_out_b;
		end if;
	end process;

	-- Registrador BEX 
	process(clock) begin
	if(rising_edge(clock) and StallD = '1') then
		BEX <= BEX(151 downto 150) & '0' & BEX(148 downto 0);  
		instrEx<= InstrEx;
	elsif(rising_edge(clock) and StallD = '0') then
		BEX <= MemtoReg_id & RegWrite_id & MemWrite_id & MemRead_id & AluSrcD & AluOP & rd & rs2 & rs1 & PC_plus4 & immext & RB_id & RA_id; 
		instrEx<= BID(31 downto 0);
	else
		BEX <= BEX;
		instrEx<=InstrEx;
	end if;
	end process;

	COP_EX <= get_instruction_type(instrEx);
	
end architecture;
