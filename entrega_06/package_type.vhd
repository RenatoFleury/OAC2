---------------------------------------------------------------------------------------
----------Pacote para declara�ao do tipo de instru�oes---------------------------------
---------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- Sessao de daclara�ao do package de tipos de instru�oes
package tipos is
	--tipo e mnem�nicos de instru�ao
	type instruction_type is (ADD, SLT,                     --tipo R
							  ADDI, SLTI, SLLI, SRLI, SRAI, --tipo I
							  LW,                           --tipo load
							  SW,                           --tipo Store
							  BEQ, BNE, BLT,                --tipo Branchs
							  JAL, JALR,                 	--tipo Jumps
							  NOP,							--tipo inventado
							  NOINST,						--tipo nao existente 
							  HALT							--PARE
	);
	
	function get_instruction_type (
		instruction : std_logic_vector(31 downto 0)
	) return instruction_type;

end package tipos;

package body tipos is

	function get_instruction_type (
		instruction : std_logic_vector(31 downto 0)
	) return instruction_type is
		variable opcode: std_logic_vector(6 downto 0);
		variable func3: std_logic_vector(2 downto 0);
		variable func7: std_logic_vector(6 downto 0);
		variable instruction_type_return: instruction_type;
	begin
		opcode := instruction(6 downto 0);
		func3  := instruction(14 downto 12);
		func7  := instruction(31 downto 25);

			if (func7 = "0000000" and func3 = "000" and opcode = "0110011") then
				instruction_type_return := ADD;    
			elsif (func7 = "0000000" and func3 = "010" and opcode = "0110011") then
				instruction_type_return := SLT;    
			elsif (func3 = "000" and opcode = "0010011") then
				instruction_type_return := ADDI;   
			elsif (func3 = "010" and opcode = "0010011") then
				instruction_type_return := SLTI;   
			elsif (func7 = "0000000" and func3 = "001" and opcode = "0010011" and instruction /= x"00001013") then
				instruction_type_return := SLLI;   
			elsif (func7 = "0000000" and func3 = "101" and opcode = "0010011") then
				instruction_type_return := SRLI;   
			elsif (func7 = "0100000" and func3 = "101" and opcode = "0010011") then
				instruction_type_return := SRAI;   
			elsif (func3 = "010" and opcode = "0000011") then
				instruction_type_return := LW;     
			elsif (func3 = "010" and opcode = "0100011") then
				instruction_type_return := SW;     
			elsif (func3 = "000" and opcode = "1100011") then ------------------------ VERIFICAR func3
				instruction_type_return := BEQ;    
			elsif (func3 = "001" and opcode = "1100011") then ------------------------ VERIFICAR func3
				instruction_type_return := BNE;    
			elsif (func3 = "100" and opcode = "1100011") then ------------------------ VERIFICAR func3
				instruction_type_return := BLT;
			elsif (instruction=x"0000006f") then
				instruction_type_return := HALT;
			elsif (opcode = "1101111") then
				instruction_type_return := JAL;
			elsif (func3 = "000" and opcode = "1100111") then
				instruction_type_return := JALR;
			elsif (instruction=x"00000000" or instruction=x"00001013") then
				instruction_type_return := NOP;
			else
				instruction_type_return := NOINST;
			end if;
		return instruction_type_return;
	end;

end package body tipos;