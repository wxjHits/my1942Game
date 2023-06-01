/**********************************************************************************************************/

/*pause*/
/*4000 or 4004 Duty (D), envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)*/
/*4001 or 4005 Sweep unit: enabled (E), period (P), negate (N), shift (S)                                 */ 
/*4002 or 4006 Timer low (T)                                                                              */
/*4003 or 4007 Length counter load (L), timer high (T)                                                    */

/*triangle*/ 
/*4008 Length counter halt / linear counter control (C), linear counter load (R)                          */
/*4009 Unused                                                                                             */
/*400A Timer low (T)                                                                                      */
/*400B Length counter load (L), timer high (T), set linear counter reload flag                            */

/*noise*/
/*400C Envelope loop / length counter halt (L), constant volume (C), volume/envelope (V)                  */
/*400D Unused                                                                                             */
/*400E Loop noise (L), noise period (P)                                                                   */
/*400F Length counter load (L)                                                                            */

/*status write*/
/*4015 Enable DMC (D), noise (N), triangle (T), and pulse channels (2/1)                                  */

/*status write*/                                                                            
/*4015 DMC interrupt (I), frame interrupt (F), DMC active (D), length counter > 0 (N/T/2/1)               */
                         
/*frame counter*/
/*4017 Mode (M, 0 = 4-step, 1 = 5-step), IRQ inhibit flag (I)                                             */

/*0x5000_40??*/

module ahb_apu(
    input  wire                         HCLK,    
    input  wire                         HRESETn, 
    input  wire                         HSEL,    
    input  wire    [31:0]               HADDR,   
    input  wire    [1:0]                HTRANS,  
    input  wire    [2:0]                HSIZE,   
    input  wire    [3:0]                HPROT,   
    input  wire                         HWRITE,  
    input  wire    [31:0]               HWDATA,  
    input  wire                         HREADY,  
	
    output wire                         HREADYOUT, 
    output wire    [31:0]               HRDATA,  
    output wire                         HRESP,

    //output  wire    [7:0]               d_out,
    input   wire    [3:0]               mute_in,
    output  wire                        audio_out,
    //output  wire    [7:0]               d_in

    //INT
    output  wire                        PULSE0INT,
    output  wire                        PULSE1INT,
    output  wire                        TRIANGLEINT,
    output  wire                        NOISEINT
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg [7:0] addr;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr <= 8'b0;
  else if(read_en || write_en) addr <= HADDR[7:0];
end

reg write_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) write_en_reg <= 1'b0;
  else if(write_en) write_en_reg <= 1'b1;
  else  write_en_reg <= 1'b0;
end

reg write_en_reg_r1;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) write_en_reg_r1 <= 1'b0;
  else if(write_en_reg) write_en_reg_r1 <= 1'b1;
  else  write_en_reg_r1 <= 1'b0;
end

wire write_en_reg_r;
assign write_en_reg_r = (write_en_reg_r1) | (write_en_reg); 

reg [7:0] data;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) data <= 8'b0;
  else if(read_en || write_en_reg_r) data <= HWDATA[7:0];
end

// CPU cycle pulse.
reg  [5:0] q_clk_cnt;
wire [5:0] d_clk_cnt;
wire       cpu_cycle_pulse;
wire       apu_cycle_pulse;
wire       e_pulse;
wire       l_pulse;
wire       f_pulse;
reg        q_pulse0_en;
wire       d_pulse0_en;
reg        q_pulse1_en;
wire       d_pulse1_en;
reg        q_triangle_en;
wire       d_triangle_en;
reg        q_noise_en;
wire       d_noise_en;

always @(posedge HCLK)
  begin
    if (~HRESETn)
      begin
        q_clk_cnt     <= 6'h00;
        q_pulse0_en   <= 1'b0;
        q_pulse1_en   <= 1'b0;
        q_triangle_en <= 1'b0;
        q_noise_en    <= 1'b0;
      end
    else
      begin
        q_clk_cnt     <= d_clk_cnt;
        q_pulse0_en   <= d_pulse0_en;
        q_pulse1_en   <= d_pulse1_en;
        q_triangle_en <= d_triangle_en;
        q_noise_en    <= d_noise_en;
      end
  end

