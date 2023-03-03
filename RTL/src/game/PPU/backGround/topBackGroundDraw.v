`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module topBackGroundDraw #(
    parameter                       ADDR_WIDTH = (`NAMETABLE_AHBBUS_ADDRWIDTH)
)(
    input   wire                    clk_50MHz   ,
    input   wire                    clk_100MHz  ,
    input   wire                    clk_25p2MHz ,
    input   wire                    rstn        ,
    //cpu ahb-lite bus
    input  wire                     HCLK        ,
    input  wire                     HRESETn     ,
    input  wire                     HSEL        ,
    input  wire   [31:0]            HADDR       ,
    input  wire   [1:0]             HTRANS      ,
    input  wire   [2:0]             HSIZE       ,
    input  wire   [3:0]             HPROT       ,
    input  wire                     HWRITE      ,
    input  wire   [31:0]            HWDATA      ,
    input wire                      HREADY      ,
    output wire                     HREADYOUT   ,
    output wire   [31:0]            HRDATA      ,
    output wire   [1:0]             HRESP       ,

    //from VGA_driver
    input  wire [`VGA_POSXY_BIT-1:0] vgaPosX    ,
    input  wire [`VGA_POSXY_BIT-1:0] vgaPosY    ,

    output wire [`RGB_BIT-1:0] backGroundVgaRgbOut
);

    wire   [ADDR_WIDTH-1:0]  BRAM_RDADDR    ;
    wire   [ADDR_WIDTH-1:0]  BRAM_WRADDR    ;
    wire   [31:0]            BRAM_RDATA     ;
    wire   [31:0]            BRAM_WDATA     ;
    wire   [3:0]             BRAM_WRITE     ;

ahb_nameTableRam_interface u_ahb_nameTableRam_interface(
  .HCLK       (HCLK       ) ,
  .HRESETn    (HRESETn    ) ,
  .HSEL       (HSEL       ) ,
  .HADDR      (HADDR      ) ,
  .HTRANS     (HTRANS     ) ,
  .HSIZE      (HSIZE      ) ,
  .HPROT      (HPROT      ) ,
  .HWRITE     (HWRITE     ) ,
  .HWDATA     (HWDATA     ) ,
  .HREADY     (HREADY     ) ,
  .HREADYOUT  (HREADYOUT  ) ,
  .HRDATA     (HRDATA     ) ,
  .HRESP      (HRESP      ) ,

  .BRAM_RDADDR(BRAM_RDADDR) ,
  .BRAM_WRADDR(BRAM_WRADDR) ,
  .BRAM_RDATA (BRAM_RDATA ) ,
  .BRAM_WDATA (BRAM_WDATA ) ,
  .BRAM_WRITE (BRAM_WRITE )
);

wire [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] nameTableRamIndex;
wire [31:0] nameTableRamDataO;

nameTableRam u_nameTableRam(
    //cortex-m0
    .clk(clk_50MHz),
    .addra(BRAM_WRADDR),
    .addrb(BRAM_RDADDR),
    .dina(BRAM_WDATA),
    .wea(BRAM_WRITE),
    .doutb(BRAM_RDATA),

    //到tiledraw函数
    .clk_tileDraw(clk_100MHz),
    .nameTableRamIndex(nameTableRamIndex),
    .nameTableRamDataO(nameTableRamDataO)
);

wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  backTileIndex;
wire    [`SPRITE_TILEDATA_BIT-1:0]     backTileDataI;
backTileDraw u_backTileDraw(
  .clk(clk_100MHz),
  .rstn(rstn),

    //from VGA_driver
   .vgaPosX(vgaPosX),
   .vgaPosY(vgaPosY),

    //当前VGA坐标对应的名称表位置
    .nameTableRamIndex(nameTableRamIndex),
    .nameTableRamDataO(nameTableRamDataO),
    
    //索引背景的图案表
    .backTileIndex(backTileIndex),
    .backTileDataI(backTileDataI),
    
    //to VGA_driver.v
    .backGroundVgaRgbOut(backGroundVgaRgbOut)
);

backGroundTileRom u_backGroundTileRom(
    //from backTileDraw.v
    .backTileIndex(backTileIndex),
    .backTileDataI(backTileDataI)
);

endmodule