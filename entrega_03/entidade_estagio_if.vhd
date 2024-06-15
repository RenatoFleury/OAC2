---------------------------------------------------------------------------------------------------------
---------------MOD LO DE BUSCA - IF -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

library work;
use work.tipos.all;


entity estagio_if is
    generic(
        imem_init_file: string := "imem.txt"	
    );
    port(

			clock			: in 	std_logic;	
        	id_hd_hazard	: in 	std_logic;	
											
			id_Branch_nop	: in 	std_logic;	
			id_PC_Src		: in 	std_logic;
			id_Jump_PC		: in 	std_logic_vector(31 downto 0) := x"00000000";	
			keep_simulating	: in	Boolean := True; 
	
        		BID		: out 	std_logic_vector(63 downto 0) := x"0000000000000000");
end entity;

architecture behavioral of estagio_if is
	component ram is
		generic(
			address_bits : integer;
			size		 : integer;
			ram_init_file: string
		);
		port(
			clock, write     : in std_logic;
			address, data_in : in std_logic_vector(address_bits-1 downto 0);
			data_out		 : out std_logic_vector(address_bits-1 downto 0)
		);
	end component;

	signal PC_if, NPC_if, ri_if, PC_selected, PC_write: std_logic_vector(31 downto 0);
	signal COP_if --! nao sei como acessar o package type
	constant halt_addr: std_logic_vector(31 downto 0) := x"00000400";
	signal data_out : std_logic_vector(31 downto 0);

begin 

	iMEM: ram generic map (32, 4096,imem_init_file)
			  port map (clock, '0', PC_if, x"00000000", data_out);
	
	PC_write <= not id_hd_hazard or not id_Branch_nop;
	PC_plus_4 <= PC_if + x"00000004";

	PROCESS_IF_PC: process (clock, id_hd_hazard, id_Branch_nop, id_PC_Src, id_Jump_PC, keep_simulating)
	begin 
			if (rising_edge(clock) and PC_write = '1') then 
				PC_if <= PC_selected;
			end if;
	end process;
	
	PROCESS_IF_MUX1:
			--! confirmar a codificação do pc src
			if (id_PC_Src = '1') then
				mux_out <= id_Jump_PC;
			elsif (id_PC_Src = '0') then 
				mux_out <=  PC_plus_4;
			end if;
			--case id_PC_Src is
			--	when "00" => PC_selected <= NPC_if
			--	when "01" => PC_selected <= halt_addr
			--	when "10" or "11" => PC_selected <= id_Jump_PC
		        --end case;

	end process;

	PROCESS_IF_MUX2:
		       if (id_Branch_nop='1') then 
				INSTR_IF <= x"00000000";
		       else
                                INSTR_IF <= data_out;
		       end if;
	end process;
	
	PROCESS_BID:
		if (rising_edge(clock)) then



end behavioral;