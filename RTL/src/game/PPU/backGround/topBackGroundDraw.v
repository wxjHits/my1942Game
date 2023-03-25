`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module topBackGroundDraw #(
    parameter                       ADDR_WIDTH = (`NAMETABLE_AHBBUS_ADDRWIDTH)
)(
    input   wire                    clk_50MHz   ,
    input   wire                    clk_100MHz  ,
    input   wire                    clk_25p2MHz ,
    input   wire                    rstn        ,
    //cpu ahb-lite bus
    input  wire                     NAMETABLE_HCLK        ,
    input  wire                     NAMETABLE_HRESETn     ,
    input  wire                     NAMETABLE_HSEL        ,
    input  wire   [31:0]            NAMETABLE_HADDR       ,
    input  wire   [1:0]             NAMETABLE_HTRANS      ,
    input  wire   [2:0]             NAMETABLE_HSIZE       ,
    input  wire   [3:0]             NAMETABLE_HPROT       ,
    input  wire                     NAMETABLE_HWRITE      ,
    input  wire   [31:0]            NAMETABLE_HWDATA      ,
    input wire                      NAMETABLE_HREADY      ,
    output wire                     NAMETABLE_HREADYOUT   ,
    output wire   [31:0]            NAMETABLE_HRDATA      ,
    output wire   [1:0]             NAMETABLE_HRESP       ,

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
  .HCLK       (NAMETABLE_HCLK       ) ,
  .HRESETn    (NAMETABLE_HRESETn    ) ,
  .HSEL       (NAMETABLE_HSEL       ) ,
  .HADDR      (NAMETABLE_HADDR      ) ,
  .HTRANS     (NAMETABLE_HTRANS     ) ,
  .HSIZE      (NAMETABLE_HSIZE      ) ,
  .HPROT      (NAMETABLE_HPROT      ) ,
  .HWRITE     (NAMETABLE_HWRITE     ) ,
  .HWDATA     (NAMETABLE_HWDATA     ) ,
  .HREADY     (NAMETABLE_HREADY     ) ,
  .HREADYOUT  (NAMETABLE_HREADYOUT  ) ,
  .HRDATA     (NAMETABLE_HRDATA     ) ,
  .HRESP      (NAMETABLE_HRESP      ) ,

  .BRAM_RDADDR(BRAM_RDADDR) ,
  .BRAM_WRADDR(BRAM_WRADDR) ,
  .BRAM_RDATA (BRAM_RDATA ) ,
  .BRAM_WDATA (BRAM_WDATA ) ,
  .BRAM_WRITE (BRAM_WRITE )
);

wire [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0] nameTableRamIndex;
wire [31:0] nameTableRamDataO;
wire    [9-1:0]  attributeAddr;
wire    [4*(`BYTE)-1:0]     attributeTableDataO;

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
    .nameTableRamDataO(nameTableRamDataO),
    .attributeAddr(attributeAddr),
    .attributeTableDataO(attributeTableDataO)
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
    //属性表
    .attributeAddr(attributeAddr),
    .attributeTableDataO(attributeTableDataO),
    
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