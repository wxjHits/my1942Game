
module apu_div
#(
  parameter PERIOD_BITS = 16
)
(
  input  wire                   clk_in,     // system clock signal
  input  wire                   rst_in,     // reset signal
  input  wire                   pulse_in,   // input pulse
  input  wire                   reload_in,  // reset counter to period_in (no pulse_out generated)
  input  wire [PERIOD_BITS-1:0] period_in,  // new period value
  output wire                   pulse_out   // divided output pulse
);

reg  [PERIOD_BITS-1:0] q_cnt;
wire [PERIOD_BITS-1:0] d_cnt;

always @(posedge clk_in)
  begin
    if (rst_in)
      q_cnt <= 0;
    else
      q_cnt <= d_cnt;
  end

assign d_cnt     = (reload_in || (pulse_in && (q_cnt == 0))) ? period_in     :
                   (pulse_in)                                ? q_cnt - 1'h1 : q_cnt;
assign pulse_out = pulse_in && (q_cnt == 0);

endmodule