assign d_clk_cnt     = (q_clk_cnt == 6'h37) ? 6'h00 : q_clk_cnt + 6'h01;
assign d_pulse0_en   = (write_en_reg_r && (addr == 8'h15)) ? data[0] : q_pulse0_en;
assign d_pulse1_en   = (write_en_reg_r && (addr == 8'h15)) ? data[1] : q_pulse1_en;
assign d_triangle_en = (write_en_reg_r && (addr == 8'h15)) ? data[2] : q_triangle_en;
assign d_noise_en    = (write_en_reg_r && (addr == 8'h15)) ? data[3] : q_noise_en;

assign cpu_cycle_pulse = (q_clk_cnt == 6'h00);


apu_div #(.PERIOD_BITS(1)) apu_pulse_gen(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .pulse_in(cpu_cycle_pulse),
  .reload_in(1'b0),
  .period_in(1'b1),
  .pulse_out(apu_cycle_pulse)
);

//
// Frame counter.
//
/*reg apu_cycle_pulse_r1;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) apu_cycle_pulse_r1 <= 1'b0;
  else if(apu_cycle_pulse) apu_cycle_pulse_r1 <= 1'b1;
  else  apu_cycle_pulse_r1 <= 1'b0;
end

wire apu_cycle_pulse_r;
assign apu_cycle_pulse_r = (apu_cycle_pulse_r1 | apu_cycle_pulse);
*/
wire frame_counter_mode_wr;

apu_frame_counter apu_frame_counter_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .cpu_cycle_pulse_in(cpu_cycle_pulse),
  .apu_cycle_pulse_in(apu_cycle_pulse),
  .mode_in(data[7:6]),
  .mode_wr_in(frame_counter_mode_wr),
  .e_pulse_out(e_pulse),
  .l_pulse_out(l_pulse),
  .f_pulse_out(f_pulse)
);

assign frame_counter_mode_wr = write_en_reg_r && (addr == 8'h17);

//
// Pulse 0 channel.
//
wire [3:0] pulse0_out;
wire       pulse0_active;
wire       pulse0_wr;

apu_pulse #(.CHANNEL(0)) apu_pulse0_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .en_in(q_pulse0_en),
  .cpu_cycle_pulse_in(cpu_cycle_pulse),
  .lc_pulse_in(l_pulse),
  .eg_pulse_in(e_pulse),
  .a_in(addr[1:0]),
  .d_in(data[7:0]),
  .wr_in(pulse0_wr),
  .pulse_out(pulse0_out),
  .active_out(pulse0_active)
);

assign pulse0_wr = write_en_reg_r && (addr[4:2] == 2'b000);

//
// Pulse 1 channel.
//
wire [3:0] pulse1_out;
wire       pulse1_active;
wire       pulse1_wr;

apu_pulse #(.CHANNEL(1)) apu_pulse1_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .en_in(q_pulse1_en),
  .cpu_cycle_pulse_in(cpu_cycle_pulse),
  .lc_pulse_in(l_pulse),
  .eg_pulse_in(e_pulse),
  .a_in(addr[1:0]),
  .d_in(data[7:0]),
  .wr_in(pulse1_wr),
  .pulse_out(pulse1_out),
  .active_out(pulse1_active)
);

assign pulse1_wr = write_en_reg_r && (addr[4:2] == 2'b001);

//
// Triangle channel.
//
wire [3:0] triangle_out;
wire       triangle_active;
wire       triangle_wr;

apu_triangle apu_triangle_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .en_in(q_triangle_en),
  .cpu_cycle_pulse_in(cpu_cycle_pulse),
  .lc_pulse_in(l_pulse),
  .eg_pulse_in(e_pulse),
  .a_in(addr[1:0]),
  .d_in(data[7:0]),
  .wr_in(triangle_wr),
  .triangle_out(triangle_out),
  .active_out(triangle_active)
);

assign triangle_wr = write_en_reg_r && (addr[4:2] == 2'b010);

//
// Noise channel.
//
wire [3:0] noise_out;
wire       noise_active;
wire       noise_wr;

apu_noise apu_noise_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .en_in(q_noise_en),
  .apu_cycle_pulse_in(apu_cycle_pulse),
  .lc_pulse_in(l_pulse),
  .eg_pulse_in(e_pulse),
  .a_in(addr[1:0]),
  .d_in(data[7:0]),
  .wr_in(noise_wr),
  .noise_out(noise_out),
  .active_out(noise_active)
);

assign noise_wr = write_en_reg_r && (addr[4:2] == 2'b011);

//
// Mixer.
//
apu_mixer apu_mixer_blk(
  .clk_in(HCLK),
  .rst_in(~HRESETn),
  .mute_in(mute_in),
  .pulse0_in(pulse0_out),
  .pulse1_in(pulse1_out),
  .triangle_in(triangle_out),
  .noise_in(noise_out),
  .audio_out(audio_out)
);

//
//HRDATA
//

reg read_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) read_en_reg <= 1'b0;
  else if(read_en) read_en_reg <= 1'b1;
  else  read_en_reg <= 1'b0;
end

assign HRDATA = (read_en_reg && (addr == 8'h15)) ?
               { 28'b0000, noise_active, triangle_active, pulse1_active, pulse0_active } : 32'h00;


//添加的中断
reg [1:0] pulse0_int_reg;
reg [1:0] pulse1_int_reg;
reg [1:0] triangle_int_reg;
reg [1:0] noise_int_reg;

reg pulse0_active_r;
reg pulse1_active_r;
reg triangle_active_r;
reg noise_active_r;

always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) begin
      pulse0_active_r <= 1'b0;
      pulse1_active_r <= 1'b0;
      triangle_active_r <= 1'b0;
      noise_active_r <= 1'b0;
  end
  else begin
      pulse0_active_r <= pulse0_active;
      pulse1_active_r <= pulse1_active;
      triangle_active_r <= triangle_active;
      noise_active_r <= noise_active;
  end
end

assign PULSE0INT    = (~pulse0_active) & pulse0_active_r;
assign PULSE1INT    = (~pulse1_active) & pulse1_active_r;
assign TRIANGLEINT  = (~triangle_active) & triangle_active_r;
assign NOISEINT     = (~noise_active) & noise_active_r;

endmodule
