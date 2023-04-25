# Component fifo_async

## Project Purpose

Design an asynchronous FIFO

## Test Bensch

### Directory structure
* sim_0 - catalog for modeling
* tb - simulation components
* src - FIFO components

### Command files

Modeling is done in the Vivado system. 
It's supposed to use a Linux system and a terminal in which the environment variables have already been configured to access Vivado

Command files:
* all.sh - running all tests and displaying the result
* complile.sh - source compilation
* elaborate.sh - test assembly
* g_run_0.sh - run test 0 in GUI mode
* g_run_1.sh - run test 1 in GUI mode
* g_run_2.sh - run test 2 in GUI mode
* g_run_3.sh - run test 3 in GUI mode
* c_run_0.sh - run test 0 in console mode
* c_run_1.sh - run test 1 in console mode
* c_run_2.sh - run test 2 in console mode
* c_run_3.sh - run test 3 in console mode

### Test descriptions

* Test 0 - performs multiple read and write accesses from the FIFO. Includes filling the entire FIFO volume
* Test 1 - performs accesses with random delays, write speed exceeds read speed
* Test 2 - performs accesses with random delays, write speed is less than read speed
* Test 3 - performs accesses with random delays

### Group run result

As a result of the execution of the all.sh script, the global.txt file is generated

An example of a global.txt file on successful completion of the test
````
test_id=    0 test_name:               direct_base         TEST_PASSED
test_id=    1 test_name:       high_write_low_read         TEST_PASSED
test_id=    2 test_name:       low_write_high_read         TEST_PASSED
test_id=    3 test_name:                 randomize         TEST_PASSED
````

## Project Features

* To open the data file dump.vcd use https://gtkwave.sourceforge.net/
* The addresses are reclocked to another frequency using 2 triggers. This is required to avoid the effect of metastability.
* Gray counters are used to generate read and write addresses
* The use of Gray counters is determined by the requirement to achieve the lowest delay
* The addresses w_addr_next and w_addr are used. The w_addr_next address is needed to generate the full FIFO flag. 
* The maximum number of words in a FIFO is 2^DEPTH_LOG2-1
* Zero latency memory is used. This assumes the use of distributed memory in the Xilinx FPGA (based on LUTs)
* Link to local project repository https://github.com/NicolasFrankel/AsyncFifo

## Synthesys

The synthesis of the component was carried out, the main parameters. For example, selected Xilix Ultrascale+ xcku3p-ffvb676-2-e
* FIFO width - 16 bits
* Number of words - 64
* Write Clock 200 MHz
* read  Clock 250 MHz

The clocks are set in the file fifo_async_ooc.xdc

The clock domains are crossed between the w_addr, w_addr_r1 and r_addr, r_addr_w1 signals. When using a Gray counter, it is fundamentally important that the signal propagation delay be less than the smallest clock period. This limits were added to the current xdc file.   
  

## Opportunities for improvement  

* Pass the clock period w_clk, r_rclk together with the test_id parameter;
* Introduce obvious control of flags r_empty, w_full (currently they are controlled indirectly);
* To use block memory, we need to use memory output reclocking. This requires additional logic to implement the output buffer. The delay will be increased, the complexity of the FIFO component will increase, but a higher frequency of operation of the FIFO component can be achieved.


