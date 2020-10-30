# workingzone
Progetto di Reti Logiche 2019/20

### Overview
Implementation of a FSM machine in hardware using VHDL.

The described module is an implementation of a working-zone encoder.

### Architecture
- single process architecture (lambda and delta functions implemented in the same module)
- asynchronous reset
- optimization of number of states and clock cycles
- behavorial description (except for two output signals that are defined with dataflow assignments)

### Documents
- [specification](https://github.com/lucamora/workingzone/blob/master/docs/specification.pdf)
- [report](https://github.com/lucamora/workingzone/blob/master/docs/report.pdf)

### Tools
- [wz.js](https://github.com/lucamora/workingzone/blob/master/tools/wz.js): emulator of wz encoder behavior
- [gen.js](https://github.com/lucamora/workingzone/blob/master/tools/gen.js): generator of random test suite (used by [random.vhd](https://github.com/lucamora/workingzone/blob/master/test/random.vhd) testbench)