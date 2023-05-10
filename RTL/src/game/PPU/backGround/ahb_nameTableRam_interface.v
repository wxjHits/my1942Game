`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module ahb_nameTableRam_interface #(
    parameter                       ADDR_WIDTH = (`NAMETABLE_AHBBUS_ADDRWIDTH))(
    input  wire                     HCLK,    
    input  wire                     HRESETn, 
    input  wire                     HSEL,    
    input  wire   [31:0]            HADDR,   
    input  wire   [1:0]             HTRANS,  
    input  wire   [2:0]             HSIZE,   
    input  wire   [3:0]             HPROT,   
    input  wire                     HWRITE,  
    input  wire   [31:0]            HWDATA,   
    input  wire                     HREADY, 
    output wire                     HREADYOUT, 
    output wire   [31:0]            HRDATA,  
    output wire   [1:0]             HRESP,
    //
    output reg                      scrollEn        ,//背景滚动使能
    output reg    [07:0]            scrollCntMax    ,//背景滚动的速度控制
    output reg    [23:0]            flashAddrStart  ,//关卡数据从flash的什么地址开始
    output reg    [07:0]            mapBackgroundMax,//地图在当前关卡一共有几幅图
    input  wire   [07:0]            mapBackgroundCnt,//当前开始扫描第几幅图片
    input  wire   [07:0]            mapScrollPtr    ,//名称表的滚动指针的低8bit
    input  wire                     scrollingFlag   ,//表明背景正在滚动中
    output reg                      scrollPause     ,//背景暂停控制信号
    output reg                      createPlaneIntrEn,//产生飞机的中断使能

    output reg                      ahb_Palette_H_L ,//选择调色板 开始界面选择1 运行界面选择0
    //
    output wire   [ADDR_WIDTH-1:0]  BRAM_RDADDR,
    output wire   [ADDR_WIDTH-1:0]  BRAM_WRADDR,
    input  wire   [31:0]            BRAM_RDATA,
    output wire   [31:0]            BRAM_WDATA,
    output wire   [3:0]             BRAM_WRITE
);

assign HRESP = 2'b0;
// assign HRDATA = BRAM_RDATA;

wire trans_en;
assign trans_en = HSEL & HTRANS[1];

wire write_en;
assign write_en = trans_en & HWRITE;

wire read_en;
assign read_en = trans_en & (~HWRITE);

/*****对nameTableRam的读写 0x000~0x7FF 0~2047*****/
reg [3:0] size_dec;
always@(*) begin
  case({HADDR[1:0],HSIZE[1:0]})
    4'h0 : size_dec = 4'h1;
    4'h1 : size_dec = 4'h3;
    4'h2 : size_dec = 4'hf;
    4'h4 : size_dec = 4'h2;
    4'h8 : size_dec = 4'h4;
    4'h9 : size_dec = 4'hc;
    4'hc : size_dec = 4'h8;
    default : size_dec = 4'h0;
  endcase
end
reg [3:0] size_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) size_reg <= 0;
  else if(write_en & HREADY) size_reg <= size_dec;
end

reg [ADDR_WIDTH:0] addr_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) addr_reg <= 0;
  else if(trans_en & HREADY) addr_reg <= HADDR[1+(ADDR_WIDTH+1):2];//地址空间0~0x7FF
end

reg wr_en_reg;
always@(posedge HCLK or negedge HRESETn) begin
  if(~HRESETn) wr_en_reg <= 1'b0;
  else if(HREADY) wr_en_reg <= write_en;
  else wr_en_reg <= 1'b0;
end

//
wire   BRAM_EN = (wr_en_reg && addr_reg[ADDR_WIDTH]==0);
assign BRAM_RDADDR = HADDR[(ADDR_WIDTH+1):2];
assign BRAM_WRADDR  = addr_reg;
assign HREADYOUT = 1'b1;
assign BRAM_WRITE = BRAM_EN ? size_reg : 4'h0;
assign BRAM_WDATA = HWDATA; 

