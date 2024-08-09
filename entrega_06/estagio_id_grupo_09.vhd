library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.tipos.all;

entity estagio_id_grupo_09 is
    port(
		-- Entradas
		clock               : in	std_logic;                       -- Base de tempo- bancada de teste
		BID                 : in	std_logic_vector(063 downto 0);  -- Informacoes vindas estagio Busca
		MemRead_ex          : in	std_logic;                       -- Leitura de memoria no estagio ex
		rd_ex               : in	std_logic_vector(004 downto 0);  -- Destino nos regs. no estagio ex
		ula_ex              : in	std_logic_vector(031 downto 0);  -- Saida da ULA no estagio Ex
		MemRead_mem         : in	std_logic;                       -- Leitura na memoria no estagio mem
		rd_mem              : in	std_logic_vector(004 downto 0);  -- Escrita nos regs. no estagio mem
		ula_mem             : in	std_logic_vector(031 downto 0);  -- Saada da ULA no estagio Mem 
		NPC_mem             : in	std_logic_vector(031 downto 0);  -- Valor do NPC no estagio mem
		RegWrite_wb         : in	std_logic;                       -- Escrita no RegFile vindo de wb
		writedata_wb        : in	std_logic_vector(031 downto 0);  -- Valor escrito no RegFile - wb
		rd_wb               : in	std_logic_vector(004 downto 0);  -- Endereco do registrador escrito
		ex_fw_A_Branch      : in	std_logic_vector(001 downto 0);  -- Selecao de Branch forwardA
		ex_fw_B_Branch      : in	std_logic_vector(001 downto 0);  -- Selecao de Branch forwardB 

		-- Saidas
		id_Jump_PC          : out	std_logic_vector(031 downto 0) := x"00000000";-- Destino JUmp/Desvio
		id_PC_src           : out	std_logic := '0';				-- Seleciona a entrado do PC
		id_hd_hazard        : out	std_logic := '0';				-- Preserva o if_id e nao inc. PC
		id_Branch_nop       : out	std_logic := '0';				-- Insercao de um NOP devido ao Branch. 
		                                                            -- limpa o if_id.ri
		rs1_id_ex           : out	std_logic_vector(004 downto 0);	-- Endereco rs1 no estagio id
		rs2_id_ex           : out	std_logic_vector(004 downto 0);	-- Endereco rs2 no estagio id
		BEX                 : out	std_logic_vector(151 downto 0) := (others => '0');-- Saida do ID > EX
		COP_id              : out	instruction_type  := NOP;		-- Instrucao no estagio id
		COP_ex              : out	instruction_type := NOP			-- Instrucao no estagio id passada> EX
    );
end entity;

architecture behavioral of estagio_id_grupo_09 is

    component regfile is
    port(
		-- Entradas
		clock			: 	in 		std_logic;						-- Base de tempo - Bancada de teste
        RegWrite		: 	in 		std_logic; 						-- Sinal de escrita no RegFile
        read_reg_rs1	: 	in 		std_logic_vector(04 downto 0);	-- Endereco do registrador na saida RA
        read_reg_rs2	: 	in 		std_logic_vector(04 downto 0);	-- Endereco do registrador na saida RB
        write_reg_rd	: 	in 		std_logic_vector(04 downto 0);	-- Endereco do registrador a ser escrito
        data_in			: 	in 		std_logic_vector(31 downto 0);	-- Valor a ser escrito no registrador
		
		-- Sa das
        data_out_a		: 	out 	std_logic_vector(31 downto 0);	-- Valor lido pelo endere o rs1
        data_out_b		: 	out 	std_logic_vector(31 downto 0) 	-- Valor lido pelo enderc o rs2
    );
    end component;
        -- lembrar de inicializar com 0 ou valores equivalentes a um NOP
	signal op : std_logic_vector(6 downto 0) := (others => '0');
	signal rs1,rs2,rd : std_logic_vector(4 downto 0) := (others => '0'); 
	signal RA_id,RB_id, data_out_a,data_out_b : std_logic_vector(31 downto 0) := (others => '0'); 
	signal ImmSrcD : std_logic_vector(2 downto 0) := (others => '0');
	signal extend_bits: std_logic_vector(31 downto 7) := (others => '0');
	signal invalid_instr : std_logic := '0';
	signal funct7 : std_logic_vector(6 downto 0) := (others => '0');
	signal funct3, AluOp : std_logic_vector(2 downto 0) := (others => '0');
	signal stallD, ALUSrcD,MemWrite_id,MemRead_id,RegWrite_id : std_logic := '0';
	signal MemtoReg_id : std_logic_vector(1 downto 0) := (others => '0');
	signal PC_plus4 : std_logic_vector(31 downto 0) := (others => '0');
	signal immext : std_logic_vector(31 downto 0) := (others => '0');
	signal is_jump : std_logic;
	signal instrEx: std_logic_vector(31 downto 0):=(others =>'0');
	signal rs1_bool, rs2_bool : std_logic := '0';
	signal SEPC, SCAUSE : std_logic_vector(31 downto 0):= (others => '0');
	

