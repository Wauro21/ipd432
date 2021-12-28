-- ----------------------------------------------------------------
-- convergent.vhd
--
-- 4/28/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Convergent rounding, i.e., round 0.5 to even.
--
-- ----------------------------------------------------------------
-- Implementation details
-- ----------------------
--
-- Convergent rounding can be implemented using conditional
-- logic for each of the possible input cases, however,
-- synthesis tests showed that this results in more logic.
--
-- This component implements convergent rounding by selecting
-- between two possible output values; the input value truncated,
-- or the input value plus half truncated. The output value
-- is selected based on the following example.
--
-- Given a 5-bit input rounded to a 3-bit output, the 5-bit
-- input can be considered to be a fractional integer with
-- 3-bits whole and 2-bits fractional part. The desired
-- convergent rounding input-to-output response is
--
--  ----------------------------------------------------
-- |      Input     | Output ||   Truncated    | Output |
-- |----------------|--------||----------------| mux    |
-- | signed| binary | signed ||Input |Input+0.5| select |
-- |----------------|--------||----------------|--------|
-- |       |        |        ||      |         |        |
-- | -4.00 | 100.00 |   -4   ||  -4  |  -4     |  0/1   |
-- | -3.75 | 100.01 |   -4   ||  -4  |  -4     |  0/1   |
-- | -3.50 | 100.10 |   -4   ||  -4  |  -3     |    0   |
-- | -3.25 | 100.11 |   -3   ||  -4  |  -3     |    1   |
-- |       |        |        ||      |         |        |
-- | -3.00 | 101.00 |   -3   ||  -3  |  -3     |  0/1   |
-- | -2.75 | 101.01 |   -3   ||  -3  |  -3     |  0/1   |
-- | -2.50 | 101.10 |   -2   ||  -3  |  -2     |    1   |
-- | -2.25 | 101.11 |   -2   ||  -3  |  -2     |    1   |
-- |       |        |        ||      |         |        |
-- | -2.00 | 110.00 |   -2   ||  -2  |  -2     |  0/1   |
-- | -1.75 | 110.01 |   -2   ||  -2  |  -2     |  0/1   |
-- | -1.50 | 110.10 |   -2   ||  -2  |  -1     |    0   |
-- | -1.25 | 110.11 |   -1   ||  -2  |  -1     |    1   |
-- |       |        |        ||      |         |        |
-- | -1.00 | 111.00 |   -1   ||  -1  |  -1     |  0/1   |
-- | -0.75 | 111.01 |   -1   ||  -1  |  -1     |  0/1   |
-- | -0.50 | 111.10 |    0   ||  -1  |   0     |    1   |
-- | -0.25 | 111.11 |    0   ||  -1  |   0     |    1   |
-- |       |        |        ||      |         |        |
-- |  0.00 | 000.00 |    0   ||   0  |   0     |  0/1   |
-- |  0.25 | 000.01 |    0   ||   0  |   0     |  0/1   |
-- |  0.50 | 000.10 |    0   ||   0  |   1     |    0   |
-- |  0.75 | 000.11 |    1   ||   0  |   1     |    1   |
-- |       |        |        ||      |         |        |
-- |  1.00 | 001.00 |    1   ||   1  |   1     |  0/1   |
-- |  1.25 | 001.01 |    1   ||   1  |   1     |  0/1   |
-- |  1.50 | 001.10 |    2   ||   1  |   2     |    1   |
-- |  1.75 | 001.11 |    2   ||   1  |   2     |    1   |
-- |       |        |        ||      |         |        |
-- |  2.00 | 010.00 |    2   ||   2  |   2     |  0/1   |
-- |  2.25 | 010.01 |    2   ||   2  |   2     |  0/1   |
-- |  2.50 | 010.10 |    2   ||   2  |   3     |    0   |
-- |  2.75 | 010.11 |    3   ||   2  |   3     |    1   |
-- |       |        |        ||      |         |        |
-- |  3.00 | 011.00 |    3   ||   3  |   3     |  0/1   |
-- |  3.25 | 011.01 |    3   ||   3  |   3     |  0/1   |
-- |  3.50 | 011.10 |    3   ||   3  |   4     |    0   |
-- |  3.75 | 011.11 |    3   ||   3  |   4     |    0   |
-- |       |        |        ||      |         |        |
--  ----------------------------------------------------
--
-- Where in many places, the output multiplexer control can
-- select the correct output with the multiplexer select control
-- either 0 or 1 (0/1). If the multiplexer select control
-- defaults to 1, then the two 0 selection conditions are;
--  * select 0 when the input LSBs are 0.10, and
--  * select 0 to saturate the maximum output value.
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- ----------------------------------------------------------------

entity convergent is
	generic (
		-- Input data width (must be greater than output width)
		IWIDTH  : integer;

		-- Output data width
		OWIDTH  : integer
	);
	port (
		-- Reset and clock
		rstN   : in  std_logic;
		clk    : in  std_logic;

		-- Input data
		d      : in  signed(IWIDTH-1 downto 0);

		-- Output data
		q      : out signed(OWIDTH-1 downto 0)
	);
end entity;

-- ----------------------------------------------------------------

architecture behave of convergent is

	-- ------------------------------------------------------------
	-- Constants
	-- ------------------------------------------------------------
	--
	-- Truncation bit width
	constant TWIDTH : integer := IWIDTH-OWIDTH;

	-- Binary value for an even half value
	constant even_half : std_logic_vector(TWIDTH downto 0) :=
		std_logic_vector(to_unsigned(2**(TWIDTH-1),TWIDTH+1));

	-- Binary value for maximum output value
	constant max : std_logic_vector(IWIDTH-1 downto TWIDTH) :=
		std_logic_vector(to_unsigned(2**(OWIDTH-1)-1,OWIDTH));

	-- ------------------------------------------------------------
	-- Signals
	-- ------------------------------------------------------------
	--
	-- Input MSBs
	signal msbs : std_logic_vector(IWIDTH-1 downto TWIDTH);

	-- Truncation bits plus one bit
	signal lsbs : std_logic_vector(TWIDTH downto 0);

	-- Two output options
	-- * a = the input data with one fractional bit
	-- * b = the input data with one fractional bit + 0.5
	--
	-- Depending on the input data, these two values may
	-- be identical.
	--
	signal a : signed(IWIDTH-1 downto TWIDTH-1);
	signal b : signed(IWIDTH-1 downto TWIDTH-1);

	-- Multiplexer control
	signal sel : std_logic;

begin

	-- ------------------------------------------------------------
	-- Output multiplexer
	-- ------------------------------------------------------------
	--
	-- Inputs
	--
	-- Input data truncated
	a <= d(IWIDTH-1 downto TWIDTH-1);
	--
	-- Input data plus half
	b <= d(IWIDTH-1 downto TWIDTH-1) + 1;

	-- Selector control
	--
	-- MSBs for saturation detection
	msbs <= std_logic_vector(d(IWIDTH-1 downto TWIDTH));
	--
	-- LSBs for even-valued half detection
	lsbs <= std_logic_vector(d(TWIDTH downto 0));

	sel <= '0' when ((msbs = max) or (lsbs = even_half)) else '1';

	-- ------------------------------------------------------------
	-- Output register
	-- ------------------------------------------------------------
	--
	process(clk, rstN)
	begin
		if (rstN = '0') then
			q <= (others => '0');
		elsif rising_edge(clk) then
			if (sel = '0') then
				q <= a(IWIDTH-1 downto TWIDTH);
			else
				q <= b(IWIDTH-1 downto TWIDTH);
			end if;
		end if;
	end process;

end architecture;