LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY alu IS
	PORT (
		-- Entradas
		a_in	  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  	-- Entrada "a" de dados
		b_in      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  		-- Entrada "b" de dados
		c_in	  : IN STD_LOGIC;				-- Entrada de carry (usada nas opera��es RR e RL)	
		op_sel	  : IN STD_LOGIC_VECTOR(3 DOWNTO 0);  	-- Entrada de sele��o de opera��o
		bit_sel	  : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  	-- Entrada de sele��o de bit (usada nas opera��es BS e BC)
		-- Sa�das
		r_out	  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 	-- Sa�da do resultado
		c_out	  : OUT STD_LOGIC;				-- Sa�da de carry/barrow
		dc_out	  : OUT STD_LOGIC;				-- Sa�da de digit carry/barrow
		z_out	  : OUT STD_LOGIC 				-- Sa�da de zero
	);
END ENTITY;

ARCHITECTURE arch OF alu IS
	-- Sinais tempor�rios
	SIGNAL a_temp, b_temp, r_temp  : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL bs_temp		     : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL dc_temp		     : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL z_temp	  	     : STD_LOGIC;					 
	
BEGIN
	
	a_temp <= '0' & a_in;
	b_temp <= '0' & b_in;
	
	WITH bit_sel SELECT
		bs_temp <= "00000001" WHEN "000",
			    "00000010" WHEN "001",
			    "00000100" WHEN "010",
			    "00001000" WHEN "011",
			    "00010000" WHEN "100",
			    "00100000" WHEN "101",
			    "01000000" WHEN "110",
		                    "10000000" WHEN "111";
		
	dc_temp <= ('0' & a_temp(3 DOWNTO 0)) + ('0' & b_temp(3 DOWNTO 0)) WHEN op_sel = "0110" ELSE
		    ('0' & a_temp(3 DOWNTO 0)) - ('0' & b_temp(3 DOWNTO 0)) WHEN op_sel = "0111" ELSE
		    "00000";

	WITH op_sel SELECT
		r_temp <= -- Opera��es l�gicas
			 a_temp AND b_temp 	WHEN "0000",
			 a_temp OR b_temp 	WHEN "0001",
			 a_temp XOR b_temp 	WHEN "0010",
			 '0' & NOT a_in		WHEN "0011",
					 
			 -- Opera��es aritm�ticas
			 a_temp + 1   	WHEN "0100",
			 a_temp - 1	WHEN "0101",
			 a_temp + b_temp	WHEN "0110",
			 a_temp - b_temp	WHEN "0111",
					 
			 -- Swap e clear
			 '0' & a_temp(3 DOWNTO 0) & a_temp(7 DOWNTO 4) WHEN "1000",	 
			 "000000000"				      WHEN "1001",
					 
			 -- Rota��o
			 a_temp(0) & c_in & a_temp(7 DOWNTO 1) WHEN "1010",
			 a_temp(7) & a_temp(6 DOWNTO 0) & c_in WHEN "1011",
					 
			 -- Bit set e bit clear	
			 '0' & bs_temp OR a_in             WHEN "1100", 
			 '0' & (NOT bs_temp) AND a_in WHEN "1101", 
					 
			 -- Passa
			 a_temp WHEN "1110",
			 b_temp WHEN "1111";
	
	r_out <= r_temp(7 DOWNTO 0);
	c_out <= NOT r_temp(8) WHEN op_sel = "0111" ELSE
		r_temp(8);
	
	dc_out <= dc_temp(4) WHEN op_sel = "0110" ELSE
		 NOT dc_temp(4) WHEN op_sel = "0111" ELSE 
	                 '0'; 
	
	WITH bit_sel SELECT					
		z_temp <= a_in(0) WHEN "000",
			  a_in(1) WHEN "001",
			  a_in(2) WHEN "010",
			  a_in(3) WHEN "011",
			  a_in(4) WHEN "100",
			  a_in(5) WHEN "101",
			  a_in(6) WHEN "110",
			  a_in(7) WHEN "111";
	
	z_out <= z_temp WHEN op_sel = "1100" OR op_sel = "1101" ELSE
	               '1' WHEN r_temp(7 DOWNTO 0) = "00000000" ELSE 
	               '0';
	         
END arch;