reg [31:0] readDataMux;
assign HRDATA = readDataMux;
always@(*)begin
  casex(addr_reg)
    10'b0x_xxxx_xxxx:readDataMux = BRAM_RDATA;
    10'b10_0000_0000:readDataMux = {31'b0,scrollEn};
    10'b10_0000_0001:readDataMux = {24'b0,scrollCntMax};
    10'b10_0000_0010:readDataMux = {8'b0,flashAddrStart};
    10'b10_0000_0011:readDataMux = {24'b0,mapBackgroundMax};
    10'b10_0000_0100:readDataMux = {24'b0,mapBackgroundCnt};
    10'b10_0000_0101:readDataMux = {24'b0,mapScrollPtr};
    10'b10_0000_0110:readDataMux = {31'b0,scrollingFlag};
    10'b10_0000_0111:readDataMux = {31'b0,scrollPause};
    10'b10_0000_1000:readDataMux = {31'b0,createPlaneIntrEn};
    10'b10_0000_1001:readDataMux = {31'b0,ahb_Palette_H_L};
  endcase
end
/*****对scrollCtrl模块的读写控制*****/
    // output reg                      scrollEn        ,0x800
    // output reg    [07:0]            scrollCntMax    ,0x804
    // output reg    [23:0]            flashAddrStart  ,0x808
    // output reg    [07:0]            mapBackgroundMax,0x80C
    // input  wire   [07:0]            mapBackgroundCnt,0x810
    // input  wire   [07:0]            mapScrollPtr    ,0x814
    // input  wire                     scrollingFlag   ,0x818
    // output reg                      scrollPause     ,0x81C
    // output reg                      createPlaneIntrEn,0x820
    // output reg                      ahb_Palette_H_L ,0x824
wire scrollCtrlAddrEn = (wr_en_reg && addr_reg[ADDR_WIDTH:4]==6'b100000);

wire write_scrollEn_en          = scrollCtrlAddrEn && addr_reg[3:0]==4'd0;
wire write_scrollCntMax_en      = scrollCtrlAddrEn && addr_reg[3:0]==4'd1;
wire write_flashAddrStart_en    = scrollCtrlAddrEn && addr_reg[3:0]==4'd2;
wire write_mapBackgroundMax_en  = scrollCtrlAddrEn && addr_reg[3:0]==4'd3;
wire write_scrollPause_en       = scrollCtrlAddrEn && addr_reg[3:0]==4'd7;
wire write_createPlaneIntrEn_en = scrollCtrlAddrEn && addr_reg[3:0]==4'd8;
wire write_ahb_Palette_H_L_en   = scrollCtrlAddrEn && addr_reg[3:0]==4'd9;

always@(posedge HCLK or negedge HRESETn)begin
  if(~HRESETn)begin
    scrollEn          <= 1'd0;
    scrollCntMax      <= 8'd0;
    flashAddrStart    <=24'd0;
    mapBackgroundMax  <= 8'd0;
    scrollPause       <= 1'd0;
    createPlaneIntrEn <= 1'd0;
    ahb_Palette_H_L   <= 1'd1;
  end
  else begin
    if(write_scrollEn_en)
      scrollEn<=HWDATA[00:0];
    if(write_scrollCntMax_en)
      scrollCntMax<=HWDATA[07:0];
    if(write_flashAddrStart_en)
      flashAddrStart<=HWDATA[23:0];
    if(write_mapBackgroundMax_en)
      mapBackgroundMax<=HWDATA[07:0];
    if(write_scrollPause_en)
      scrollPause<=HWDATA[00:0];
    if (write_createPlaneIntrEn_en)
      createPlaneIntrEn<=HWDATA[00:0];
    if (write_ahb_Palette_H_L_en)
        ahb_Palette_H_L<=HWDATA[00:0];
  end
end

endmodule
