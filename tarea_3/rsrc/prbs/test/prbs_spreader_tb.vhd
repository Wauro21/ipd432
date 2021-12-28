-------------------------------------------------------------------
-- prbs_spreader_tb.vhd
--
-- 4/20/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Pseudo-Random Binary Sequence (PRBS) 'spreader' testbench.
--
-- PRBS sequences are used to randomize data sequences. This
-- testbench contains two PRBS generators; a source and destination
-- PRBS. During initialization, the source PRBS is used to load
-- the destination PRBS, and then data spreading is enabled.
-- The received data is de-spread and checked for consistency.
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

entity prbs_spreader_tb is
    generic (
		-- Automated makefile checking (eg. make vsim-check)
		MAKECHECK : integer := 0
    );
end entity;

-------------------------------------------------------------------

architecture test of prbs_spreader_tb is

    -- ------------------------------------------------------------
    -- Constants
    -- ------------------------------------------------------------
    --
    -- 50MHz clock
    constant tCLK : time := 20 ns;

    -- Clock-to-output delay
    constant tCO : time := 1 ns;

	-- PRBS settings
	--
	-- PRBS7
	constant LFSR_WIDTH : integer := 7;
	constant POLYNOMIAL : std_logic_vector :=
		lfsr_tap_string_to_polynomial("[7,6]",8);

	-- PRBS parallel output width
	constant PRBS_WIDTH : integer := 16;

	-- PRBS sequence length
	constant PRBS_LENGTH : integer := 2**LFSR_WIDTH-1;

    -- ------------------------------------------------------------
    -- Signals
    -- ------------------------------------------------------------
    --
    signal clk      : std_logic;
    signal rstN     : std_logic;

    -- Source PRBS
    signal src_load   : std_logic;
    signal src_seed   : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal src_lfsr   : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal src_enable : std_logic;
    signal src_prbs   : std_logic_vector(PRBS_WIDTH-1 downto 0);

    -- Destination PRBS
    signal dst_load   : std_logic;
    signal dst_seed   : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal dst_lfsr   : std_logic_vector(LFSR_WIDTH-1 downto 0);
    signal dst_enable : std_logic;
    signal dst_prbs   : std_logic_vector(PRBS_WIDTH-1 downto 0);

	-- Despread pattern
    signal data_in      : std_logic_vector(PRBS_WIDTH-1 downto 0);
    signal data_spread  : std_logic_vector(PRBS_WIDTH-1 downto 0);
    signal data_out     : std_logic_vector(PRBS_WIDTH-1 downto 0);
    signal data_delay   : std_logic_vector(PRBS_WIDTH-1 downto 0);

	-- Data generator
	signal data_count   : unsigned(PRBS_WIDTH-1 downto 0);
	signal data_enable  : std_logic;

begin

    -- ------------------------------------------------------------
    -- Devices under test
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
        load   => src_load,
        seed   => src_seed,
        enable => src_enable,
        lfsr_q => src_lfsr,
        prbs_q => src_prbs
    );

	u2: prbs
    generic map (
        LFSR_WIDTH => LFSR_WIDTH,
        POLYNOMIAL => POLYNOMIAL,
        PRBS_WIDTH => PRBS_WIDTH
    )
    port map (
        clk    => clk,
        rstN   => rstN,
        load   => dst_load,
        seed   => dst_seed,
        enable => dst_enable,
        lfsr_q => dst_lfsr,
        prbs_q => dst_prbs
    );

	-- Destination PRBS initialization
	--
	-- The data input to the spreader is initially set to
	-- zero, so that the source PRBS parallel output is sent
	-- directly to the destination. The destination uses
	-- that word to initialize its PRBS. The testbench
	-- checks for initialization, and then enables the
	-- data source.
	--
	dst_seed <= data_spread(LFSR_WIDTH-1 downto 0);

    -- ------------------------------------------------------------
    -- Data
    -- ------------------------------------------------------------
    --
	-- The input data
	process(clk,rstN)
	begin
		if (rstN = '0') then
			data_count <= (others => '0');
		elsif rising_edge(clk) then
			if (data_enable = '1') then
				data_count <= data_count + 1;
			else
				data_count <= (others => '0');
			end if;
		end if;
	end process;
	data_in <= std_logic_vector(data_count);

	-- The spread data
	process(clk, rstN)
	begin
		if (rstN = '0') then
			data_spread <= (others => '0');
		elsif rising_edge(clk) then
			data_spread <= src_prbs xor data_in;
		end if;
	end process;

	-- The de-spread data
	process(clk, rstN)
	begin
		if (rstN = '0') then
			data_delay <= (others => '0');
			data_out   <= (others => '0');
		elsif rising_edge(clk) then
			-- Delay the data one clock to align it with the
			-- local PRBS output sequence
			data_delay <= data_spread;
			data_out   <= dst_prbs xor data_delay;
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
		log_title("PRBS 'spreader' testbench");

        -- --------------------------------------------------------
        -- Defaults
        -- --------------------------------------------------------
        --
        src_enable  <= '0';
        src_load    <= '0';
        src_seed    <= (others => '1');
        dst_enable  <= '0';
        dst_load    <= '0';
        data_enable <= '0';
        rstN        <= '0';

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
        -- Enable the two PRBSs
        -- --------------------------------------------------------
        --
		log_subtitle("Enable the source and destination PRBSs");

        log("Enable the source PRBS");
        wait until rising_edge(clk);
        src_enable <= '1' after tCO;
        wait until rising_edge(clk);
        wait until rising_edge(clk);

        log("Load and enable the destination PRBS");
        dst_load <= '1' after tCO;
        wait until rising_edge(clk);
        dst_load <= '0' after tCO;
        dst_enable <= '1' after tCO;
        wait until rising_edge(clk);

		-- Check the de-spread data is zero
        log("Checking the de-spread data sequence is zero");
        for i in 0 to 19 loop
	        wait until rising_edge(clk);
			assert data_out = to_slv(0,PRBS_WIDTH)
				report "Error: receive data is not zero!"
				severity failure;
		end loop;
        log("Checks passed ok");

        wait for 10*PRBS_WIDTH*tCLK;

        -- --------------------------------------------------------
        -- Enable the data
        -- --------------------------------------------------------
        --
		log_subtitle("Enable the data source");

        log("Enable the data source");
        wait until rising_edge(clk);
        data_enable <= '1' after tCO;
        wait until rising_edge(clk);

		-- Wait for the data to change
        log("Synchronize to the input data");
        while (data_out /= to_slv(1,PRBS_WIDTH)) loop
	        wait until rising_edge(clk);
		end loop;

        log("Check the input data");
        for i in 2 to 2*PRBS_LENGTH-1 loop
	        wait until rising_edge(clk);
			assert data_out = to_slv(i mod 2**PRBS_WIDTH,PRBS_WIDTH)
				report "Error: receive data is not as expected!"
				severity failure;
		end loop;
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