begin	
	PC_plus4<= std_logic_vector(unsigned(BID(63 downto 32)) + 4);
	--Campos relevantes das instru  es
	funct7 <= BID(31 downto 25);
	rs2 <= BID(24 downto 20);
	rs1 <= BID(19 downto 15);
	funct3 <= BID(14 downto 12);
	rd  <= BID(11 downto 7);
	op <= BID(6 downto 0);

	rs1_id_ex <= rs1;
	rs2_id_ex <= BID(24 downto 20);

	COP_ID <= get_instruction_type(BID(31 downto 0));

	--Instancia  o da Mem ria
	registers : regfile port map(clock => clock,
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
			rs1_bool <= '1';
			rs2_bool <= '1';
			immext <= (others => '0');
			is_jump <= '0';
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
			rs1_bool <= '1';
			rs2_bool <= '0';
			is_jump <= '0';			
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
			rs1_bool <= '1';
			rs2_bool <= '0';
			is_jump <= '0';
			ALUOP <= "000";
			immext <= (31 downto 12 => BID(31)) & BID(31 downto 20);
			if (funct3 = "010") then
				invalid_instr <= '0';
			else
				invalid_instr <= '1';
			end if;
		when "0100011" => -- sw
			rs1_bool <= '1';
			rs2_bool <= '1';

			immext <= (31 downto 12 => BID(31)) & BID(31 downto 25) & BID(11 downto 7);
			if (funct3 = "010") then
				invalid_instr <= '0';			
			else
				invalid_instr <= '1';
			end if;
		when "1100011" => -- Branch
			rs1_bool <= '1';
			rs2_bool <= '1';
			is_jump <= '1';
			immext <= (31 downto 12 => BID(31)) & BID(7) & BID(30 downto 25) & BID(11 downto 8) & '0';
			if (funct3 = "000" or funct3 = "001" or funct3 = "100") then -- beq, bne, blt
		      		invalid_instr <= '0';
			else
				invalid_instr <= '1';
			end if;
		when "1101111" => -- Jal
			rs1_bool <= '0';
			rs2_bool <= '0';
			 immext <= (31 downto 20 => BID(31)) & BID(19 downto 12) & BID(20) & BID(30 downto 21) & '0';
			 invalid_instr <= '0';
			 is_jump <= '1';
		when "1100111" => -- Jalr
			rs1_bool <= '1';
			rs2_bool <= '0';
			is_jump <= '1';
			 immext <= (31 downto 13 => BID(31)) & BID(31 downto 20) & '0';
			 if (funct3 = "000") then
				invalid_instr <= '0';
			 else
				invalid_instr <= '1';
			 end if;
		when "0000000" => -- kind of nop
			rs1_bool <= '0';
			rs2_bool <= '0';
			is_jump <= '0';
			 immext <= (others => '0');
			 if (BID(31 downto 0) = x"00000000") then
				invalid_instr <= '0';
			 end if;
		when others =>
			 invalid_instr <= '1';
			 is_jump <= '0';

		end case;
	end process;
	
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
	process(BID,op,immext,RA_id,RB_id,funct3,invalid_instr) begin
	if(invalid_instr = '1') then
			id_jump_pc <= x"00000400";
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
			id_jump_pc <= x"00000000";
			id_pc_src <= '0';
			id_branch_nop <= '0';
		end if;
	elsif(op = "1101111") then
		id_Jump_PC <= std_logic_vector(unsigned(BID(63 downto 32)) + unsigned(immext));
		id_PC_src <= '1';
		id_branch_nop <= '1';
	elsif(op = "1100111") then 
		id_jump_pc <= std_logic_vector(unsigned(RA_id) + unsigned(immext)) and x"FFFFFFFE";
		id_pc_src <= '1';
		id_branch_nop <= '1';
	else 
		id_jump_pc <= x"00000000";
		id_pc_src <= '0';
		id_branch_nop <= '0';
			
	end if;
	end process;	

	-- Hazard Detection Unit
	process(MemRead_ex, MemRead_mem, rd_ex,rd_mem,rs1,rs2,rs1_bool,rs2_bool) begin
	if (MemRead_ex = '1' and ((rd_ex = rs1 and rs1_bool = '1') or (rd_ex = rs2 and rs2_bool = '1')) and (rd_ex/="00000")) then
		id_hd_hazard <= '1';
		stallD <= '1';
	elsif (MemRead_mem = '1'and is_jump = '1' and ((rd_mem = rs1 and rs1_bool = '1') or (rd_mem = rs2 and rs2_bool = '1')) and (rd_mem/="00000")) then
		id_hd_hazard <= '1';
		stallD <= '1';
	else
		id_hd_hazard <= '0';
		stallD <= '0';
	end if;
	end process;

	--Forwarding
	process(ex_fw_A_Branch, data_out_a,ula_ex,ula_mem, NPC_mem, rs1_bool, is_jump,clock) begin
		if(is_jump = '1' and rs1_bool = '1') then
			if (ex_fw_A_Branch = "01") then 
				RA_id <= ula_mem;
			elsif (ex_fw_A_Branch = "10") then 
				RA_id <= ula_ex;
			elsif(ex_fw_A_Branch = "11") then
				RA_id <= NPC_mem;
			else
				RA_id <= data_out_a;
			end if;
		else
			RA_id <= data_out_a;
		end if;
	end process;

	process(ex_fw_B_Branch, data_out_b,ula_ex,ula_mem,NPC_mem,rs2_bool,is_jump,clock) begin
		if(is_jump = '1' and rs2_bool = '1') then
			if (ex_fw_B_Branch = "01") then 
				RB_id <= ula_mem;
			elsif (ex_fw_B_Branch = "10") then 
				RB_id <= ula_ex;
			elsif(ex_fw_B_Branch = "11") then
				RB_id <= NPC_mem;
			else
				RB_id <= data_out_b;
			end if;
		else
			RB_id <= data_out_b;
		end if;
	end process;

	-- Registrador BEX 
	process(clock) begin
		if(rising_edge(clock) and StallD = '1') then
			BEX <=MemtoReg_id & '0' & '0' & '0' & AluSrcD & AluOP & rd & rs2 & rs1 & PC_plus4 & immext & RB_id & RA_id;
			instrEx<= x"00000000";
		elsif(rising_edge(clock) and StallD = '0') then
			BEX <= MemtoReg_id & RegWrite_id & MemWrite_id & MemRead_id & AluSrcD & AluOP & rd & rs2 & rs1 & PC_plus4 & immext & RB_id & RA_id; 
			instrEx<= BID(31 downto 0);
		else
			BEX <= BEX;
			instrEx<=InstrEx;
		end if;
		end process;

	COP_EX <= get_instruction_type(instrEx);
	
	process(clock, invalid_instr, BID) begin
		if (invalid_instr = '1') then
			SEPC <= BID(63 downto 32);
			SCAUSE <= x"00000002";
		else
			SEPC <= SEPC;
			SCAUSE <= SCAUSE;
		end if;
	end process;
end architecture;