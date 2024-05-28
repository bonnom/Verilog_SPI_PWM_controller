# Verilog SPI PWM Controller

This project contains a simple PWM (Pulse Width Modulation) controller implemented in Verilog with an SPI (Serial Peripheral Interface) interface. The module is designed to control the PWM signal's frequency and duty cycle through SPI communication. Unlike most SPI interfaces, this one transmits data in a less-significant-bit (LSB) first manner.

## Features

- **SPI Interface**: Configurable clock divider and duty cycle through a 5-byte SPI transaction.
- **PWM Signal Generation**: Generates a PWM signal with a user-defined frequency and duty cycle.
- **Clock Divider**: A 32-bit clock divider for adjusting the frequency of the PWM signal.
- **Duty Cycle Control**: An 8-bit duty cycle value to control the PWM signal's high-time proportion.

## SPI Communication Protocol

The SPI interface expects a total of 5 bytes to be transmitted in a single session:

- **First 4 bytes**: A 32-bit unsigned integer to set the clock divider. This value determines the frequency of the PWM signal.
- **Last byte**: An 8-bit unsigned integer to set the duty cycle. This value determines the high-time proportion of the PWM signal.

## FPGA Implementation

The code is written for the Lilygo - T-FPGA board. This FPGA board features an ESP32-S3 microcontroller alongside a Gowin GW1NSR-LV4CQN48PC6/I5 FPGA. The project files for the Gowin FPGA are included in this repository.

### Example Usage
To set the PWM frequency to 1 Hz with duty cycle of 128:
* Divide the clock frequency by 512, for example clk=25MHz: 25MHz/512 = 48923
* Then send that number in 32-bits little endian
* Then send 8-bit 128 little endian

To set the clock divider to 1000 and the duty cycle to 128 (50%), send the following bytes over SPI:

1. **Clock Divider (1000)**: `0x1B 0xBF 0x00 0x00`
2. **Duty Cycle (128)**: `0x80`

### Directory Structure

- **src/**: Contains the Verilog source code.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
