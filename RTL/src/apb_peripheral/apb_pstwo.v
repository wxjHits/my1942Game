/*
    用于控制PS2手柄的apb外设，只是采用软件进行模拟
    BASE_ADDR 0x40005000
    0x000 RW    PS2_CS 
    0x004 RW    PS2_CLK
    0x008 RW    PS2_DO 
    0x00C  R    PS2_DI 
*/

//-------------------------------------
module apb_pstwo(
    input  wire         PCLK        ,// Clock
    input  wire         PCLKG       ,// Gated Clock
    input  wire         PRESETn     ,// Reset
    input  wire         PSEL        ,// Device select
    input  wire [15:0]  PADDR       ,// Address
    input  wire         PENABLE     ,// Transfer control
    input  wire         PWRITE      ,// Write control
    input  wire [31:0]  PWDATA      ,// Write data
    input  wire [03:0]  ECOREVNUM   ,// Engineering-change-order revision bits
    output wire [31:0]  PRDATA      ,// Read data
    output wire         PREADY      ,// Device ready
    output wire         PSLVERR     ,// Device error response
    //PS2
    output wire         PS2_CS      ,
    output wire         PS2_CLK     ,
    output wire         PS2_DO      ,
    input  wire         PS2_DI      
);

	//write control
	wire write_enable;
    wire write_enable00;
    wire write_enable04;
    wire write_enable08;

    //signals
    reg        reg_ps2_cs ;
    reg        reg_ps2_clk;
    reg        reg_ps2_do ;
    reg        reg_ps2_di ;
    reg  [31:0] read_mux_word;

    always @(posedge PCLK or negedge PRESETn)begin
        if (~PRESETn)
            reg_ps2_di <= 'd0;
        else
            reg_ps2_di <= PS2_DI;
    end

	//main code
    //read operations
    reg [31:0] read_mux_le;
    always@(*)begin
        case(PADDR[11:0])
            12'h000:read_mux_le<={{31{1'b0}}, reg_ps2_cs};
            12'h004:read_mux_le<={{31{1'b0}}, reg_ps2_clk};
            12'h008:read_mux_le<={{31{1'b0}}, reg_ps2_do};
            12'h00C:read_mux_le<={{31{1'b0}}, reg_ps2_di};
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
    assign write_enable00=write_enable&(PADDR[11:0]==12'h000);
    assign write_enable04=write_enable&(PADDR[11:0]==12'h004);
    assign write_enable08=write_enable&(PADDR[11:0]==12'h008);
    assign read_enable  = PSEL & (~PWRITE);
	
    //write operations
    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            reg_ps2_cs<='d0;
        else if(write_enable00)
            reg_ps2_cs<=PWDATA[0:0];
    end

    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            reg_ps2_clk<='d0;
        else if(write_enable04)
            reg_ps2_clk<=PWDATA[0:0];
    end

    always@(posedge PCLK or negedge PRESETn)begin
        if(~PRESETn)
            reg_ps2_do<='d0;
        else if(write_enable08)
            reg_ps2_do<=PWDATA[0:0];
    end

  // Output read data to APB
  assign PRDATA = (read_enable) ? read_mux_word : {32{1'b0}};
  assign PREADY  = 1'b1; // Always ready
  assign PSLVERR = 1'b0; // Always okay

    assign PS2_CS  = reg_ps2_cs  ;
    assign PS2_CLK = reg_ps2_clk ;
    assign PS2_DO  = reg_ps2_do  ;
endmodule