------------------------------------------------------------------
-----------------------MODULO DE BUSCA - IF ----------------------
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use std.env.stop;

library work;
use work.tipos.all;

entity estagio_if_grupo_09 is
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

architecture behavioral of estagio_if_grupo_09 is
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

	signal PC_if, ri_if, PC_selected, PC_plus_4: std_logic_vector(31 downto 0):= x"00000000";
	signal COP_if: instruction_type;
	constant halt_addr: std_logic_vector(31 downto 0) := x"00000400";
	signal data_out : std_logic_vector(31 downto 0);
	signal halt_sig: std_logic:='0';

begin 

	iMEM: ram generic map (32, 4096,imem_init_file)
			  port map (clock, '0', PC_if, x"00000000", data_out);
	
	PC_plus_4 <= std_logic_vector(unsigned(PC_if) + 4);
	COP_if <= get_instruction_type(ri_if);
	
	PROCESS_MUX_1: process (id_PC_Src,id_Jump_PC,PC_plus_4)
	begin
		if (id_PC_Src = '1') then
			PC_selected <= id_Jump_PC;
		elsif (id_PC_Src = '0') then 
			PC_selected <=  PC_plus_4;
		end if;
	end process;

	PROCESS_MUX_2: process (id_branch_nop,data_out)
	begin
		if (id_branch_nop='1') then 
			ri_if <= x"00001013";
		elsif (id_branch_nop='0') then
			ri_iF <= data_out;
		end if;
	end process;

	REG_PC: process (clock)
	begin
		if ((id_hd_hazard = '0' and halt_sig = '0') and rising_edge(clock)) then
			PC_if <= PC_selected;
		else
			PC_if <= PC_if;
		end if;
	end process;

	REG_BID: process (clock)
	begin
		if (id_hd_hazard = '0' and rising_edge(clock)) then
			BID(63 downto 32) <= PC_if;
			BID(31 downto  0) <= ri_if;
		end if;
	end process;

	simulation_control: process
    begin
        wait until (ri_if = x"0000006F" and falling_edge(clock)); -- Stops the simulation
		halt_sig <= '1';
	end process;

	debuger_control: process
	begin
		wait until (keep_simulating = False);
		stop;
	end process;

end behavioral;
