---------------------------------------------------------------------------------------------------------
-----------------------MODULO DE BUSCA - IF -------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use std.env.stop;

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

	signal PC_if, ri_if, PC_selected, PC_plus_4: std_logic_vector(31 downto 0):= x"00000000";
	signal COP_if: instruction_type;
	constant halt_addr: std_logic_vector(31 downto 0) := x"00000400";
	signal data_out : std_logic_vector(31 downto 0);

begin 

	iMEM: ram generic map (32, 4096,imem_init_file)
			  port map (clock, '0', PC_if, x"00000000", data_out);
	
	PC_plus_4 <= std_logic_vector(unsigned(PC_if) + 4);
	COP_if <= get_instruction_type(ri_if);
	PROCESS_IF_PC: process (clock,id_PC_Src,id_Jump_PC,id_branch_nop,id_hd_hazard)
	begin

			if (id_PC_Src = '1') then
				PC_selected <= id_Jump_PC;
			elsif (id_PC_Src = '0') then 
				PC_selected <=  PC_plus_4;
			end if;

			if (id_branch_nop='1') then 
				ri_if <= x"00001013";
			elsif (id_branch_nop='0') then
				ri_iF <= data_out;
			end if;

			if (rising_edge(clock)) then
				BID(63 downto 32) <= PC_if;
				BID(31 downto  0) <= ri_if;

				if (id_hd_hazard = '1' or id_branch_nop = '1') then
					PC_if <= PC_if;
				else
					PC_if <= PC_selected;
				end if;			
			end if;

	end process;

	simulation_control: process
    begin
        wait until keep_simulating = False;
        stop; -- Stops the simulation
	end process;
	

end behavioral;