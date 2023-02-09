/**********************************************/
/*   LCD                                      */
/*   LCD_CS           0X5000_0000             */
/*   LCD_RS           0X5000_0004             */
/*   LCD_WR           0X5000_0008             */
/*   LCD_RD           0X5000_000C             */
/*   LCD_RST          0X5000_0010             */
/*   LCD_BL_CTR       0X5000_0014             */
/*   LCD_DATA         0X5000_0018             */
/**********************************************/
module ahb_lcd(
    input  wire                         HCLK,    
    input  wire                         HRESETn, 
    input  wire                         HSEL,    
    input  wire   [31:0]                HADDR,   
    input  wire    [1:0]                HTRANS,  
    input  wire    [2:0]                HSIZE,   
    input  wire    [3:0]                HPROT,   
    input  wire                         HWRITE,  
    input  wire   [31:0]                HWDATA,  
    input  wire                         HREADY,  
	
    output wire                         HREADYOUT, 
    output wire    [31:0]               HRDATA,  
    output wire                         HRESP,

    output  wire                        LCD_CS,
    output  wire                        LCD_RS,
    output  wire                        LCD_WR,
    output  wire                        LCD_RD,
    output  wire                        LCD_RST,
    output  wire                        LCD_BL_CTR,
    output  wire    [15:0]              LCD_DATA
);

assign HRESP = 1'b0;
assign HREADYOUT = 1'b1;

wire read_en;
assign read_en=HSEL&HTRANS[1]&(~HWRITE)&HREADY;

wire write_en;
assign write_en=HSEL&HTRANS[1]&(HWRITE)&HREADY;

reg [5:0] addr;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr <= 6'b0;
  else if(read_en || write_en) addr <= HADDR[7:2];
end

reg write_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) write_en_reg <= 1'b0;
  else if(write_en) write_en_reg <= 1'b1;
  else  write_en_reg <= 1'b0;
end

wire        LCD_CS_en;
wire        LCD_RS_en;
wire        LCD_WR_en;
wire        LCD_RD_en;
wire        LCD_RST_en;
wire        LCD_BL_CTR_en;
wire [15:0] LCD_DATA_en;

assign LCD_CS_en        = addr == 6'h00 & write_en_reg;
assign LCD_RS_en        = addr == 6'h01 & write_en_reg;
assign LCD_WR_en        = addr == 6'h02 & write_en_reg;
assign LCD_RD_en        = addr == 6'h03 & write_en_reg;
assign LCD_RST_en       = addr == 6'h04 & write_en_reg;
assign LCD_BL_CTR_en    = addr == 6'h05 & write_en_reg;
assign LCD_DATA_en      = addr == 6'h06 & write_en_reg;

reg        LCD_CS_reg;
reg        LCD_RS_reg;
reg        LCD_WR_reg;
reg        LCD_RD_reg;
reg        LCD_RST_reg;
reg        LCD_BL_CTR_reg;
reg [15:0] LCD_DATA_reg;

always@(posedge HCLK or negedge HRESETn) begin
    if(~HRESETn) begin
        LCD_CS_reg <= 1'b0;
        LCD_RS_reg <= 1'b0;
        LCD_WR_reg <= 1'b0;
        LCD_RD_reg <= 1'b0;
        LCD_RST_reg <= 1'b0;
        LCD_BL_CTR_reg <= 1'b0;
        LCD_DATA_reg <= 16'b0;
    end 
    else begin
        if (LCD_CS_en) 
            LCD_CS_reg <= HWDATA[0];
        if (LCD_RS_en) 
            LCD_RS_reg <= HWDATA[0];
        if (LCD_WR_en)
            LCD_WR_reg <= HWDATA[0];
        if (LCD_RD_en)
            LCD_RD_reg <= HWDATA[0];
        if (LCD_RST_en)
            LCD_RST_reg <= HWDATA[0];
        if (LCD_BL_CTR_en)
            LCD_BL_CTR_reg <= HWDATA[0];
        if (LCD_DATA_en)
            LCD_DATA_reg <= HWDATA[15:0];
    end
end

//-------------------------------------------------------------------       
//                  HRDATA DECODER
//-------------------------------------------------------------------

assign HRDATA    =  (   addr == 6'h00   ) ?  {31'b0,LCD_CS_reg    }  :   (         
                    (   addr == 6'h01   ) ?  {31'b0,LCD_RS_reg    }  :   (
                    (   addr == 6'h02   ) ?  {31'b0,LCD_WR_reg    }  :   (
                    (   addr == 6'h03   ) ?  {31'b0,LCD_RD_reg    }  :   (
                    (   addr == 6'h04   ) ?  {31'b0,LCD_RST_reg   }  :   (
                    (   addr == 6'h05   ) ?  {31'b0,LCD_BL_CTR_reg}  :   (
                    (   addr == 6'h06   ) ?  {16'b0,LCD_DATA_reg  }  :   32'b0))))));

assign LCD_CS       = LCD_CS_reg;
assign LCD_RS       = LCD_RS_reg;
assign LCD_WR       = LCD_WR_reg;
assign LCD_RD       = LCD_RD_reg;
assign LCD_RST      = LCD_RST_reg;
assign LCD_BL_CTR   = LCD_BL_CTR_reg;
assign LCD_DATA     = LCD_DATA_reg;
endmodule


