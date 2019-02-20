-- =====================================================================
--  Title		: Signed adder
--
--  File Name	: SGND_ADD.vhd
--  Project		: Sample
--  Block		: 
--  Tree		: 
--  Designer	: toms74209200
--  Created		: 2017/03/03
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package ADD_PAC is
	function signed_add
		(
			a1	: std_logic_vector;
			b1	: std_logic_vector
		)	return std_logic_vector;
end ADD_PAC;

package body ADD_PAC is

	function signed_add
		(
			a1	: std_logic_vector;
			b1	: std_logic_vector
		)	
	return std_logic_vector is
	variable s : std_logic_vector((a1'length) downto 0);
	
variable a : std_logic_vector((a1'length - 1) downto 0);
variable b : std_logic_vector((b1'length - 1) downto 0);

begin


a := a1;
b := b1;

	if ((a(a'length - 1) = '0') and (b(b'length - 1) = '0')) then			-- a + b
		s := ('0' & a) + ('0' & b);
	elsif (a(a'length - 1) = '1' and b(b'length - 1) = '1') then			-- -a + (-b)
		s((s'length) - 1) := '1';
		s((s'length) - 2 downto 0) := ('0' & a((a'length) - 2 downto 0)) + ('0' & b((b'length) - 2 downto 0));
	elsif (a(a'length - 1) = '1' and b(b'length - 1) = '0') then			-- -a + b
		if (a((a'length) - 2 downto 0) > b((b'length) - 2 downto 0)) then	-- |a| > |b|	-(a - b)
			s((s'length) - 1) := '1';
			s((s'length) - 2 downto 0) := ('0' & a((a'length) - 2 downto 0)) - ('0' & b((b'length) - 2 downto 0));
		else																-- |a| < |b|	b - a
			s((s'length) - 1) := '0';
			s((s'length) - 2 downto 0) := ('0' & b((b'length) - 2 downto 0)) - ('0' & a((a'length) - 2 downto 0));
		end if;
	else																	-- a + (-b)
		if (a((a'length) - 2 downto 0) > b((b'length) - 2 downto 0)) then	-- |a| > |b|	a - b
			s((s'length) - 1) := '0';
			s((s'length) - 2 downto 0) := ('0' & a((a'length) - 2 downto 0)) - ('0' & b((b'length) - 2 downto 0));
		else																-- |a| < |b|	-(b - a)
			s((s'length) - 1) := '1';
			s((s'length) - 2 downto 0) := ('0' & b((b'length) - 2 downto 0)) - ('0' & a((a'length) - 2 downto 0));
		end if;
	end if;

return s;

end;

end ADD_PAC;
