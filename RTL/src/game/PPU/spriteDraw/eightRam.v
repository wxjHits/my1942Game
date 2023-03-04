
/*
    当VGA在扫面时，该模块存储一行需要扫描的精灵数据，最多8个，也就是FC游戏中，一行最多扫描8个精灵
*/

`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"

module eightRam(
    input wire clkEightRam,
    input wire rstn,

    input wire [`VGA_POSXY_BIT-1:0] vgaPosY,//当前行
    //spriteRam
    output wire [$clog2(`SPRITE_NUM_MAX)-1:0] addrReadEightRam,
    input wire [31:0] dataToEightRam,

    //8个tiledraw模块
    output wire [31:0] dataToTileDraw00,
    output wire [31:0] dataToTileDraw01,
    output wire [31:0] dataToTileDraw02,
    output wire [31:0] dataToTileDraw03,
    output wire [31:0] dataToTileDraw04,
    output wire [31:0] dataToTileDraw05,
    output wire [31:0] dataToTileDraw06,
    output wire [31:0] dataToTileDraw07,

    input wire IsGameWindow //当前vga的posX posY是否处于游戏界面
);

    reg [2:0] eightRamAddrCnt;
    //检测IsGameWindow的下降沿
    reg IsGameWindowDealy0;
    reg IsGameWindowDealy1;
    reg gameWindowRaiseEdge;
    reg gameWindowDownEdge ;
    always@(posedge clkEightRam)begin
        if(~rstn)begin
            IsGameWindowDealy0<=0;
            IsGameWindowDealy1<=0;
            gameWindowDownEdge<=0;
            gameWindowRaiseEdge<=0;
        end
        else begin
            IsGameWindowDealy0<=IsGameWindow;
            IsGameWindowDealy1<=IsGameWindowDealy0;
            gameWindowRaiseEdge<=(IsGameWindowDealy0) & (~IsGameWindowDealy1);
            gameWindowDownEdge<=(~IsGameWindowDealy0) & (IsGameWindowDealy1);
        end
    end

    // // vgaPosY进行一下时钟同步
    // reg [`VGA_POSXY_BIT-1:0] vgaPosY_r;
    // always@(posedge clkEightRam)begin
    //     if(~rstn)
    //         vgaPosY_r<=0;
    //     else
    //         vgaPosY_r<=vgaPosY;
    // end
    //游戏画面下一行的寄存
    reg  [`VGA_POSXY_BIT-1:0] vgaPosYNext;//当前行
    always@(posedge clkEightRam)begin
        if(~rstn)
            vgaPosYNext<=0;
        else if(gameWindowDownEdge==1'b1)
            vgaPosYNext<=vgaPosY-`GAME_START_POSY+1'b1;
        else
            vgaPosYNext<=vgaPosYNext;
    end

    //read_en标志位
    reg read_en;
    reg [$clog2(`SPRITE_NUM_MAX)-1:0] spriteRamAddrCnt;

    //read_en标志位，使得在游戏画面每一行扫描完成后，spriteRamAddrCnt开始计数，从0~63完成对精灵spriteRam的扫描检测
    always@(posedge clkEightRam)begin
        if(~rstn)
            read_en<=0;
        else if(gameWindowDownEdge==1'b1)
            read_en<=1;
        else if(spriteRamAddrCnt==63||eightRamAddrCnt==7)
            read_en<=0;
        else 
            read_en<=read_en;
    end

    //
    always@(posedge clkEightRam)begin
        if(~rstn)
            spriteRamAddrCnt<=0;
        else if(read_en==1'b1)
            spriteRamAddrCnt<=spriteRamAddrCnt+1'b1;
        else if(gameWindowRaiseEdge==1'b1)
            spriteRamAddrCnt<=0;
        else
            spriteRamAddrCnt<=spriteRamAddrCnt;
    end

    assign addrReadEightRam = spriteRamAddrCnt;
    //对当前扫描的spriteRam[i]的数据y坐标进行判断，是否会出现在vgaPosYNext这一行

    wire [`BYTE-1:0] thisSpriteRamPosY = dataToEightRam[23:16];
    // reg writeEightRamEn;
    // always@(posedge clkEightRam)begin
    //     if(~rstn)
    //         writeEightRamEn<=0;
    //     else if (
    //                 read_en
    //                     &&
    //                 (vgaPosYNext>=thisSpriteRamPosY) && (vgaPosYNext<(thisSpriteRamPosY+8))
    //             )
    //         writeEightRamEn<=1;
    //     else
    //         writeEightRamEn<=0;
    // end

    wire             writeEightRamEn =  read_en?(vgaPosYNext>=thisSpriteRamPosY) && (vgaPosYNext<(thisSpriteRamPosY+8)):1'b0;

/***********************************************************************************/
//ram的读写主体
    //ram写操作
    reg read_enDelay;
    always@(posedge clkEightRam)begin
        if(~rstn)
            read_enDelay<=0;
        else
            read_enDelay<=read_en;
    end

    reg  [4*(`BYTE)-1:0] eightRam [0:7];
    // reg [2:0] eightRamAddrCnt;

    integer i;
    always@(posedge clkEightRam) begin
        if(~rstn) begin
            for (i=0;i<8;i=i+1) begin
                eightRam[i]<=0;
            end
            eightRamAddrCnt<=0;
        end
        else if(read_enDelay)begin
            if(writeEightRamEn)begin
                eightRam[eightRamAddrCnt]<=dataToEightRam;
                eightRamAddrCnt<=eightRamAddrCnt+1'b1;
            end
            else
                eightRamAddrCnt<=eightRamAddrCnt;
        end
        else
            eightRamAddrCnt<=0;
    end

    assign dataToTileDraw00 = eightRam[0];
    assign dataToTileDraw01 = eightRam[1];
    assign dataToTileDraw02 = eightRam[2];
    assign dataToTileDraw03 = eightRam[3];
    assign dataToTileDraw04 = eightRam[4];
    assign dataToTileDraw05 = eightRam[5];
    assign dataToTileDraw06 = eightRam[6];
    assign dataToTileDraw07 = eightRam[7];

endmodule
