# Verilog SPI PWM controller

This project contains a simple PWM counter in verilog with a SPI interface.
It doesn't contain any advanced features.
The SPI is LSB, unlike most SPI interfaces.

The SPI interface expects 5 bytes in a single pass:\
* First four bytes: 32-bit unsigned int to set the clock divider
* Last byte: 8-bit unsigned int to set the clock divider

## FPGA
The code is written for the Lilygo - T-FPGA. This is an FPGA board that contains an esp32s3 together with an gowin GW1NSR-LV4CQN48PC6/I5.
The gowin project file is included in this github repository.
