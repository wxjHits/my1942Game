//BASE_ADDR 0x40001000
//0x00  W LED[7:0]   
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

	//write control
	wire write_enable;
	wire write_enable00;

  reg    [31:0] read_mux_word;

	//control register
	reg [7:0] led_data_r;

	//main code
	//write signal
	assign write_enable=PSEL&(~PENABLE)&PWRITE;
	assign write_enable00=write_enable&(PADDR[11:2]==10'h000);
  assign  read_enable  = PSEL & (~PWRITE);
	//write operations
	always@(posedge PCLK or negedge PRESETn)begin
		if(~PRESETn)
			led_data_r<='d0;
		else if(write_enable00)
			led_data_r<=PWDATA[7:0];
	end

  //read operations
  always @(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)
      read_mux_word <= 32'd0;
    else if (PADDR[11:4] == 8'h00) begin
            case (PADDR[3:2])
                2'b00:  read_mux_word <= {{24{1'b0}} ,led_data_r};
                default : read_mux_word <= {32{1'bx}};
            endcase
        end
    end
	// Output read data to APB
  assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

  //connect external
  assign LED = led_data_r;
endmodule