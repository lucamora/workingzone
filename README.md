# workingzone
Progetto di Reti Logiche 2019/20

### Overview
Implementation of a FSM machine in hardware using VHDL
The described module is an implementation of a working-zone encoder.

### Architecture
- single process architecture (lambda and delta functions implemented in the same module)
- asynchronous reset
- optimization of number of states and clock cycles
- behavorial description (except for two output signals that are defined with dataflow assignments)
