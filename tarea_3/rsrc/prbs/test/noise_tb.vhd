-------------------------------------------------------------------
-- noise_tb.vhd
--
-- 4/29/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Digital noise source testbench.
--
-- The testbench currently just enables the noise source and
-- writes samples to an output file for analysis in MATLAB.
-- The samples can be plotted using the stairs() MATLAB plot,
-- and the signal will look like a Modelsim analog format plot.
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Text library
library std;
use std.textio.all;

-- Control components
library control;
use control.components.all;
use control.utilities_pkg.all;
use control.lfsr_pkg.all;

-- Control test components
library control_test;
use control_test.log_pkg.all;

-------------------------------------------------------------------

entity noise_tb is
    generic (
		-- Automated makefile checking (eg. make vsim-check)
		MAKECHECK : integer := 0;

		-- Noise source parameters
		--
    	-- LFSR configuration
		LFSR_WIDTH  : integer := 31;
		POLYNOMIAL  : std_logic_vector := lfsr_polynomial(31);

        -- Noise source type
--		NOISE_TYPE  : string := "UNIFORM";  -- or "GAUSSIAN"
		NOISE_TYPE  : string := "GAUSSIAN";  -- or "UNIFORM"

        -- Noise samples sum
        NOISE_SUM   : integer := 4;

		-- Output noise data width
        NOISE_WIDTH : integer := 16;

		-- Output data file name
		OUTPUT_FILE_NAME   : string :=
			"test/noise_tb.txt";

        -- Number of samples to write to file
        NSAMPLES : integer := 100*1024

    );
end entity;

-------------------------------------------------------------------

architecture test of noise_tb is

    -- ------------------------------------------------------------
    -- Constants
    -- ------------------------------------------------------------
    --
    -- 100MHz 'fast' clock
    constant tCLK : time := 10 ns;

    -- Clock-to-output delay
    constant tCO : time := 1 ns;

    -- ------------------------------------------------------------
    -- Signals
    -- ------------------------------------------------------------
    --
    signal clk    : std_logic;
    signal rstN   : std_logic;
	signal load   : std_logic;
	signal seed   : std_logic_vector(LFSR_WIDTH-1 downto 0);
	signal enable : std_logic;
	signal q      : signed(NOISE_WIDTH-1 downto 0);

    -- Test number indicator
    signal test_number : integer;

begin

    -- ------------------------------------------------------------
    -- Device under test
    -- ------------------------------------------------------------
    --
	u1:	noise
		generic map (
			LFSR_WIDTH  => LFSR_WIDTH,
			POLYNOMIAL  => POLYNOMIAL,
			NOISE_TYPE  => NOISE_TYPE,
			NOISE_SUM   => NOISE_SUM,
			NOISE_WIDTH => NOISE_WIDTH
		)
		port map (
			clk    => clk,
			rstN   => rstN,
			load   => load,
			seed   => seed,
			enable => enable,
			q      => q
		);

	-- ------------------------------------------------------------
	-- Output file generator
	-- ------------------------------------------------------------
	--
	-- Write an output file when the noise source is enabled.
	-- MATLAB can then be used to look at the statistics of
	-- the noise sequence.
	--
	process(clk)
		file output_file : text;
    	variable output_file_status : file_open_status;
		variable output_line : line;
		variable val : integer;
		variable file_is_open : boolean := false;
		variable count : integer := 0;
	begin
		if rising_edge(clk) then
			if ((enable = '1') and (count < NSAMPLES)) then

				-- Open the file
				if (not file_is_open) then
					log("Opening the output data file: " &
						OUTPUT_FILE_NAME);
					file_open(output_file_status, output_file,
						OUTPUT_FILE_NAME, WRITE_MODE);
					assert output_file_status = OPEN_OK
						report "Error: failed to open the FIR filter " &
							"output data file " & OUTPUT_FILE_NAME
						severity failure;
					file_is_open := true;
				end if;

				-- Test number
