-- ----------------------------------------------------------------
-- noise.vhd
--
-- 4/29/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Uniform or Gaussian noise source generator.
--
-- A parallel output pseudo-random binary sequence (PRBS)
-- generator is used to generate both noise sources. For
-- uniform noise, the parallel PRBS output is used directly.
-- For Gaussian noise, the parallel PRBS is used to generate
-- multiple uniform noise samples simulatenously, and those
-- samples are summed, and then convergent rounded to give
-- the Gaussian(-like) output. At least four samples should
-- be added; the probability distribution of a sum is the
-- convolution of the sample distributions, and for four
-- samples, the distribution is bell-shaped.
--
-- If the output binary value is considered to be a signed
-- fractional integer value from -1.0 to 1.0, then the
-- uniform noise signal has a variance of 1/3 (an input loading
-- factor of LF = -4.8dB), and the Gaussian (four sample average)
-- has an input variance of 1/12 (LF = -10.8dB).
--
-- Uniform noise output has no latency. Gaussian noise has
-- an additional latency due to the sums. The latency is
-- ceil(log2(NOISE_SUM)), eg. 2 clocks for a 4 sample sum.
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library control;
use control.components.all;
use control.lfsr_pkg.all;

-------------------------------------------------------------------

entity noise is
    generic (

    	-- LFSR configuration
		LFSR_WIDTH  : integer := 16;
		POLYNOMIAL  : std_logic_vector := lfsr_polynomial(16);

--		LFSR_WIDTH  : integer := 31;
--		POLYNOMIAL  : std_logic_vector := lfsr_polynomial(31);

        -- Noise source type
        NOISE_TYPE  : string := "UNIFORM";  -- or "GAUSSIAN"

        -- Noise samples sum
        NOISE_SUM   : integer := 4;

		-- Output noise data width
        NOISE_WIDTH : integer := 16
    );
    port (
        -- Clock and reset
        clk    : in  std_logic;
        rstN   : in  std_logic;

        -- Load a starting seed
        load   : in  std_logic;
        seed   : in  std_logic_vector(LFSR_WIDTH-1 downto 0);

        -- Enable control
        enable : in  std_logic;

        -- Noise output
        q      : out signed(NOISE_WIDTH-1 downto 0)
    );
end entity;

-------------------------------------------------------------------

architecture mixed of noise is

    -- ------------------------------------------------------------
    -- Functions
    -- ------------------------------------------------------------
    --
	impure function PRBS_WIDTH return integer is
	begin
		if (NOISE_TYPE = "UNIFORM") then
			return NOISE_WIDTH;
		else
			return NOISE_SUM*NOISE_WIDTH;
		end if;
	end function;

    -- ------------------------------------------------------------
    -- Parameters
    -- ------------------------------------------------------------
    --
	-- Sum output data width
	constant SUM_WIDTH  : integer :=
		NOISE_WIDTH + integer(ceil(log2(real(NOISE_SUM))));

    -- ------------------------------------------------------------
    -- Internal signals
    -- ------------------------------------------------------------
    --
	signal uniform : std_logic_vector(PRBS_WIDTH-1 downto 0);
	signal sum     : signed(SUM_WIDTH-1 downto 0);

begin

    -- ------------------------------------------------------------
    -- Parallel output PRBS generator
    -- ------------------------------------------------------------
    --
	u1: prbs
    generic map (
        LFSR_WIDTH => LFSR_WIDTH,
        POLYNOMIAL => POLYNOMIAL,
        PRBS_WIDTH => PRBS_WIDTH
    )
    port map (
        clk    => clk,
        rstN   => rstN,
        load   => load,
        seed   => seed,
        enable => enable,
        prbs_q => uniform
    );

    -- ------------------------------------------------------------
    -- Uniform noise
    -- ------------------------------------------------------------
    --
	g1: if (NOISE_TYPE = "UNIFORM") generate
		q <= signed(uniform);
	end generate;

    -- ------------------------------------------------------------
    -- Gaussian noise
    -- ------------------------------------------------------------
    --
	g2: if (NOISE_TYPE = "GAUSSIAN") generate

		-- Sum the uniform noise samples
		-- (interpreted as signed values)
		u2: adder_tree
		generic map (
			NINPUTS => NOISE_SUM,
			IWIDTH  => NOISE_WIDTH,
			OWIDTH  => SUM_WIDTH
		)
		port map (
			rstN   => rstN,
			clk    => clk,
			d      => uniform,
			q      => sum
		);

		-- Convergent round the sum to the output width
		u3: convergent
			generic map (
				IWIDTH  => SUM_WIDTH,
				OWIDTH  => NOISE_WIDTH
			)
			port map (
				rstN   => rstN,
				clk    => clk,
				d      => sum,
				q      => q
			);

	end generate;

end architecture;

