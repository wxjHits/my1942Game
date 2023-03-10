
`include "define.v"
module topPPU#(
    parameter ADDR_WIDTH = 6 //精灵数量只有64个
)(
    input   wire            clk_50MHz   ,
    input   wire            clk_100MHz  ,
    input   wire            clk_25p2MHz ,
    input   wire            rstn        ,
    
    //CPU AHB interface 对spriteRam进行写操作
    input  wire             SPRITE_HCLK         ,
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
    //CPU AHB interface 对nameTable进行写操作
    input  wire             NAMETABLE_HCLK      ,
    input  wire             NAMETABLE_HRESETn   ,
    input  wire             NAMETABLE_HSEL      ,
    input  wire   [31:0]    NAMETABLE_HADDR     ,
    input  wire   [1:0]     NAMETABLE_HTRANS    ,
    input  wire   [2:0]     NAMETABLE_HSIZE     ,
    input  wire   [3:0]     NAMETABLE_HPROT     ,
    input  wire             NAMETABLE_HWRITE    ,
    input  wire   [31:0]    NAMETABLE_HWDATA    ,
    input  wire             NAMETABLE_HREADY    ,
    output wire             NAMETABLE_HREADYOUT ,
    output wire   [31:0]    NAMETABLE_HRDATA    ,
    output wire   [1:0]     NAMETABLE_HRESP     ,

    //中断VGA
    output wire             VGA_Intr            ,

    //VGA PIN
    output  wire            hsync       ,//输出行同步信号
    output  wire            vsync       ,//输出场同步信号
    output  wire    [11:0]  rgb          //输出像素点色彩信息

);

    wire    vga_clk = clk_25p2MHz;

    wire [`VGA_POSXY_BIT-1:0] vgaPosX;
    wire [`VGA_POSXY_BIT-1:0] vgaPosY;

    wire IsGameWindow = (vgaPosX>=`GAME_START_POSX && vgaPosX<`GAME_START_POSX+`GAME_WINDOW_WIDTH ) &&
                        (vgaPosY>=`GAME_START_POSY && vgaPosY<`GAME_START_POSY+`GAME_WINDOW_HEIGHT);

    wire    [`RGB_BIT-1:0]  vgaRgbOut           ;

    //精灵颜色与背景颜色的选择
    reg     [`RGB_BIT-1:0]  vgaRgbSel           ;
    wire    [`RGB_BIT-1:0]  spriteVgaRgbOut     ;
    wire    [`RGB_BIT-1:0]  backGroundVgaRgbOut ;
    always@(*)begin
        if(spriteVgaRgbOut==0)
            vgaRgbSel=backGroundVgaRgbOut;
        else
            vgaRgbSel=spriteVgaRgbOut;
    end
    assign vgaRgbOut = vgaRgbSel;

    topSpriteDraw u_topSpriteDraw(
        .clk_50MHz          (clk_50MHz          ),
        .clk_100MHz         (clk_100MHz         ),
        .clk_25p2MHz        (clk_25p2MHz        ),
        .rstn               (rstn               ),
        //CPU AHB interface 对spriteRam进行写操作
        .SPRITE_HCLK        (SPRITE_HCLK        ),    //50MHz
        .SPRITE_HRESETn     (SPRITE_HRESETn     ), 
        .SPRITE_HSEL        (SPRITE_HSEL        ),    
        .SPRITE_HADDR       (SPRITE_HADDR       ),   
        .SPRITE_HTRANS      (SPRITE_HTRANS      ),  
        .SPRITE_HSIZE       (SPRITE_HSIZE       ),   
        .SPRITE_HPROT       (SPRITE_HPROT       ),   
        .SPRITE_HWRITE      (SPRITE_HWRITE      ),  
        .SPRITE_HWDATA      (SPRITE_HWDATA      ),   
        .SPRITE_HREADY      (SPRITE_HREADY      ), 
        .SPRITE_HREADYOUT   (SPRITE_HREADYOUT   ), 
        .SPRITE_HRDATA      (SPRITE_HRDATA      ),  
        .SPRITE_HRESP       (SPRITE_HRESP       ),

        .IsGameWindow       (IsGameWindow       ),
        .vgaPosX            (vgaPosX            ),
        .vgaPosY            (vgaPosY            ),
        .spriteVgaRgbOut    (spriteVgaRgbOut    )
);

    topBackGroundDraw u_topBackGroundDraw(
        .clk_50MHz          (clk_50MHz          ),
        .clk_100MHz         (clk_100MHz         ),
        .clk_25p2MHz        (clk_25p2MHz        ),
        .rstn               (rstn               ),
        //cpu ahb-lite bus
        .NAMETABLE_HCLK     (NAMETABLE_HCLK     ),
        .NAMETABLE_HRESETn  (NAMETABLE_HRESETn  ),
        .NAMETABLE_HSEL     (NAMETABLE_HSEL     ),
        .NAMETABLE_HADDR    (NAMETABLE_HADDR    ),
        .NAMETABLE_HTRANS   (NAMETABLE_HTRANS   ),
        .NAMETABLE_HSIZE    (NAMETABLE_HSIZE    ),
        .NAMETABLE_HPROT    (NAMETABLE_HPROT    ),
        .NAMETABLE_HWRITE   (NAMETABLE_HWRITE   ),
        .NAMETABLE_HWDATA   (NAMETABLE_HWDATA   ),
        .NAMETABLE_HREADY   (NAMETABLE_HREADY   ),
        .NAMETABLE_HREADYOUT(NAMETABLE_HREADYOUT),
        .NAMETABLE_HRDATA   (NAMETABLE_HRDATA   ),
        .NAMETABLE_HRESP    (NAMETABLE_HRESP    ),
    //from VGA_driver
        .vgaPosX            (vgaPosX            ),
        .vgaPosY            (vgaPosY            ),
        .backGroundVgaRgbOut(backGroundVgaRgbOut)
    );

    vga_driver  u_vga_driver(
        .vga_clk            (vga_clk            ),
        .rstn               (rstn               ),
        .pixdata            (vgaRgbOut          ),
        .pix_x              (vgaPosX            ),
        .pix_y              (vgaPosY            ),
        .IsGameWindow       (IsGameWindow       ),
        .hsync              (hsync              ),
        .vsync              (vsync              ),
        .rgb                (rgb                )
    );

    reg VGA_Intr_r0;
    reg VGA_Intr_r1;
    always@(posedge clk_50MHz)begin
        if(~rstn)begin
            VGA_Intr_r0<=0;
            VGA_Intr_r1<=0;
        end
        else begin
            VGA_Intr_r0<=(vgaPosX==`GAME_START_POSX+`GAME_WINDOW_WIDTH) && (vgaPosY==`GAME_START_POSY+`GAME_WINDOW_HEIGHT);
            VGA_Intr_r1<=VGA_Intr_r0;
        end
    end
    assign VGA_Intr = VGA_Intr_r0 & (~VGA_Intr_r1);
    
endmodule