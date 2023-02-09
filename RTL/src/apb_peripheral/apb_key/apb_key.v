//-------------------------------------
// Programmer's model
// -------------------------------
//BASE_ADDR 0x40002000
// 0x000 RW    Data read
// 0x004 RW    Interrupt Enable Set
// 0x008 R     Interrupt Status
//       W     Interrupt Status Clear
// 0x400 - 0x7FC : Byte 0 masked access
// 0x800 - 0xBFC : Byte 1 masked access
//-------------------------------------
module apb_key (
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
  
  input  wire [3:0]  PORTIN,    //GPIO input

  output wire [3:0]  GPIOINT,   //GPIO Interrupt
  output wire        COMBINT    //Combined interrupt
);

	//write control
	wire write_enable;
    wire write_enable04;

    //signals
    reg  [3:0] reg_intr_en;
    reg  [3:0] reg_intr_state;

    reg  [31:0] read_mux_word;
    //interrupt signals
    wire   [3:0] new_raw_int;
  // ----------------------------------------------------------
  // Synchronize input with double stage flip-flops
  // ----------------------------------------------------------
  // Signals for input double flop-flop synchroniser
  reg    [3:0] reg_in_sync1;
  reg    [3:0] reg_in_sync2;
  wire   [3:0] reg_datain;
  always @(posedge PCLK or negedge PRESETn)
  begin
    if (~PRESETn)begin
      reg_in_sync1 <= 'd0;
      reg_in_sync2 <= 'd0;
    end
    else begin
      reg_in_sync1 <= PORTIN;
      reg_in_sync2 <= reg_in_sync1;
    end
  end

  assign reg_datain = reg_in_sync2;

	//main code
    //read operations
    reg [31:0]read_mux_le;
    always@(*)begin
        case(PADDR[11:2])
            10'h000:read_mux_le<={{28{1'b0}}, reg_datain};
            10'h001:read_mux_le<={{28{1'b0}}, reg_intr_en};
            10'h002:read_mux_le<={{28{1'b0}}, reg_intr_state};
            default:read_mux_le={32{1'bx}};
        endcase
    end
    always@(posedge PCLK or negedge PRESETn)begin
        if(!PRESETn)
            read_mux_word<='d0;
        else
            read_mux_word<=read_mux_le;
    end
	//write signal
	assign write_enable=PSEL&(~PENABLE)&PWRITE;
    assign write_enable04=write_enable&(PADDR[11:2]==10'h001);
    assign read_enable  = PSEL & (~PWRITE);
	
    //write operations
    //interrupt enable
	  always@(posedge PCLK or negedge PRESETn)begin
	  	if(~PRESETn)
	  		reg_intr_en<='d0;
	  	else if(write_enable04)
	  		reg_intr_en<=PWDATA[7:0];
	  end
  
  //interrupt state register
  wire [3:0] new_masked_int;
  assign   new_masked_int = new_raw_int & reg_intr_en;
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)
        reg_intr_state<='d0;
    else
        reg_intr_state<=new_masked_int;
  end
  //interrupt (input state and edge detection)
  reg [3:0] reg_last_datain;
  always@(posedge PCLK or negedge PRESETn)begin
    if(!PRESETn)
        reg_last_datain<='d0;
    else
        reg_last_datain<=reg_datain;
  end
  wire [3:0] rise_edge_int;
  assign rise_edge_int = reg_datain&(~reg_last_datain);
  // assign new_raw_int=rise_edge_int;
  assign new_raw_int=reg_datain;


  // Output read data to APB
  assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

  //connect external
  assign GPIOINT = reg_intr_state;
  assign COMBINT = (|reg_intr_state);

endmodule