--				val := test_number;
--				write(output_line, val, justified=>right, field=>15);
--				write(output_line, string'("    "));

				-- Noise sample
				val := to_integer(q);
				write(output_line, val, justified=>right, field=>15);

				-- Write to the file
				writeline(output_file, output_line);

				count := count + 1;
			else
				-- Close the file
				if (file_is_open) then
					log("Closing the output data file: " &
						OUTPUT_FILE_NAME);
					file_close(output_file);
					file_is_open := false;
				end if;
			end if;
		end if;
	end process;

    -- ------------------------------------------------------------
    -- Clock generator
    -- ------------------------------------------------------------
    --
    process
    begin
        clk <= '1';
        wait for tCLK/2;
        clk <= '0';
        wait for tCLK/2;
    end process;

    -- ------------------------------------------------------------
    -- Stimulus
    -- ------------------------------------------------------------
    --
    process
		-- --------------------------------------------------------
		-- Variables
		-- --------------------------------------------------------
		--
		-- LFSR sequence length check
		variable prbs_length : integer;
		variable width : integer;

		-- Exit-status file
        file exitfile     : text; -- string file
    begin
        -- --------------------------------------------------------
        -- Exit-status file creation
        -- --------------------------------------------------------
        --
		exitfile_open(exitfile, MAKECHECK);

        -- --------------------------------------------------------
        -- Simulation message
        -- --------------------------------------------------------
        --
		log_title("Digital noise source testbench");

        -- --------------------------------------------------------
        -- PRBS length check
        -- --------------------------------------------------------
        --
        -- If the PRBS sequence is not long enough, then the
        -- power spectra statistics will not be correct.
        --
		log_subtitle("PRBS length check");

		-- Number of bits required to create the uniform noise
        prbs_length := NOISE_WIDTH*NSAMPLES;
		if (NOISE_TYPE = "GAUSSIAN") then
			-- Increase due to the Gaussian sum approximation
	        prbs_length := prbs_length*NOISE_SUM;
	    end if;

		log("Required PRBS sequence length " &
			integer'image(prbs_length)  & "-bits");
		width := integer(ceil(log2(real(prbs_length))));
		log("Required LFSR width " &
			integer'image(width) & "-bits"
		);
		log("Current LFSR width " &
			integer'image(LFSR_WIDTH) & "-bits"
		);
		assert LFSR_WIDTH >= width
			report "Error: the PRBS sequence is not long enough." &
			" Increase the LFSR width (and change the polynomial)."
			severity failure;

        -- --------------------------------------------------------
        -- Defaults
        -- --------------------------------------------------------
        --
        test_number <= 0;
        enable <= '0';
        load   <= '0';
        seed   <= to_slv(16#55555555#, LFSR_WIDTH);
        rstN   <= '0';

        -- --------------------------------------------------------
        -- Reset
        -- --------------------------------------------------------
        --
        wait for 4*tCLK;

        -- Wait for a clock edge
        wait until rising_edge(clk);
        rstN <= '1' after tCO;
        wait for 4*tCLK;

        -- --------------------------------------------------------
        -- Enable with the default initial seed
        -- --------------------------------------------------------
        --
		test_number <= test_number + 1;
		log_subtitle("Enable the noise source");
		log("Noise source type: " & NOISE_TYPE);

		if (MAKECHECK = 0) then
			log("Enabling for " & integer'image(NSAMPLES) & " clocks");
		else
			log("Enabling for 1024 clocks");
		end if;

        wait until rising_edge(clk);
        enable <= '1' after tCO;

		-- Enable the noise source for the requested number
		-- of samples
		if (MAKECHECK = 0) then
			for i in 0 to NSAMPLES-1 loop
				wait until rising_edge(clk);
			end loop;
		else
			-- The automated makefile does not look at the
			-- samples, so just generate a small data file
			for i in 0 to 1023 loop
				wait until rising_edge(clk);
			end loop;
		end if;

		log("Disable");
        wait until rising_edge(clk);
        enable <= '0' after tCO;

        wait for 10*tCLK;

        -- --------------------------------------------------------
        -- User-defined initial seed
        -- --------------------------------------------------------
        --
		test_number <= test_number + 1;
		log_subtitle("Enable the noise source with a " &
			"different initial seed");

		log("Load");
        wait until rising_edge(clk);
        load <= '1' after tCO;
        wait until rising_edge(clk);
        load <= '0' after tCO;

		log("Enable");
        wait until rising_edge(clk);
        enable <= '1' after tCO;

		-- Allow the noise to run for a few hundred clocks
        for i in 0 to 200 loop
	        wait until rising_edge(clk);
		end loop;

		log("Disable");
        wait until rising_edge(clk);
        enable <= '0' after tCO;

        wait for 10*tCLK;

        -- --------------------------------------------------------
        -- Simulation complete
        -- --------------------------------------------------------
        --
		log_title("Simulation complete");
		exitfile_close(exitfile, MAKECHECK);

        -- --------------------------------------------------------
        -- Simulation complete
        -- --------------------------------------------------------
        --
        assert false
            report "All done!"
            severity failure;

    end process;
end architecture;
