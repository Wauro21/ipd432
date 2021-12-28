Build Instructions
------------------

2/7/2012 D. W. Hawkins (dwh@ovro.caltech.edu)

1. Start Modelsim and change directory to the source folder,
   eg., cd c:/temp/prbs
   
2. Source the simulation script;

   vsim> source scripts/sim.tcl
   
   The script will output the list of testbenches
   
   # LFSR/PRBS testbench procedures 
   # ------------------------------ 
   #  
   #   lfsr_tb           - run the LFSR testbench 
   #   prbs_tb           - run the PRBS testbench 
   #   prbs_spreader_tb  - run the PRBS spreader/despreader testbench 
   #   noise_tb          - run the digital noise source testbench 
   #  
   
3. Run one of the testbench procedures.

Enjoy!
