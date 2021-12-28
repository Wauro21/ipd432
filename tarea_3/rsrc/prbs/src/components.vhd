-- ----------------------------------------------------------------
-- components.vhd
--
-- 2/27/2008 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Components package.
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------

package components is

	-- ------------------------------------------------------------
	-- Linear feedback shift register (LFSR)
	-- ------------------------------------------------------------
	--
	component lfsr is
		generic (
			WIDTH      : integer;
			POLYNOMIAL : std_logic_vector;
			TOPOLOGY   : string;
			INVERT     : boolean
		);
		port (
			clk    : in  std_logic;
			rstN   : in  std_logic;
			load   : in  std_logic;
			seed   : in  std_logic_vector(WIDTH-1 downto 0);
			enable : in  std_logic;
			data   : out std_logic_vector(WIDTH-1 downto 0)
		);
	end component;

	-- ------------------------------------------------------------
	-- Pseudo-random binary sequence (PRBS)
	-- ------------------------------------------------------------
	--
	component prbs is
		generic (
			LFSR_WIDTH : integer;
			POLYNOMIAL : std_logic_vector;
			PRBS_WIDTH : integer
		);
		port (
			clk    : in  std_logic;
			rstN   : in  std_logic;
			load   : in  std_logic;
			seed   : in  std_logic_vector(LFSR_WIDTH-1 downto 0);
			enable : in  std_logic;
			lfsr_q : out std_logic_vector(LFSR_WIDTH-1 downto 0);
			prbs_q : out std_logic_vector(PRBS_WIDTH-1 downto 0)
		);
	end component;

	-- ------------------------------------------------------------
	-- Digital noise source
	-- ------------------------------------------------------------
	--
	component noise is
		generic (
			LFSR_WIDTH  : integer;
			POLYNOMIAL  : std_logic_vector;
			NOISE_TYPE  : string;
			NOISE_SUM   : integer;
			NOISE_WIDTH : integer
		);
		port (
			clk    : in  std_logic;
			rstN   : in  std_logic;
			load   : in  std_logic;
			seed   : in  std_logic_vector(LFSR_WIDTH-1 downto 0);
			enable : in  std_logic;
			q      : out signed(NOISE_WIDTH-1 downto 0)
		);
	end component;

	-- ------------------------------------------------------------
	-- Adder tree
	-- ------------------------------------------------------------
	--
	component adder_tree is
		generic (
			NINPUTS : integer;
			IWIDTH  : integer;
			OWIDTH  : integer
		);
		port (
			rstN   : in  std_logic;
			clk    : in  std_logic;
			d      : in  std_logic_vector(NINPUTS*IWIDTH-1 downto 0);
			q      : out signed(OWIDTH-1 downto 0)
		);
	end component;

	-- ------------------------------------------------------------
	-- Convergent rounding
	-- ------------------------------------------------------------
	--
	component convergent is
		generic (
			IWIDTH  : integer;
			OWIDTH  : integer
		);
		port (
			rstN   : in  std_logic;
			clk    : in  std_logic;
			d      : in  signed(IWIDTH-1 downto 0);
			q      : out signed(OWIDTH-1 downto 0)
		);
	end component;

end package;

