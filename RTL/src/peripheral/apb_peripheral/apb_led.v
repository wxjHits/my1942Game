module apb_led (
// --------------------------------------------------------------------------
// Port Definitions
// --------------------------------------------------------------------------
  input  wire        PCLK,     // Clock
  input  wire        PCLKG,    // Gated Clock
  input  wire        PRESETn,  // Reset

  input  wire        PSEL,     // Device select
  input  wire [15:0] PADDR,    // Address
  input  wire        PENABLE,  // Transfer control
  input  wire        PWRITE,   // Write control
  input  wire [31:0] PWDATA,   // Write data

  input  wire [3:0]  ECOREVNUM,// Engineering-change-order revision bits

  output wire [31:0] PRDATA,   // Read data
  output wire        PREADY,   // Device ready
  output wire        PSLVERR,  // Device error response
  
  output wire [7:0]  LED
);

wire write_enable;
wire read_enable;
wire write_enable00;

reg [7:0] LED_r;

assign PREADY = 1'b1;
assign PSLVERR = 1'b0;
assign PRDATA = (read_enable & (PADDR[11:2] == 10'h000)) ? {24'b0,LED_r}:32'd0;

assign  read_enable  = PSEL & PENABLE & (~PWRITE); // assert for whole APB read transfer
assign  write_enable = PSEL & (PENABLE) & PWRITE; // assert for 1st cycle of write transfer
assign  write_enable00 = write_enable & (PADDR[11:2] == 10'h000);

always @(posedge PCLKG)begin
	if (~PRESETn)
    	LED_r <= 2'b00;
    else if (write_enable00)
      	LED_r <= PWDATA[7:0];
end
assign LED = LED_r;

endmodule