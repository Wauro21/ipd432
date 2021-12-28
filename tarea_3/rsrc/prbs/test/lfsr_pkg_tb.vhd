-------------------------------------------------------------------
-- lfsr_pkg_tb.vhd
--
-- 4/20/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Linear Feedback Shift-Register (LFSR) and Pseudo-Random Binary
-- Sequence (PRBS) package testbench.
--
-- This testbench tests the polynomial parsing functions in the
-- LFSR package.
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
use control.lfsr_pkg.all;

-- Control test components
library control_test;
use control_test.log_pkg.all;

-------------------------------------------------------------------

entity lfsr_pkg_tb is
    generic (
		-- Automated makefile checking (eg. make vsim-check)
		MAKECHECK : integer := 0
    );
end entity;

-------------------------------------------------------------------

architecture test of lfsr_pkg_tb is

begin

    -- ------------------------------------------------------------
    -- Stimulus
    -- ------------------------------------------------------------
    --
    process

		-- Exit-status file
        file exitfile     : text; -- string file

		-- Test polynomial values
		variable prbs7  : std_logic_vector( 7 downto 0);
		variable prbs8  : std_logic_vector( 8 downto 0);
		variable prbs15 : std_logic_vector(15 downto 0);
		variable prbs21 : std_logic_vector(21 downto 0);
		variable prbs60 : std_logic_vector(60 downto 0);

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
		log_title("PRBS package testbench");

        -- --------------------------------------------------------
        -- Binary string-to-polynomial
        -- --------------------------------------------------------
        --
		log_subtitle("Binary string-to-polynomial test");

		-- Taps [7,6]
		prbs7 := lfsr_binary_string_to_polynomial("1100_0001");
		log("PRBS7 polynomial X^7 + X^6 + 1 in binary form = " &
			to_hstring(prbs7));
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		-- Taps [8,6,5,4]
		prbs8 := lfsr_binary_string_to_polynomial("1_0111_0001");
		log("PRBS8 polynomial X^8 +X^6 + X^5 + X^4 + 1 in binary form = " &
			to_hstring(prbs8));
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		-- Taps [15,14]
		prbs15 := lfsr_binary_string_to_polynomial("1100_0000_0000_0001");
		log("PRBS15 polynomial X^15 + X^14 + 1 in binary form = " &
			to_hstring(prbs15));
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		-- Taps [21,19]
		prbs21 := lfsr_binary_string_to_polynomial("10_1000_0000_0000_0000_0001");
		log("PRBS21 polynomial X^21 + X^19 + 1 in binary form = " &
			to_hstring(prbs21));
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		-- Taps [60,59]
		prbs60 := lfsr_binary_string_to_polynomial("1_1000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001");
		log("PRBS60 polynomial X^60 + X^59 + 1 in binary form = " &
			to_hstring(prbs60));
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

        -- --------------------------------------------------------
        -- Hexadecimal string-to-polynomial
        -- --------------------------------------------------------
        --
		log_subtitle("Hexadecimal string-to-polynomial test");

		-- Taps [7,6]
		prbs7 := lfsr_hex_string_to_polynomial("C1",8);
		log("PRBS7 polynomial X^7 + X^6 + 1 in binary form = " &
			to_hstring(prbs7));
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		-- Taps [8,6,5,4]
		prbs8 := lfsr_hex_string_to_polynomial("171",9);
		log("PRBS8 polynomial X^8 +X^6 + X^5 + X^4 + 1 in binary form = " &
			to_hstring(prbs8));
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		-- Taps [15,14]
		prbs15 := lfsr_hex_string_to_polynomial("C001",16);
		log("PRBS15 polynomial X^15 + X^14 + 1 in binary form = " &
			to_hstring(prbs15));
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		-- Taps [21,19]
		prbs21 := lfsr_hex_string_to_polynomial("28_0001",22);
		log("PRBS21 polynomial X^21 + X^19 + 1 in binary form = " &
			to_hstring(prbs21));
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		-- Taps [60,59]
		prbs60 := lfsr_hex_string_to_polynomial("1800_0000_0000_0001",61);
		log("PRBS60 polynomial X^60 + X^59 + 1 in binary form = " &
			to_hstring(prbs60));
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

        -- --------------------------------------------------------
        -- Tap string-to-polynomial
        -- --------------------------------------------------------
        --
		log_subtitle("Tap string-to-polynomial test");

		-- Taps [7,6]
		-- ----------
		prbs7 := lfsr_tap_string_to_polynomial("T[7,6]",8);
		log("PRBS7 polynomial X^7 + X^6 + 1 in binary form = " &
			to_hstring(prbs7));
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		-- Test the format and order of the taps
		prbs7 := lfsr_tap_string_to_polynomial("T[6,7]",8);
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		prbs7 := lfsr_tap_string_to_polynomial("7,6",8);
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		prbs7 := lfsr_tap_string_to_polynomial("6,7",8);
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		-- Taps [8,6,5,4]
		-- --------------
		prbs8 := lfsr_tap_string_to_polynomial("[8,6,5,4]",9);
		log("PRBS8 polynomial X^8 +X^6 + X^5 + X^4 + 1 in binary form = " &
			to_hstring(prbs8));
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		prbs8 := lfsr_tap_string_to_polynomial("[4,5,6,8]",9);
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		prbs8 := lfsr_tap_string_to_polynomial("[6,8,4,5]",9);
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		-- Taps [15,14]
		-- ------------
		prbs15 := lfsr_tap_string_to_polynomial("[15,14]",16);
		log("PRBS15 polynomial X^15 + X^14 + 1 in binary form = " &
			to_hstring(prbs15));
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		prbs15 := lfsr_tap_string_to_polynomial("[14,15]",16);
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		prbs15 := lfsr_tap_string_to_polynomial("15,14",16);
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		prbs15 := lfsr_tap_string_to_polynomial("14,15",16);
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		-- Taps [21,19]
		prbs21 := lfsr_tap_string_to_polynomial("[21,19]",22);
		log("PRBS21 polynomial X^21 + X^19 + 1 in binary form = " &
			to_hstring(prbs21));
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		prbs21 := lfsr_tap_string_to_polynomial("[19,21]",22);
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		prbs21 := lfsr_tap_string_to_polynomial("21,19",22);
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		prbs21 := lfsr_tap_string_to_polynomial("19,21",22);
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		-- Taps [60,59]
		prbs60 := lfsr_tap_string_to_polynomial("[60,59]",61);
		log("PRBS60 polynomial X^60 + X^59 + 1 in binary form = " &
			to_hstring(prbs60));
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

		prbs60 := lfsr_tap_string_to_polynomial("[59,60]",61);
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

		prbs60 := lfsr_tap_string_to_polynomial("59,60",61);
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

		prbs60 := lfsr_tap_string_to_polynomial("60,59",61);
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

        -- --------------------------------------------------------
        -- Default polynomial
        -- --------------------------------------------------------
        --
		log_subtitle("Default polynomial test");

		-- Taps [7,6]
		-- ----------
		prbs7 := lfsr_polynomial(7);
		log("PRBS7 polynomial X^7 + X^6 + 1 in binary form = " &
			to_hstring(prbs7));
		assert prbs7 = X"C1"
			report "Error: PRBS7 polynomial mismatch!"
			severity failure;

		-- Taps [8,6,5,4]
		-- --------------
		prbs8 := lfsr_polynomial(8);
		log("PRBS8 polynomial X^8 +X^6 + X^5 + X^4 + 1 in binary form = " &
			to_hstring(prbs8));
		assert prbs8 = '1' & X"71"
			report "Error: PRBS8 polynomial mismatch!"
			severity failure;

		-- Taps [15,14]
		-- ------------
		prbs15 := lfsr_polynomial(15);
		log("PRBS15 polynomial X^15 + X^14 + 1 in binary form = " &
			to_hstring(prbs15));
		assert prbs15 = X"C001"
			report "Error: PRBS15 polynomial mismatch!"
			severity failure;

		-- Taps [21,19]
		prbs21 := lfsr_polynomial(21);
		log("PRBS21 polynomial X^21 + X^19 + 1 in binary form = " &
			to_hstring(prbs21));
		assert prbs21 = "10" & X"80001"
			report "Error: PRBS21 polynomial mismatch!"
			severity failure;

		-- Taps [60,59]
		prbs60 := lfsr_polynomial(60);
		log("PRBS60 polynomial X^60 + X^59 + 1 in binary form = " &
			to_hstring(prbs60));
		assert prbs60 = "1" & X"800000000000001"
			report "Error: PRBS60 polynomial mismatch!"
			severity failure;

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

		-- Suppress a Modelsim warning that there is no wait
		wait;
    end process;
end architecture;
