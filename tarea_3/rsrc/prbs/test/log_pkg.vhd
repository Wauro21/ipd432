-- log_pkg.vhd
--
-- 1/30/2009 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Testbench utilities:
--
--  * Logging functions (log to the Modelsim console)
--  * Exit file creation (for make vsim-check)
--
-- ----------------------------------------------------------------
-- Notes:
-- ------
--
-- 1. Console output justification.
--
--    The default font for the main window (helvetica 10pt) is
--    set in the Modelsim prefs.tcl file. Since the default font
--    is not monospaced, the justification of simulation output
--    text messages does not format correctly.
--
--    The font can be changed via the GUI:
--
--    Tools -> Edit Preferences, Main Window, Courier 12
--
--    with the change being saved in the user-specific .modelsim
--    file (an .ini format file). The entry in that file is:
--
--    PrefMain = font {Courier 12 roman normal}
--
--    Prior to changing the font, .modelsim does not have any
--    PrefMain entries.
--
--    The defaults can be customized via:
--
--     * Create the MODELSIM_TCL environment variable
--
--       export MODELSIM_TCL=$VHDL/modelsim.tcl
--
--     * Create the modelsim.tcl file with the line:
--
--       set PrefMain(font) {Courier 12 normal roman}
--
-- 2. Makefile automated checking; make vsim-check
--
--    Assertion statements are used for two purposes in
--    testbenches:
--
--     * to check for errors in the logic
--     * to terminate the simulation
--
--    Automated makefile checking needs a way to determine
--    whether the simulation terminated due to failure, or
--    success. Since there is no way to pass this information
--    to the calling program (make), a text file is used. The
--    file is created at the start of the simulation, and 0 is
--    written to the file at the end of the simulation. If the
--    simulation terminates and the file is empty, then an error
--    occurred, otherwise the simulation terminated successfully.
--
--    Modelsim supports environment variables in filenames, eg.
--
--    constant filename : string := "$VHDL_EXIT_STATUS_FILE";
--
--    and it can support the overriding of generics, so the
--    location of the exitfile could easily be changed. However,
--    it is currently hardcoded (below) to be the file named
--    "exitstatus".
--
--    The creation of the "exitstatus" file depends on the
--    generic makecheck. Every testbench should have the generic
--    and default it to zero. The Makefile sets it to 1.
--
--    Testbenches can also use makecheck to determine whether
--    they are being called from make; and increase or decrease
--    the number of tests to be performed.
--
-- ----------------------------------------------------------------
-- References
-- ----------
--
-- [1] "The designer's guide to VHDL", P. J. Ashenden, 1996.
--
-- ----------------------------------------------------------------
-- References:
-- -----------
--
-- [1] comp.lang.vhdl FAQ (http://www.eda.org/comp.lang.vhdl/)
--     Lots of good notes.
--
-- [2] Ashenden, P. J., "The designers guide to VHDL", 1996.
--
-- [3] Modelsim-Altera User's Manual, version 6.19, August 2006.
--     (oem_man.pdf)
--     * "Chapter 4 - VHDL Simulation"
--     * p71 Using the TextIO package
--     * p79 has comments on the modelsim util package
--       library modelsim_lib;
--       use modelsim_lib.util.all;
--       Tools include; get_resolution(), to_real(), to_time()
--     * p83 has a section on modelling memory

-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TextIO
use std.textio.all;

-- Synopsis library
--use ieee.std_logic_textio.all;

-- Modelsim library
--   The library needs to be explicitly compiled
--
--use work.io_utils.all;

-- ----------------------------------------------------------------

package log_pkg is

	-- ============================================================
	-- String conversion functions
	-- ============================================================
	--
	-- Create a hex string for an integer of width bits (1 to 32)
	function to_hstring (
		value : in integer;
		width : in integer) return string;

	-- Create a hex string for a std_logic_vector
	function to_hstring (
		value : in std_logic_vector) return string;

	-- Create a binary string for a std_logic_vector
	function to_bstring (
		value : in std_logic_vector) return string;

	-- ============================================================
	-- Logging
	-- ============================================================
	--
	-- ------------------------------------------------------------
	-- Title message
	-- ------------------------------------------------------------
	--
	-- Message delineated with '=====' above and below
	procedure log_title (
		msg : string);

	-- ------------------------------------------------------------
	-- Subtitle message
	-- ------------------------------------------------------------
	--
	-- Message delineated with '-----' above and below
	procedure log_subtitle (
		msg : string);

	-- ------------------------------------------------------------
	-- Message
	-- ------------------------------------------------------------
	--
	-- Message with a leading timestamp right-justified to 'width'
	procedure log (
		msg   : string;
		width : integer := 13);

	-- ============================================================
	-- Exit file generation
	-- ============================================================
	--
	-- make vsim-check uses an exitfile to determine whether a
	-- simulation terminated correctly. These two routines
	-- create that file and close it appropriately
	--
	-- ------------------------------------------------------------
	-- Exit file open
	-- ------------------------------------------------------------
	--
	procedure exitfile_open (
		file exitfile : text;
		makecheck     : integer);

	-- ------------------------------------------------------------
	-- Exit file close
	-- ------------------------------------------------------------
	--
	procedure exitfile_close (
		file exitfile : text;
		makecheck     : integer);

end package;

-- ----------------------------------------------------------------

package body log_pkg is

	-- ============================================================
	-- String conversion functions
	-- ============================================================
	--
	-- Create a hex string for an integer of width bits (1 to 32)
	function to_hstring (
		value : in integer;
		width : in integer) return string is
	begin
		if (value < 0) then
			return to_hstring(
				std_logic_vector(to_signed(value,width)));
		else
			return to_hstring(
				std_logic_vector(to_unsigned(value,width)));
		end if;
	end;

	-- Create a hex string for a std_logic_vector
	function to_hstring (
		value : in std_logic_vector) return string is
		variable nibble : std_logic_vector(0 to 3);
		constant nchars : integer := (value'length+3)/4;
		variable slv    : std_logic_vector(0 to 4*nchars-1);
		variable result : string(1 to nchars);
	begin
		assert (value'length > 0)
			report "Invalid std_logic_vector"
			severity failure;

		-- Convert the input slv into 4-bit nibbles
		slv := (others => '0');
		slv(4*nchars-value'length to 4*nchars-1) := value;

		-- Convert the nibbles to characters
		for i in 0 to nchars-1 loop
			nibble := to_X01Z(slv(4*i to 4*i+3));
			case nibble is
				when X"0"   => result(i+1) := '0';
				when X"1"   => result(i+1) := '1';
				when X"2"   => result(i+1) := '2';
				when X"3"   => result(i+1) := '3';
				when X"4"   => result(i+1) := '4';
				when X"5"   => result(i+1) := '5';
				when X"6"   => result(i+1) := '6';
				when X"7"   => result(i+1) := '7';
				when X"8"   => result(i+1) := '8';
				when X"9"   => result(i+1) := '9';
				when X"A"   => result(i+1) := 'A';
				when X"B"   => result(i+1) := 'B';
				when X"C"   => result(i+1) := 'C';
				when X"D"   => result(i+1) := 'D';
				when X"E"   => result(i+1) := 'E';
				when X"F"   => result(i+1) := 'F';
				when "ZZZZ" => result(i+1) := 'Z';
				when others => result(i+1) := 'X';
			end case;
		end loop;
		return result;
	end;

	-- Create a binary string for a std_logic_vector
	function to_bstring (
		value : in std_logic_vector) return string is
		constant nchars : integer := value'length;
		variable result : string(1 to nchars);
	begin
		for i in 0 to nchars-1 loop
			case value(i) is
				when '0' =>
					result(i+1) := '0';
				when '1' =>
					result(i+1) := '1';
				when others =>
					result(i+1) := 'X';
			end case;
		end loop;
		return result;
	end function;

	-- ============================================================
	-- Logging
	-- ============================================================
	--
	-- ------------------------------------------------------------
	-- Title message
	-- ------------------------------------------------------------
	--
	procedure log_title (
		msg : string) is
		variable l : line;
	begin
		write(l,string'(" "));
		writeline(output, l);
		-- The length of the separator is matched to the
		-- width of the transcript file when opened in gvim
		write(l,string'(
			"=======================================" &
			"======================================="));
		writeline(output, l);
		write(l, msg);
		writeline(output, l);
		write(l,string'(
			"=======================================" &
			"======================================="));
		writeline(output, l);
	end procedure;

	-- ------------------------------------------------------------
	-- Subtitle message
	-- ------------------------------------------------------------
	--
	procedure log_subtitle (
		msg : string) is
		variable l : line;
	begin
		write(l,string'(" "));
		writeline(output, l);
		write(l,string'(
			"---------------------------------------" &
			"---------------------------------------"));
		writeline(output, l);
		write(l, msg);
		writeline(output, l);
		write(l,string'(
			"---------------------------------------" &
			"---------------------------------------"));
		writeline(output, l);
	end procedure;

	-- ------------------------------------------------------------
	-- Message
	-- ------------------------------------------------------------
	procedure log (
		msg   : string;
		width : integer := 13) is
		variable l : line;
	begin
		-- Justified timestamp
		--
		-- "1 ms" -> "1000000 ns" has a width of 10
		-- "1 s"  -> "1000000000 ns" has a width of 13
		--
		write(l, now, justified=>right, field=>width, unit=>ns);
		write(l, string'(":  "));

		-- User message
		write(l, msg);
		writeline(output, l);
	end procedure;

	-- ============================================================
	-- Exit file generation
	-- ============================================================
	--
	-- ------------------------------------------------------------
	-- Exit file open
	-- ------------------------------------------------------------
	--
	procedure exitfile_open (
		file exitfile : text;
		makecheck     : integer) is
       	variable status   : file_open_status;
        constant filename : string  := "exitstatus";
	begin
		if (makecheck /= 0) then
        	file_open(status, exitfile, filename, WRITE_MODE);
        	assert status = OPEN_OK
        	    report "Exit file open failed!"
        	    severity failure;
		end if;
	end procedure;

	-- ------------------------------------------------------------
	-- Exit file close
	-- ------------------------------------------------------------
	--
	procedure exitfile_close (
		file exitfile : text;
		makecheck     : integer) is
		variable l : line;
	begin
		if (makecheck /= 0) then
        	-- Write to the exit file
        	write(l, string'("0"));
        	writeline(exitfile, l);
		end if;
	end procedure;

end package body;

