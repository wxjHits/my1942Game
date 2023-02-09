/*
    weixuejing 2023.02.06
    description:
        用于存储64个精灵的属性值，一个精灵4byte
        byte3:横坐标posX
        byte2:纵坐标posY
        byte1:对应的sprinteTileRom的索引值Index
        byte0:
            [7]:hFilp上下翻转选择 0/1
            [6]:vFilp左右反转选择 0/1
            [5:4]:PaletteChoice调色板的选择
            [3]:isBackgroud是否处于背景之上
*/


`include "define.v"
module spriteRam(
    //cortex-m0
    input clk,
    input [$clog2(`SPRITE_NUM_MAX)-1:0] addra,
    input [$clog2(`SPRITE_NUM_MAX)-1:0] addrb,
    input [31:0] dina,
    input [3:0] wea,
    output reg [31:0] doutb,

    //hitCheck.v
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   hitCheck_spriteViewRamIndex,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO_hitCheck,

    //tileDraw
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex00,   //tile的索引值
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex01,   //tile的索引值
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex02,   //tile的索引值
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex03,   //tile的索引值
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex04,   //tile的索引值
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex05,   //tile的索引值
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO00,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO01,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO02,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO03,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO04,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO05
);
    /*****64个精灵RAM的初始化*****/
    //(* ram_style="block" *)
    reg  [4*(`BYTE)-1:0] spriteViewRam [0:`SPRITE_NUM_MAX-1];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my_1942/spriteViewRam.txt", spriteViewRam);
	end

/*与CPU M0软核的交互*/
    always@(posedge clk) begin
        if(wea[0]) spriteViewRam[addra][7:0] <= dina[7:0];
    end
    always@(posedge clk) begin
        if(wea[1]) spriteViewRam[addra][15:8] <= dina[15:8];
    end
    always@(posedge clk) begin
        if(wea[2]) spriteViewRam[addra][23:16] <= dina[23:16];
    end
    always@(posedge clk) begin
        if(wea[3]) spriteViewRam[addra][31:24] <= dina[31:24];
    end

    always@(posedge clk) begin
        doutb <= spriteViewRam[addrb];
    end

/*与其他PPU模块的交互*/
    assign spriteViewRamDataO_hitCheck = spriteViewRam[hitCheck_spriteViewRamIndex];

    assign spriteViewRamDataO00 = spriteViewRam[spriteViewRamIndex00];
    assign spriteViewRamDataO01 = spriteViewRam[spriteViewRamIndex01];
    assign spriteViewRamDataO02 = spriteViewRam[spriteViewRamIndex02];
    assign spriteViewRamDataO03 = spriteViewRam[spriteViewRamIndex03];
    assign spriteViewRamDataO04 = spriteViewRam[spriteViewRamIndex04];
    assign spriteViewRamDataO05 = spriteViewRam[spriteViewRamIndex05];

endmodule