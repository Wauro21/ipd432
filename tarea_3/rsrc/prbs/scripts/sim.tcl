# -----------------------------------------------------------------
# sim.tcl
#
# 4/20/2011 D. W. Hawkins (dwh@ovro.caltech.edu)
#
# ModelSim simulation script
#
# This script can be used to define simulation procedures for the
# testbenches. The procedures can only be called after the files
# have been built into the control and control_test libraries.
#
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Paths
# -----------------------------------------------------------------
#

# Paths relative to the prbs/ folder
set top     [pwd]
set src     $top/src
set test    $top/test
set scripts $top/scripts

# Modelsim work
set mwork $top/mwork

# -----------------------------------------------------------------
# Build the source
# -----------------------------------------------------------------
#
# My normal build system creates two libraries;
#  * control      = synthesis and simulation source
#  * control_test = simulation only
#
# Since the LFSR/PRBS code has been extracted from my build
# system, just map control and control_test onto the work
# directory.
#

if {![file exists $mwork]} {
	echo "Creating the Modelsim word directory: $mwork"
	vlib $mwork
	vmap work $mwork
	vmap control $mwork
	vmap control_test $mwork
}


# Empty files list
set files ""
	
# Start with the package files
lappend files $src/utilities_pkg.vhd
lappend files $src/lfsr_pkg.vhd
lappend files $src/components.vhd

# LFSR/PRBS
lappend files $src/lfsr.vhd
lappend files $src/prbs.vhd
lappend files $src/noise.vhd

# Adder tree
lappend files $src/adder_tree.vhd

# Convergent rounding
lappend files $src/convergent.vhd

# Tests
lappend files $test/log_pkg.vhd
lappend files $test/lfsr_tb.vhd
lappend files $test/prbs_tb.vhd
lappend files $test/prbs_spreader_tb.vhd
lappend files $test/noise_tb.vhd

# Compile the files
foreach file $files {
	vcom -2008 $file
}

# -----------------------------------------------------------------
# Testbench procedures
# -----------------------------------------------------------------

echo ""
echo "LFSR/PRBS testbench procedures"
echo "------------------------------"
echo ""
echo "  lfsr_tb           - run the LFSR testbench"
echo "  prbs_tb           - run the PRBS testbench"
echo "  prbs_spreader_tb  - run the PRBS spreader/despreader testbench"
echo "  noise_tb          - run the digital noise source testbench"
echo ""

proc lfsr_tb {} {
	global scripts
	set start [clock seconds]
	vsim control_test.lfsr_tb
	do $scripts/lfsr_tb.do
	run -a
	set end [clock seconds]
	echo "######################################################"
	echo "Elapsed time: [format %.2f [expr {($end-$start)/60.0}]] minutes"
	echo "######################################################"
}

proc prbs_tb {} {
	global scripts
	set start [clock seconds]
	vsim control_test.prbs_tb
	do $scripts/prbs_tb.do
	run -a
	set end [clock seconds]
	echo "######################################################"
	echo "Elapsed time: [format %.2f [expr {($end-$start)/60.0}]] minutes"
	echo "######################################################"
}

proc prbs_spreader_tb {} {
	global scripts
	set start [clock seconds]
	vsim control_test.prbs_spreader_tb
	do $scripts/prbs_spreader_tb.do
	run -a
	set end [clock seconds]
	echo "######################################################"
	echo "Elapsed time: [format %.2f [expr {($end-$start)/60.0}]] minutes"
	echo "######################################################"
}

proc noise_tb {} {
	global scripts
	set start [clock seconds]
	vsim -novopt control_test.noise_tb
	do $scripts/noise_tb.do
	run -a
	set end [clock seconds]
	echo "######################################################"
	echo "Elapsed time: [format %.2f [expr {($end-$start)/60.0}]] minutes"
	echo "######################################################"
}

