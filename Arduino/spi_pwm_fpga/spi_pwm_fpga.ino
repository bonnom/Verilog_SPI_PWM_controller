/*
For more info check out this Github
https://github.com/Xinyuan-LilyGO/T-FPGA
*/
#include "Arduino.h"
#include "SPI.h"
#include "Wire.h"
#include "XPowersLib.h" //https://github.com/lewisxhe/XPowersLib
#include "pins_config.h"

// #include "driver/spi_master.h"
XPowersAXP2101 PMU;

void led_task(void *param);
void fpga_spi_blink(uint8_t *data, size_t len);

void setup()
{
    pinMode(PIN_FPGA_CS, OUTPUT);
    digitalWrite(PIN_FPGA_CS, 1);
    Serial.begin(115200);
    Serial.println("starting");
    xTaskCreatePinnedToCore(led_task, "led_task", 1024, NULL, 1, NULL, 1);

    bool result = PMU.begin(Wire, AXP2101_SLAVE_ADDRESS, PIN_IIC_SDA, PIN_IIC_SCL);

    if (result == false) {
        Serial.println("PMU is not online...");
        while (1)
            delay(50);
    }

    PMU.setDC4Voltage(1200);   // Here is the FPGA core voltage. Careful review of the manual is required before modification.
    PMU.setALDO1Voltage(3300); // BANK0 area voltage
    PMU.setALDO2Voltage(3300); // BANK1 area voltage
    PMU.setALDO3Voltage(2500); // BANK2 area voltage
    PMU.setALDO4Voltage(1800); // BANK3 area voltage

    PMU.enableALDO1();
    PMU.enableALDO2();
    PMU.enableALDO3();
    PMU.enableALDO4();

    PMU.disableTSPinMeasure();
    PMU.setChargingLedMode(XPOWERS_CHG_LED_OFF);
    delay(1000);
    // Wire1.begin(PIN_FPGA_D0, PIN_FPGA_SCK);

    pinMode(PIN_BTN, INPUT);
    // SPI.begin(PIN_FPGA_SCK, PIN_FPGA_D1, PIN_FPGA_D0);
    SPI.begin(PIN_FPGA_SCK, PIN_FPGA_D0, PIN_FPGA_D1);
}

void loop()
{
    // Check if 4 bytes are available on the serial port
    const size_t length_data = 5;
    if (Serial.available() >= length_data) {
        uint8_t data[length_data];
        Serial.readBytes(data, length_data); // Read 4 bytes from the serial buffer
        fpga_spi_blink(data, length_data);
    }
    delay(10);
    
}

void led_task(void *param)
{
    pinMode(PIN_LED, OUTPUT);
    while (true) {
        digitalWrite(PIN_LED, 1);
        delay(20);
        digitalWrite(PIN_LED, 0);
        delay(random(300, 980));
    }
}

void fpga_spi_blink(uint8_t *data, size_t len) {
  uint8_t data_received[len]; // Allocate array to store received data

  digitalWrite(PIN_FPGA_CS, LOW); // Select FPGA by pulling CS low
  // Begin SPI transaction with specified settings
  SPI.beginTransaction(SPISettings(400000, LSBFIRST, SPI_MODE0));
  // Send data byte by byte and receive data into data_received array
  for (size_t i = 0; i < len; i++) {
    data_received[i] = SPI.transfer(data[i]); // Store received data in the array
  }
  // End SPI transaction
  
  SPI.endTransaction();
  digitalWrite(PIN_FPGA_CS, HIGH); // Deselect FPGA by pulling CS high

  // Write the entire data_received array to serial
  Serial.write(data_received, len); // Write array data and specify length
}