/*
This is a very simple PWM counter module that is set with an SPI interface.
Unlike most SPI connections, this one is less-significant-bit (LSB) first!!
The clock divider part is 32 bits and the duty cycle is 8 bits.
To get the actual clock frequency of the pwm signal, 
  take into account that the 8bits of the duty_should be added as well

Serial transmission:
    First 4 bytes : Sets the clock divider
    Last byte     : Set the pwm duty cycle
*/

module spi_pwm #(
  parameter integer DEFAULT_CLOCK_DIV = 17,  // Default clock divider for PWM frequency
  parameter integer DUTY_CYCLE_WIDTH = 8,
  parameter integer CLOCK_DIV_WIDTH = 32     // Width of the clock divider data
)(
  // SPI Interface
  input logic spi_sclk,   // SPI Clock
  input logic spi_mosi,   // SPI Master Out Slave In
  output logic spi_miso,  // SPI Master In Slave Out
  input logic spi_cs,     // SPI Chip Select

  input logic clk,        // System Clock
  input logic rst,        // Reset signal
  output logic pwm_out    // PWM Output
);

  // SPI State variables
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    RECEIVING = 2'b01,
    ERROR = 2'b10
  } spi_state_t;

  spi_state_t spi_state;
  logic [DUTY_CYCLE_WIDTH - 1:0] duty_cycle;
  logic [CLOCK_DIV_WIDTH - 1:0] pwm_clock_div;
  logic [CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH - 1:0] shift_register;
  logic [$clog2(CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH) + 1:0] shift_count;

  // Clock Divider
  logic [CLOCK_DIV_WIDTH - 1:0] div_counter;
  logic divided_clk;

  // PWM Counter
  logic [DUTY_CYCLE_WIDTH - 1:0] pwm_counter;

  // Loopback
  logic loopback_data;

  // Assign initial values
  assign spi_miso = loopback_data; // Set MISO to loopback data during write

  // SPI State Machine
  always @(posedge spi_sclk or negedge rst) begin
    if (!rst) begin
      // Reset all signals to their initial values
      spi_state <= IDLE;
      shift_register <= 'b0;
      shift_count <= 0;
    end else begin
      case (spi_state)

        IDLE: begin
          if (spi_cs == 0) begin
            shift_register <= {spi_mosi, shift_register[CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1:1]};
            shift_count <= 1;
            spi_state <= RECEIVING;
          end
        end

        RECEIVING: begin
          if (spi_cs == 0) begin
            if(shift_count < (CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1)) begin
              shift_count <= shift_count + 1;
              shift_register <= {spi_mosi, shift_register[CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1:1]};
            end
            else if (shift_count == (CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1)) begin
              shift_register <= {spi_mosi, shift_register[CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1:1]};
              spi_state <= IDLE; // Back to idle
              shift_count <= 0;
            end 
          end
          else begin
            spi_state <= IDLE;
            shift_count <= 0;
          end
        end

        default: begin
          spi_state <= IDLE;
          shift_count <= 0;
        end
      endcase
    end
  end
   // When the SPI stops sending, it writes the values for clock divider and duty cycle
   always @(posedge spi_cs) 
   begin
        pwm_clock_div <=  shift_register[CLOCK_DIV_WIDTH-1:0];
        duty_cycle <= shift_register[CLOCK_DIV_WIDTH + DUTY_CYCLE_WIDTH-1:CLOCK_DIV_WIDTH];
   end

  // Clock Divider Logic
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      div_counter <= 0;
      divided_clk <= 0;
    end else begin
      if (div_counter >= pwm_clock_div) begin
        divided_clk <= ~divided_clk;
        div_counter <= 0;
      end else begin
        div_counter <= div_counter + 1;
      end
    end
  end

  // PWM generation using the divided clock
  always @(posedge divided_clk or negedge rst) begin
    if (!rst) begin
      pwm_counter <= 0; // Reset counter
      pwm_out <= 0;     // Initialize PWM output
    end else begin
      if (pwm_counter < duty_cycle) begin
        pwm_out <= 1'b1;
      end else begin
        pwm_out <= 1'b0;
      end
      pwm_counter <= pwm_counter + 1;
      if (pwm_counter >= (1 << DUTY_CYCLE_WIDTH)) begin
        pwm_counter <= 0; // Reset counter at end of PWM cycle
      end
    end
  end

  // Loopback logic
  always @* begin
    loopback_data = spi_mosi; // Assign MOSI data to loopback data
  end

endmodule
