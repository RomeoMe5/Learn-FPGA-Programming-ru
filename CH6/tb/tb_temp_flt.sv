`timescale 1ns/10ps
module tb_temp_flt;

  parameter  INTERVAL     = 10000;
  parameter  NUM_SEGMENTS = 8;
  parameter  CLK_PER      = 20;

  logic clk;

  // Temperature Sensor Interface
  tri1 TMP_SCL;
  tri1 TMP_SDA;
  tri1 TMP_INT;
  tri1 TMP_CT;

  // 7 segment display
  logic [NUM_SEGMENTS-1:0] anode;
  logic [7:0]              cathode;
  logic                    sda_en;

  initial clk = '0;
  always begin
    clk = #(CLK_PER/2) ~clk;
  end

  i2c_temp_flt
    #
    (
     .INTERVAL     (INTERVAL),
     .NUM_SEGMENTS (NUM_SEGMENTS),
     .CLK_PER      (CLK_PER)
     )
  u_i2c_temp
    (
     .clk          (clk), // 100Mhz clock

     // Temperature Sensor Interface
     .TMP_SCL      (TMP_SCL),
     .TMP_SDA      (TMP_SDA),
     .TMP_INT      (TMP_INT),
     .TMP_CT       (TMP_CT),

     .SW           (1'b1),

     // 7 segment display
     .anode        (anode),
     .cathode      (cathode)
     );

  always @(posedge clk) begin
    sda_en <= '0;
    case (u_i2c_temp.bit_count)
      5'h0a, 5'h0b, 5'h0c, 5'h0d: sda_en <= '1;
      5'h10, 5'h11: sda_en               <= '1;
      5'h14, 5'h15, 5'h16, 5'h17: sda_en <= '1;
      5'h18, 5'h19, 5'h1a: sda_en        <= '1;
    endcase // case (u_i2c_temp.bit_count)
  end

  assign TMP_SDA = sda_en ? '0 : 'z;

endmodule
