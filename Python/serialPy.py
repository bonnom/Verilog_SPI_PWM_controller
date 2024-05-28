'''
This files contain the code to send bytes over serial to the ESP32-S3
'''

import serial
import struct
import time
import numpy as np

# Define the serial port (replace with your actual port name)
port = 'COM5'  # Windows
# port = '/dev/ttyUSB0'  # Linux/macOS

# Open the serial port with desired baud rate
try:
  ser = serial.Serial(port, baudrate=115200)
except serial.SerialException as e:
  print(f"Error opening serial port: {e}")

# Define the data to send (replace with your actual data)
# Example data to send: uint8 and float
clock_frequency=27*10**6

data = bytearray()
uint32_value_frequency = np.uint32(clock_frequency/511)
data.extend(struct.pack('<I', uint32_value_frequency))
uint8_duty_cycle = 5
data.append(uint8_duty_cycle)  # float value

time.sleep(2)
# Send the data
try:
  ser.write(data)
  print(f"Sent data: {data}")
except serial.SerialException as e:
  print(f"Error sending data: {e}")
  
# Read data from the serial port (optional, depending on your use case)

try:
  # Adjust the number of bytes to read based on your data format on the device
  received_data = ser.read(5)  # Read 10 bytes (adjust as needed)
  if received_data:
    print(f"Received data: {received_data}")
    # You can further process the received data here
    # For example, unpack a float value if the device sends one:
    if len(received_data) >= 5:  # Ensure at least 4 bytes for a float
      int32_received = struct.unpack('I', received_data[0:4])
      print(f"Received int value: {int32_received}")
      int_received = received_data[4]
      print(f"Received int value: {int_received}")
  else:
    print("No data received.")
except serial.SerialException as e:
  print(f"Error reading data: {e}")

# Close the serial port
time.sleep(5)
ser.close()
print("Serial port closed.")