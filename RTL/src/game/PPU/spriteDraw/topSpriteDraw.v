`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"

module topSpriteDraw#(
    parameter ADDR_WIDTH = 6 //精灵数量只有64个
)(
    input   wire            clk_50MHz   ,
    input   wire            clk_100MHz  ,
    input   wire            clk_25p2MHz ,
    input   wire            rstn        ,
    
    //CPU AHB interface 对spriteRam进行写操作
    input  wire             SPRITE_HCLK         ,    //50MHz
    input  wire             SPRITE_HRESETn      , 
    input  wire             SPRITE_HSEL         ,    
    input  wire   [31:0]    SPRITE_HADDR        ,   
    input  wire   [01:0]    SPRITE_HTRANS       ,  
    input  wire   [02:0]    SPRITE_HSIZE        ,   
    input  wire   [03:0]    SPRITE_HPROT        ,   
    input  wire             SPRITE_HWRITE       ,  
    input  wire   [31:0]    SPRITE_HWDATA       ,   
    input  wire             SPRITE_HREADY       , 
    output wire             SPRITE_HREADYOUT    , 
    output wire   [31:0]    SPRITE_HRDATA       ,  
    output wire   [01:0]    SPRITE_HRESP        ,

    input  wire             IsGameWindow        ,
    //from VGA_driver
    input  wire  [`VGA_POSXY_BIT-1:0] vgaPosX   ,
    input  wire  [`VGA_POSXY_BIT-1:0] vgaPosY   ,

    // output wire  [`RGB_BIT-1:0]       spriteVgaRgbOut
    // input  wire [`RGB_BIT-1:0] backGroundVgaRgbOut,
    output reg  [`RGB_BIT-1:0]       spriteVgaRgbOut
);

    wire    [ADDR_WIDTH-1:0]    BRAM_RDADDR ;
    wire    [ADDR_WIDTH-1:0]    BRAM_WRADDR ;
    wire    [31:0]              BRAM_RDATA  ;
    wire    [31:0]              BRAM_WDATA  ;
    wire    [3:0]               BRAM_WRITE  ;

    wire [$clog2(`SPRITE_NUM_MAX)-1:0] addrReadEightRam;
    wire [31:0] dataToEightRam;

    wire    [4*(`BYTE)-1:0]                 dataToTileDraw      [0:8-1] ;
    wire    [`SPRITE_TILEROM_ADDRBIT-1:0]   tileIndex           [0:8-1] ;
    wire    [`SPRITE_TILEDATA_BIT-1:0]      tileDataI           [0:8-1] ;
    wire    [8-1:0]           IsScanRange                               ;
    wire    [7:0]                           vgaIsZeroFlag               ;
    wire    [`RGB_BIT-1:0]                  vgaRgbOut           [0:8-1] ;

    //
    // assign spriteVgaRgbOut =  IsScanRange[0] ? vgaRgbOut[0]:(
    //                                             IsScanRange[1] ? vgaRgbOut[1]:(
    //                                             IsScanRange[2] ? vgaRgbOut[2]:(
    //                                             IsScanRange[3] ? vgaRgbOut[3]:(
    //                                             IsScanRange[4] ? vgaRgbOut[4]:(
    //                                             IsScanRange[5] ? vgaRgbOut[5]:(
    //                                             IsScanRange[6] ? vgaRgbOut[6]:vgaRgbOut[7]))))));

    // always @(*) begin //闪屏问题的解决2023.03.10
    //     casex (IsScanRange)//要用casex
    //         8'bxxxx_xxx1: spriteVgaRgbOut=vgaRgbOut[0];
    //         8'bxxxx_xx10: spriteVgaRgbOut=vgaRgbOut[1];
    //         8'bxxxx_x100: spriteVgaRgbOut=vgaRgbOut[2];
    //         8'bxxxx_1000: spriteVgaRgbOut=vgaRgbOut[3];
    //         8'bxxx1_0000: spriteVgaRgbOut=vgaRgbOut[4];
    //         8'bxx10_0000: spriteVgaRgbOut=vgaRgbOut[5];
    //         8'bx100_0000: spriteVgaRgbOut=vgaRgbOut[6];
    //         8'b1000_0000: spriteVgaRgbOut=vgaRgbOut[7];
    //         default:spriteVgaRgbOut=0;
    //     endcase
    // end
    
    always @(*) begin //闪屏问题的解决2023.03.10
        casex (IsScanRange&(~vgaIsZeroFlag))//要用casex,多个精灵重叠时以最小编号的精灵色彩显示,2023.04.15
            8'bxxxx_xxx1: spriteVgaRgbOut=vgaRgbOut[0];
            8'bxxxx_xx10: spriteVgaRgbOut=vgaRgbOut[1];
            8'bxxxx_x100: spriteVgaRgbOut=vgaRgbOut[2];
            8'bxxxx_1000: spriteVgaRgbOut=vgaRgbOut[3];
            8'bxxx1_0000: spriteVgaRgbOut=vgaRgbOut[4];
            8'bxx10_0000: spriteVgaRgbOut=vgaRgbOut[5];
            8'bx100_0000: spriteVgaRgbOut=vgaRgbOut[6];
            8'b1000_0000: spriteVgaRgbOut=vgaRgbOut[7];
            default:spriteVgaRgbOut=0;
        endcase
    end

    genvar  i;
    generate
        for(i=0;i<8;i=i+1)begin:tiltDraw_inst
            tileDraw u_tileDraw(
                .clk                    (clk_100MHz             ),//用于计算的时钟必须大于VGA的扫描时钟，这样计算过程可以多个时钟周期
                .rstn                   (rstn                  ),
                .vgaPosX                (vgaPosX                ),
                .vgaPosY                (vgaPosY                ),
                .spriteViewRamDataO     (dataToTileDraw[i]      ),
                .tileIndex              (tileIndex[i]           ),
                .tileDataI              (tileDataI[i]           ),
                .IsScanRange            (IsScanRange[i]         ),
                // .backgroundVgaRgbIn     (backgroundVgaRgbIn     ),
                .vgaIsZeroFlag          (vgaIsZeroFlag[i]       ),
                .vgaRgbOut              (vgaRgbOut[i]           )
            );
        end
    endgenerate



ahb_spriteRam_interface ahb_spriteRam_interface_inst(
    .HCLK       (SPRITE_HCLK        ),
    .HRESETn    (SPRITE_HRESETn     ),
    .HSEL       (SPRITE_HSEL        ),
    .HADDR      (SPRITE_HADDR       ),
    .HTRANS     (SPRITE_HTRANS      ),
    .HSIZE      (SPRITE_HSIZE       ),
    .HPROT      (SPRITE_HPROT       ),
    .HWRITE     (SPRITE_HWRITE      ),
    .HWDATA     (SPRITE_HWDATA      ),
    .HREADY     (SPRITE_HREADY      ),
    .HREADYOUT  (SPRITE_HREADYOUT   ),
    .HRDATA     (SPRITE_HRDATA      ),
    .HRESP      (SPRITE_HRESP       ),
    .BRAM_RDADDR(BRAM_RDADDR        ),
    .BRAM_WRADDR(BRAM_WRADDR        ),
    .BRAM_RDATA (BRAM_RDATA         ),
    .BRAM_WDATA (BRAM_WDATA         ),
    .BRAM_WRITE (BRAM_WRITE         ) 
);


spriteRam spriteRam_inst(
    .clk    (clk_50MHz),
    .addra  (BRAM_WRADDR),
    .addrb  (BRAM_RDADDR),
    .dina   (BRAM_WDATA),
    .doutb  (BRAM_RDATA),
    .wea    (BRAM_WRITE),
    //eightRam
    .clkEightRam(clk_100MHz),
    .addrReadEightRam(addrReadEightRam),
    .dataToEightRam(dataToEightRam)
);

eightRam eightRam_inst(
    .clkEightRam(clk_100MHz),
    .rstn(rstn),

    .vgaPosY(vgaPosY),//当前行
    //spriteRam
    .addrReadEightRam(addrReadEightRam),
    .dataToEightRam(dataToEightRam),

    //8个tiledraw模块
    .dataToTileDraw00(dataToTileDraw[00]),
    .dataToTileDraw01(dataToTileDraw[01]),
    .dataToTileDraw02(dataToTileDraw[02]),
    .dataToTileDraw03(dataToTileDraw[03]),
    .dataToTileDraw04(dataToTileDraw[04]),
    .dataToTileDraw05(dataToTileDraw[05]),
    .dataToTileDraw06(dataToTileDraw[06]),
    .dataToTileDraw07(dataToTileDraw[07]),

    .IsGameWindow(IsGameWindow) //当前vga的posX posY是否处于游戏界面
);

spriteTileRom spriteTileRom_inst(
    .clk (clk_100MHz),
    //from tiltDraw.v
    .tileIndex00(tileIndex[00]), //tileçç´˘ĺźĺ??
    .tileIndex01(tileIndex[01]),
    .tileIndex02(tileIndex[02]),
    .tileIndex03(tileIndex[03]),
    .tileIndex04(tileIndex[04]),
    .tileIndex05(tileIndex[05]),
    .tileIndex06(tileIndex[06]),
    .tileIndex07(tileIndex[07]),

    .tileDataO00(tileDataI[00]),
    .tileDataO01(tileDataI[01]),
    .tileDataO02(tileDataI[02]),
    .tileDataO03(tileDataI[03]),
    .tileDataO04(tileDataI[04]),
    .tileDataO05(tileDataI[05]),
    .tileDataO06(tileDataI[06]),
    .tileDataO07(tileDataI[07])
);

endmodule