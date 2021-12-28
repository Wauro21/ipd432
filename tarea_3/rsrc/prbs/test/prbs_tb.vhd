-------------------------------------------------------------------
-- prbs_tb.vhd
--
-- 4/20/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Pseudo-Random Binary Sequence (PRBS) generator testbench.
--
-- The testbench is constructed using a Linear feedback shift
-- register (LFSR) that operates at a clock rate PRBS_WIDTH
-- times faster than the parallel output PRBS. The 1-bit PRBS
-- output from the LFSR is packed into a PRBS_WIDTH word for
-- comparison against the PRBS parallel output.
--
-- The LFSR and PRBS VHDL implement the PRBS logic in two
-- very different ways, a successful comparison simulation
-- for the two designs should be a sufficient test.
--
-------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

entity prbs_tb is
    generic (
		-- Automated makefile checking (eg. make vsim-check)
		MAKECHECK : integer := 0;

		-- LFSR parameters
		--
		-- 16-bit LFSR test
--		LFSR_WIDTH : integer := 16;
--		POLYNOMIAL : std_logic_vector := to_slv(16#1100B#,17);

		-- PRBS7 7-bit LFSR test; taps [7,6], 1100_0001b
		LFSR_WIDTH : integer := 7;
		POLYNOMIAL : std_logic_vector := lfsr_tap_string_to_polynomial("[7,6]",8);

		-- PRBS7 mirror polynomial test; taps [7,1], 1000_0011b
--		LFSR_WIDTH : integer := 7;
--		POLYNOMIAL : std_logic_vector := lfsr_taps_to_polynomial("[7,1]",8)

		-- PRBS parallel output width
		PRBS_WIDTH : integer := 16

    );
end entity;

-------------------------------------------------------------------

architecture test of prbs_tb is

    -- ------------------------------------------------------------
    -- Constants
    -- ------------------------------------------------------------
    --
    -- 100MHz 'fast' clock
    constant tCLK : time := 10 ns;

    -- Clock-to-output delay
    constant tCO : time := 1 ns;

	-- LFSR settings
	--
	-- PRBS sequence length
	constant PRBS_LENGTH : integer := 2**LFSR_WIDTH-1;

	-- Topology; FIBONACCI or GALOIS
	constant TOPOLOGY   : string  := "FIBONACCI";

	-- XOR or XNOR gates
	constant INVERT     : boolean := false;

    -- ------------------------------------------------------------
    -- Signals
    -- ------------------------------------------------------------
    --
    signal clk_fast : std_logic;
    signal clk      : std_logic;
    signal rstN     : std_logic;

    -- PRBS signals
    signal prbs_load   : std_logic;
    signal prbs_lfsr   : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal prbs_enable : std_logic;
    signal prbs_q      : std_logic_vector(PRBS_WIDTH-1 downto 0);

    -- LFSR signals
    signal lfsr_load   : std_logic;
    signal lfsr_enable : std_logic;
    signal lfsr_q      : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal lfsr_shift  : std_logic_vector(PRBS_WIDTH-1 downto 0);
    signal lfsr_prbs   : std_logic_vector(PRBS_WIDTH-1 downto 0);

	-- Common seed
    signal seed        : std_logic_vector(LFSR_WIDTH-1 downto 0);

begin

    -- ------------------------------------------------------------
    -- Device under test
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
        load   => prbs_load,
        seed   => seed,
        enable => prbs_enable,
        lfsr_q => prbs_lfsr,
        prbs_q => prbs_q
    );

    -- ------------------------------------------------------------
    -- LFSR
    -- ------------------------------------------------------------
    --
    u2: lfsr
        generic map (
            WIDTH      => LFSR_WIDTH,
            POLYNOMIAL => POLYNOMIAL,
			TOPOLOGY   => TOPOLOGY,
			INVERT     => INVERT
        )
        port map (
            clk    => clk_fast,
            rstN   => rstN,
            load   => lfsr_load,
            seed   => seed,
            enable => lfsr_enable,
            data   => lfsr_q
        );

	-- Serial-to-parallel converter
	process(clk_fast, rstN)
		variable i : integer := 0;
	begin
		if (rstN = '0') then
			lfsr_shift <= (others => '0');
			lfsr_prbs  <= (others => '0');
		elsif rising_edge(clk_fast) then
			if (lfsr_enable = '1') then
				-- Right-shift the PRBS data
				lfsr_shift <=
					lfsr_q(0) &
					lfsr_shift(PRBS_WIDTH-1 downto 1);
				if ((i mod PRBS_WIDTH) = 0) then
					lfsr_prbs <= lfsr_shift;
				end if;
				i := i + 1;
			else
				i := 0;
			end if;
		end if;
	end process;

    -- ------------------------------------------------------------
    -- Clock generators
    -- ------------------------------------------------------------
    --
    process
    begin
        clk_fast <= '1';
        wait for tCLK/2;
        clk_fast <= '0';
        wait for tCLK/2;
    end process;

    process
    begin
        clk <= '1';
        wait for PRBS_WIDTH*tCLK/2;
        clk <= '0';
        wait for PRBS_WIDTH*tCLK/2;
    end process;

    -- ------------------------------------------------------------
    -- Stimulus
    -- ------------------------------------------------------------
    --
    process

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
		log_title("PRBS testbench");

        -- --------------------------------------------------------
        -- Defaults
        -- --------------------------------------------------------
        --
        prbs_enable <= '0';
        prbs_load   <= '0';
        lfsr_enable <= '0';
        lfsr_load   <= '0';
        seed        <= to_slv(16#55555555#, LFSR_WIDTH);
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
		log_subtitle("Enable the LFSR and PRBS");

		-- Start the LFSR one fast clock and one slow period
		-- before the PRBS so the parallel patterns line up
        wait until rising_edge(clk);
		for i in 0 to PRBS_WIDTH-2 loop
	        wait until rising_edge(clk_fast);
		end loop;
        lfsr_enable <= '1' after tCO;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        prbs_enable <= '1' after tCO;

		-- Check the two sequences for two periods
        log("Checking the PRBS sequence (two complete periods)");
        for i in 0 to 2*PRBS_LENGTH-1 loop
	        wait until rising_edge(clk);
			assert prbs_q = lfsr_prbs
				report "Error: PRBS bit mismatch at index " &
					integer'image(i)
				severity failure;
		end loop;
        lfsr_enable <= '0' after tCO;
        prbs_enable <= '0' after tCO;
        log("Checks passed ok");

        wait for 10*PRBS_WIDTH*tCLK;

        -- --------------------------------------------------------
        -- User-defined initial seed
        -- --------------------------------------------------------
        --
		log_subtitle("Enable the LFSR with an initial seed");

        wait until rising_edge(clk);
        lfsr_load <= '1' after tCO;
        prbs_load <= '1' after tCO;
        wait until rising_edge(clk_fast);
        lfsr_load <= '0' after tCO;
        wait until rising_edge(clk);
        prbs_load <= '0' after tCO;

		-- Start the LFSR one fast clock and one slow period
		-- before the PRBS so the parallel patterns line up
        wait until rising_edge(clk);
		for i in 0 to PRBS_WIDTH-2 loop
	        wait until rising_edge(clk_fast);
		end loop;
        lfsr_enable <= '1' after tCO;
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        prbs_enable <= '1' after tCO;

		-- Check the two sequences for two periods
        log("Checking the PRBS sequence (two complete periods)");
        for i in 0 to 2*PRBS_LENGTH-1 loop
	        wait until rising_edge(clk);
			assert prbs_q = lfsr_prbs
				report "Error: PRBS bit mismatch at index " &
					integer'image(i)
				severity failure;
		end loop;
        lfsr_enable <= '0' after tCO;
        prbs_enable <= '0' after tCO;
        log("Checks passed ok");

        wait for 10*PRBS_WIDTH*tCLK;

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
