# Dual-Port RAM Verification

This repository contains the RTL design and a basic testbench for a True Dual-Port RAM. 

**Credit:** The core RAM module implementation is provided by the [verilog-basics repository](https://github.com/s-bear/verilog-basics).

## Project Structure
* `ram_dp_generic.v`: The core RAM module featuring a parameterizable data width, memory depth, and address width. Port A is dedicated to writing, while Port B is utilized for reading.
* `tb_ram_dp_generic.v`: A simple testbench designed to execute fundamental write and read operations.

## Verification Scope
The testbench (`tb_ram_dp_generic.v`) verifies the following basic memory operations:
* Writing a 32-bit data word to a specific address via Port A.
* Reading the written data back from that same address via Port B.
* Accessing different addresses sequentially to ensure correct memory mapping.
* Demonstrating the read latency (the number of clock cycles required after applying a read address before the corresponding data is available on the output bus).

## Simulation Link
https://edaplayground.com/x/GcpS
## Waveform
https://edaplayground.com/w/x/AkC
