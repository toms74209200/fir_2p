-- =====================================================================
--  Title		: FIR filter 2 power base coefficient
--
--  File Name	: FIR_2P.vhd
--  Project		: Sample
--  Block		: 
--  Tree		: 
--  Designer	: T.Suzuki - HDK
--  Created		: 2019/02/20
-- =====================================================================
--	Rev.	Date		Designer	Change Description
-- ---------------------------------------------------------------------
--	v0.1	19/02/20	T.Suzuki		First
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.ADD_PAC.all;

entity FIR_2P is
	port(
		nRST		: in	std_logic;							--(n) Reset
		CLK			: in	std_logic;							--(p) Clock
		
		EN			: in	std_logic;							--(p) Data input enable
		IN_DAT		: in	std_logic_vector(11 downto 0);		--(p) Data

--		out_sum0		: out	std_logic_vector(30 downto 0);
--		out_sum1		: out	std_logic_vector(30 downto 0);
--		out_sum2		: out	std_logic_vector(30 downto 0);

		
		OUT_DAT		: out	std_logic_vector(11 downto 0)		--(p) data
		);
end FIR_2P;

architecture RTL of FIR_2P is

-- Signal array --
type	reg_ary_type	is array (0 to 31) of std_logic_vector(11 downto 0);
type	prdct_ary_type	is array (0 to 31) of std_logic_vector(24 downto 0);
type	sum_a_ary_type	is array (0 to 15) of std_logic_vector(25 downto 0);
type	sum_b_ary_type	is array (0 to 7) of std_logic_vector(26 downto 0);
type	sum_c_ary_type	is array (0 to 4) of std_logic_vector(27 downto 0);
type	sum_d_ary_type	is array (0 to 2) of std_logic_vector(28 downto 0);
signal	dat_reg			: reg_ary_type;							-- data register array
signal	prdct			: prdct_ary_type;						-- Product array
signal	sum_a			: sum_a_ary_type;						-- Sum array
signal	sum_b			: sum_b_ary_type;						-- Sum array
signal	sum_c			: sum_c_ary_type;						-- Sum array
signal	sum_d			: sum_d_ary_type;						-- Sum array
signal	sum_e			: std_logic_vector(29 downto 0);		-- Sum array

-- Coefficient table --
type		coef_rom_type	is array(0 to 31) of std_logic_vector(4 downto 0);
constant	coef	: coef_rom_type := (						-- signature & bit shift right
										"0" & X"0",
										"0" & X"9",
										"0" & X"8",
										"0" & X"8",
										"0" & X"8",
										"0" & X"0",
										"1" & X"7",
										"1" & X"6",
										"1" & X"5",
										"1" & X"6",
										"0" & X"0",
										"0" & X"5",
										"0" & X"4",
										"0" & X"3",
										"0" & X"3",
										"0" & X"2",
										"0" & X"3",
										"0" & X"3",
										"0" & X"4",
										"0" & X"5",
										"0" & X"0",
										"1" & X"6",
										"1" & X"5",
										"1" & X"6",
										"1" & X"7",
										"0" & X"0",
										"0" & X"8",
										"0" & X"8",
										"0" & X"8",
										"0" & X"9",
										"0" & X"0",
										"1" & X"A"
										);


-- Function --
function shift_right
	(
		data	: std_logic_vector(11 downto 0);
		shift	: std_logic_vector(4 downto 0)
	)
return std_logic_vector is
variable shift_data	: std_logic_vector(24 downto 0);
variable shift_abs	: integer range 0 to 15;

begin
	shift_abs := CONV_INTEGER(shift(3 downto 0));

	if (shift = 0) then
		shift_data := (others => '0');
	else
		shift_data(shift_data'left) := shift(shift'left);
		shift_data(23 downto 24-shift_abs) := (others => '0');
		shift_data(23-shift_abs downto 12-shift_abs) := data;
		shift_data(11-shift_abs downto 0) := (others => '0');
	end if;

	return shift_data;
end;

begin

-- ***********************************************************
--	Data register
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		dat_reg(0)	<= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (EN = '1') then
			dat_reg(0)	<= IN_DAT;
		end if;
	end if;
end process;

process (CLK, nRST) begin
	for i in 1 to 31 loop
		if (nRST = '0') then
			dat_reg(i)	<= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (EN = '1') then
				dat_reg(i)	<= dat_reg(i-1);
			end if;
		end if;
	end loop;
end process;


-- ***********************************************************
--	Multiplier
-- ***********************************************************
process (CLK, nRST) begin
	for i in 0 to 31 loop
		if (nRST = '0') then 
			prdct(i)	<= (others => '0');
		elsif (CLK'event and CLK = '1') then
			if (EN = '1') then
				prdct(i)	<= shift_right(dat_reg(i), coef(i));
			end if;
		end if;
	end loop;
end process;


-- ***********************************************************
--	Summation
-- ***********************************************************

--	1st			2nd			3rd				4th					5th
-- 00 + 01
--			sum0 + sum1
-- 02 + 03
--						sum16 + sum17
-- 04 + 05
--			sum2 + sum3
-- 06 + 07
--										sum24 + sum25
-- 08 + 09
--			sum4 + sum5
-- 10 + 11
--						sum18 + sum19
-- 12 + 13
--			sum6 + sum7
-- 14 + 15
--																sum28 + sum29
-- 16 + 17
--			sum8 + sum9
-- 18 + 19
--						sum20 + sum21
-- 20 + 21
--			sum10 + sum11
-- 22 + 23
--										sum26 + sum27
-- 24 + 25
--			sum12 + sum13
-- 26 + 27
--						sum22 + sum23
-- 28 + 29
--			sum14 + sum15
-- 30 + 31
--	15		 15 + 8		15 + 8 + 4		15 + 8 + 4 + 2		15 + 8 + 4 + 2 + 1 = 30

-- 1st adder
U_ADD_ARRAY_1 : for i in 0 to 15 generate
	sum_a(i) <= signed_add(prdct(i*2), prdct(i*2+1));
end generate;

-- 2nd adder
U_ADD_ARRAY_2 : for i in 0 to 7 generate
	sum_b(i) <= signed_add(sum_a(i), sum_a(i*2+1));
end generate;

-- 3rd adder
U_ADD_ARRAY_3 : for i in 0 to 3 generate
	sum_c(i) <= signed_add(sum_b(i), sum_b(i*2+1));
end generate;

-- 4th adder
sum_d(0) <= signed_add(sum_c(0), sum_c(1));
sum_d(1) <= signed_add(sum_c(2), sum_c(3));

-- 5th adder
sum_e <= signed_add(sum_d(0), sum_d(1));


-- ***********************************************************
--	Divider
-- ***********************************************************
--process (CLK, nRST) begin
--	if (nRST = '0') then 
--		div <= (others => '0');
--	elsif (CLK'event and CLK = '1') then
--		if (EN = '1') then
--			div <= sum(17 downto 5);
--		end if;
--	end if;
--end process;

--out_sum0 <= sum(16);
--out_sum1 <= sum(24);
--out_sum2 <= sum(28);
--
OUT_DAT <= sum_e(23 downto 12);


end RTL;	-- FIR_2P
