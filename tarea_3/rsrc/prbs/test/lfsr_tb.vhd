-------------------------------------------------------------------
-- lfsr_tb.vhd
--
-- 4/20/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Linear feedback shift register (LFSR) test bench.
--
-- See lfsr_pkg.vhd for a list of generator polynomials.
--
-- The testbench opens a binary file containing the PRBS output.
-- The PRBS file was generated using C-code or MATLAB.
-- The testbench compares the VHDL generated sequence against
-- the PRBS file contents to confirm they are equal.
--
-- The second test compares the PRBS sequence against that loaded
-- with an initial seed that is not all ones. The PRBS sequence
-- index associated with that index needs to be provided. The
-- simplest way to do this is to decide on the index, eg., 20,
-- and look at the LFSR state at that index; that is the value
-- of the seed to load.
--
-- The LFSR was tested for PRBS7 sequences (both mirror
-- polynomials) and for a 16-bit polynomial. A more exhaustive
-- test sequence could be scripted in Tcl.
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

entity lfsr_tb is
    generic (
		-- Automated makefile checking (eg. make vsim-check)
		MAKECHECK : integer := 0;

    	-- 16-bit LFSR test; taps [16,12,3,1]
--		WIDTH      : integer := 16;
--		POLYNOMIAL : std_logic_vector := to_slv(16#1100B#,17);
--		PRBS_FILE_NAME   : string :=
--			"$VHDL/lib/prbs/test/prbs16_FFFFh_fibonacci_xor_1100Bh.bin";
--		LFSR_SEED : integer := 16#0897#;
--		LFSR_INDEX : integer := 20

		-- PRBS7 7-bit LFSR test; taps [7,6], 1100_0001b
		WIDTH      : integer := 7;
		POLYNOMIAL : std_logic_vector := to_slv(16#C1#,8);
		PRBS_FILE_NAME   : string :=
			"test/prbs7_7Fh_fibonacci_xor_C1h.bin";
		LFSR_SEED : integer := 16#21#;
		LFSR_INDEX : integer := 20

		-- PRBS7 mirror polynomial test; tap [7,1], 1000_0011b
--		WIDTH      : integer := 7;
--		POLYNOMIAL : std_logic_vector := to_slv(16#83#,8);
--		PRBS_FILE_NAME   : string :=
--			"$VHDL/lib/prbs/test/prbs7_7Fh_fibonacci_xor_83h.bin";
--		LFSR_SEED : integer := 16#3B#;
--		LFSR_INDEX : integer := 20

    );
end entity;

-------------------------------------------------------------------

architecture test of lfsr_tb is

    -- ------------------------------------------------------------
    -- Constants
    -- ------------------------------------------------------------
    --
    -- 50MHz clock
    constant tCLK : time := 20 ns;

    -- Clock-to-output delay
    constant tCO : time := 1 ns;

	-- PRBS sequence length
	constant PRBS_LENGTH : integer := 2**WIDTH-1;

	-- Topology; FIBONACCI or GALOIS
	constant TOPOLOGY   : string  := "FIBONACCI";

	-- XOR or XNOR gates
	constant INVERT     : boolean := false;

    -- ------------------------------------------------------------
    -- Signals
    -- ------------------------------------------------------------
    --
    signal clk    : std_logic;
    signal rstN   : std_logic;
    signal load   : std_logic;
    signal seed   : std_logic_vector(WIDTH-1 downto 0);
    signal enable : std_logic;
    signal data   : std_logic_vector(WIDTH-1 downto 0);

	-- Pseudo-random binary sequence (LFSR output bit)
    signal prbs : std_logic;
begin

    -- ------------------------------------------------------------
    -- Device under test
    -- ------------------------------------------------------------
    --
    u1: lfsr
        generic map (
            WIDTH      => WIDTH,
            POLYNOMIAL => POLYNOMIAL,
			TOPOLOGY   => TOPOLOGY,
			INVERT     => INVERT
        )
        port map (
            clk    => clk,
            rstN   => rstN,
            load   => load,
            seed   => seed,
            enable => enable,
            data   => data
        );

	-- Use the shift-register output for the PRBS bit
	prbs <= data(0);

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

		-- File parameters
    	subtype byte_t is character;
    	type binary_file_t is file of byte_t;
    	file binary_file : binary_file_t;
    	variable status : file_open_status;
    	variable byte : byte_t;

		-- PRBS sequence
		-- * length 2**WIDTH-1
		-- * use 'downto' so that bytes can be serialized easily
		variable prbs_sequence : std_logic_vector(PRBS_LENGTH-1 downto 0);
		variable index : integer;

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
		log_title("LFSR testbench");

        -- --------------------------------------------------------
        -- Load the PRBS sequence from file
        -- --------------------------------------------------------
        --
		log_subtitle("Load the PRBS file");
        log("Read PRBS from file " & PRBS_FILE_NAME);

		-- Open the file
		file_open(status, binary_file, PRBS_FILE_NAME, READ_MODE);
		assert status = OPEN_OK
			report "File open for read failed!"
    		severity failure;

		-- Read the data
		index := 0;
    	while not  endfile(binary_file) loop
			-- Read a byte
			read(binary_file, byte);

			-- Serialize
			if (index + 8 < PRBS_LENGTH) then
				prbs_sequence(index+7 downto index)
					:= to_slv(character'pos(byte), 8);
				index := index + 8;
			else
				-- Convert the last bits
				prbs_sequence(PRBS_LENGTH-1 downto index)
					:= to_slv(character'pos(byte),
						PRBS_LENGTH-index);
				exit;
			end if;
		end loop;
		file_close(binary_file);
        log("PRBS initialization from file complete");

        -- --------------------------------------------------------
        -- Defaults
        -- --------------------------------------------------------
        --
        enable <= '0';
        load   <= '0';
        seed   <= (others => '0');
        rstN   <= '0';

        -- --------------------------------------------------------
        -- Reset
        -- --------------------------------------------------------
        --
        wait for 4*tCLK;

        -- Wait for a clock edge
        wait until rising_edge(clk);
        rstN <= '1' after tCO;

        -- --------------------------------------------------------
        -- Enable with the default initial seed
        -- --------------------------------------------------------
        --
		log_subtitle("Enable the LFSR");

        -- Check the pattern
        log("Checking the PRBS sequence (two complete periods)");
        wait until rising_edge(clk);
        enable <= '1' after tCO;
        for i in 0 to 2*PRBS_LENGTH-1 loop
	        wait until rising_edge(clk);
			assert prbs = prbs_sequence(i mod PRBS_LENGTH)
				report "Error: PRBS bit mismatch at index " &
					integer'image(i)
				severity failure;
		end loop;
        enable <= '0' after tCO;
        log("Checks passed ok");

        wait for 5*tCLK;

        -- --------------------------------------------------------
        -- User-defined initial seed
        -- --------------------------------------------------------
        --
		log_subtitle("Enable the LFSR with an initial seed");

        -- Load a different starting seed
        wait until rising_edge(clk);
        load <= '1' after tCO;
        seed <= to_slv(LFSR_SEED, WIDTH);
        wait until rising_edge(clk);
        load <= '0' after tCO;
        seed <= (others => '0');

        -- Check the pattern
        log("Checking the PRBS sequence (two complete periods)");
        wait until rising_edge(clk);
        enable <= '1' after tCO;
        for i in 0 to 2*PRBS_LENGTH-1 loop
	        wait until rising_edge(clk);
			assert prbs = prbs_sequence((i+LFSR_INDEX) mod PRBS_LENGTH)
				report "Error: PRBS bit mismatch at index " &
					integer'image(i)
				severity failure;
		end loop;
        enable <= '0' after tCO;
        log("Checks passed ok");

        wait for 5*tCLK;

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
