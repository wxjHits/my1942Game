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

    //8个暂存 eightRam.v读操作
    input clkEightRam,
    input [$clog2(`SPRITE_NUM_MAX)-1:0] addrReadEightRam,
    output reg [31:0] dataToEightRam
);
    /*****64个精灵RAM的初始化*****/
    (* ram_style="block" *) reg  [4*(`BYTE)-1:0] spriteViewRam [0:`SPRITE_NUM_MAX-1];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/spriteViewRam.txt", spriteViewRam);
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


    always@(posedge clkEightRam) begin
        dataToEightRam <= spriteViewRam[addrReadEightRam];
    end

endmodule