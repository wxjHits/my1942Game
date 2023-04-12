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
    //to topPPU
    output wire [`RGB_BIT-1:0] backGroundVgaRgbOut,
    //to SPI_FLASH
    output  wire            scrollEn        ,// 用于软件还是硬件控制SPI_FLASH
    output  wire            SPI_CLK         ,
    output  wire            SPI_CS          ,
    output  wire            SPI_MOSI        ,
    input   wire            SPI_MISO        
);

    wire   [ADDR_WIDTH-1:0]  BRAM_RDADDR    ;
    wire   [ADDR_WIDTH-1:0]  BRAM_WRADDR    ;
    wire   [31:0]            BRAM_RDATA     ;
    wire   [31:0]            BRAM_WDATA     ;
    wire   [3:0]             BRAM_WRITE     ;

    //AHB-Lite W/R scrollCtrl模块
    // wire                    scrollEn        ;// Write & Read
    wire    [07:0]          scrollCntMax    ;// Write & Read
    wire    [23:0]          flashAddrStart  ;// Write & Read
    wire    [07:0]          mapBackgroundMax;// Write & Read
    wire    [07:0]          mapBackgroundCnt;// only Read
    wire    [07:0]          mapScrollPtr    ;// only Read
    wire                    scrollingFlag   ;// only Read


ahb_nameTableRam_interface u_ahb_nameTableRam_interface(
    .HCLK               (NAMETABLE_HCLK     ),
    .HRESETn            (NAMETABLE_HRESETn  ),
    .HSEL               (NAMETABLE_HSEL     ),
    .HADDR              (NAMETABLE_HADDR    ),
    .HTRANS             (NAMETABLE_HTRANS   ),
    .HSIZE              (NAMETABLE_HSIZE    ),
    .HPROT              (NAMETABLE_HPROT    ),
    .HWRITE             (NAMETABLE_HWRITE   ),
    .HWDATA             (NAMETABLE_HWDATA   ),
    .HREADY             (NAMETABLE_HREADY   ),
    .HREADYOUT          (NAMETABLE_HREADYOUT),
    .HRDATA             (NAMETABLE_HRDATA   ),
    .HRESP              (NAMETABLE_HRESP    ),
    //to scrollCtrl.v
    .scrollEn           (scrollEn           ),
    .scrollCntMax       (scrollCntMax       ),
    .flashAddrStart     (flashAddrStart     ),
    .mapBackgroundMax   (mapBackgroundMax   ),
    .mapBackgroundCnt   (mapBackgroundCnt   ),
    .mapScrollPtr       (mapScrollPtr       ),
    .scrollingFlag      (scrollingFlag      ),
    //to nameTableRam.v
    .BRAM_RDADDR        (BRAM_RDADDR        ),
    .BRAM_WRADDR        (BRAM_WRADDR        ),
    .BRAM_RDATA         (BRAM_RDATA         ),
    .BRAM_WDATA         (BRAM_WDATA         ),
    .BRAM_WRITE         (BRAM_WRITE         )
);

    wire    [03:0]  writeNameEn     ;
    wire    [08:0]  writeNameAddr   ;
    wire    [31:0]  writeNameData   ;
    wire    [03:0]  writeAttrEn     ;
    wire    [08:0]  writeAttrAddr   ;
    wire    [31:0]  writeAttrData   ;
//产生帧率中断
    //产生的中断进行计数器计数
    wire vgaIntr;
    reg VGA_Intr_r0;
    reg VGA_Intr_r1;
    always@(posedge clk_100MHz)begin
        if(~rstn)begin
            VGA_Intr_r0<=0;
            VGA_Intr_r1<=0;
        end
        else begin
            VGA_Intr_r0<=(vgaPosX==`GAME_START_POSX+`GAME_WINDOW_WIDTH-1) && (vgaPosY==`GAME_START_POSY+`GAME_WINDOW_HEIGHT-1);
            // VGA_Intr_r0<=(vgaPosX[3:0]==4'd3);
            VGA_Intr_r1<=VGA_Intr_r0;
        end
    end
    assign vgaIntr = VGA_Intr_r0 & (~VGA_Intr_r1);

    wire [8:0]   scrollPtrOut;

//滚动控制,将数据从flash搬运到nameTableRam
 scrollCtrl u_scrollCtrl(
    //clk & rstn
    .clk                (clk_100MHz         ),
    .rstn               (rstn               ),
    //CPU AHB-Lite
    .scrollEn           (scrollEn           ),
    .scrollCntMax       (scrollCntMax       ),
    .flashAddrStart     (flashAddrStart     ),
    .mapBackgroundMax   (mapBackgroundMax   ),
    .mapScrollPtr       (mapScrollPtr       ),
    .mapBackgroundCnt   (mapBackgroundCnt   ),
    .scrollingFlag      (scrollingFlag      ),
    //to nameTableRam.v
    .writeNameEn        (writeNameEn        ),
    .writeNameAddr      (writeNameAddr      ),
    .writeNameData      (writeNameData      ),
    .writeAttrEn        (writeAttrEn        ),
    .writeAttrAddr      (writeAttrAddr      ),
    .writeAttrData      (writeAttrData      ),
    //SPI
    .SPI_CLK            (SPI_CLK            ),
    .SPI_CS             (SPI_CS             ),
    .SPI_MOSI           (SPI_MOSI           ),
    .SPI_MISO           (SPI_MISO           ),
    //vga帧率中断
    .vgaIntr            (vgaIntr            ),
    //to backTileDraw.v
    .scrollPtrOut       (scrollPtrOut       )
);

wire    [`NAMETABLE_AHBBUS_ADDRWIDTH-1:0]   nameTableRamIndex   ;
wire    [31:0]                              nameTableRamDataO   ;
wire    [08:0]                              attributeAddr       ;
wire    [4*(`BYTE)-1:0]                     attributeTableDataO ;

nameTableRam u_nameTableRam(
    //cortex-m0
    .clk(clk_50MHz),
    .addra(BRAM_WRADDR),
    .addrb(BRAM_RDADDR),
    .dina(BRAM_WDATA),
    .wea(BRAM_WRITE),
    .doutb(BRAM_RDATA),
    //from scrollCtrl
    .clk_flashToNametable   (clk_100MHz     ),//100MHz
    .writeNameEn            (writeNameEn    ),
    .writeNameAddr          (writeNameAddr  ),
    .writeNameData          (writeNameData  ),
    .writeAttrEn            (writeAttrEn    ),
    .writeAttrAddr          (writeAttrAddr  ),
    .writeAttrData          (writeAttrData  ),
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
    .scrollPtrOut(scrollPtrOut),
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