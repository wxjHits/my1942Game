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

    //例化的64个tileDraw
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex00,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex01,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex02,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex03,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex04,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex05,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex06,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex07,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex08,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex09,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex10,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex11,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex12,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex13,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex14,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex15,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex16,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex17,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex18,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex19,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex20,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex21,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex22,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex23,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex24,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex25,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex26,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex27,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex28,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex29,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex30,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex31,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex32,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex33,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex34,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex35,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex36,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex37,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex38,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex39,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex40,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex41,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex42,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex43,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex44,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex45,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex46,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex47,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex48,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex49,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex50,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex51,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex52,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex53,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex54,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex55,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex56,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex57,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex58,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex59,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex60,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex61,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex62,
    input   wire    [$clog2(`SPRITE_NUM_MAX)-1:0]   spriteViewRamIndex63,

    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO00,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO01,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO02,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO03,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO04,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO05,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO06,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO07,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO08,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO09,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO10,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO11,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO12,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO13,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO14,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO15,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO16,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO17,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO18,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO19,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO20,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO21,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO22,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO23,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO24,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO25,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO26,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO27,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO28,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO29,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO30,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO31,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO32,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO33,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO34,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO35,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO36,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO37,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO38,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO39,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO40,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO41,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO42,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO43,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO44,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO45,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO46,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO47,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO48,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO49,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO50,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO51,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO52,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO53,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO54,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO55,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO56,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO57,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO58,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO59,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO60,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO61,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO62,
    output  wire    [4*(`BYTE)-1:0]                 spriteViewRamDataO63 
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

    // assign spriteViewRamDataO00 = spriteViewRam[spriteViewRamIndex00];
    // assign spriteViewRamDataO01 = spriteViewRam[spriteViewRamIndex01];
    // assign spriteViewRamDataO02 = spriteViewRam[spriteViewRamIndex02];
    // assign spriteViewRamDataO03 = spriteViewRam[spriteViewRamIndex03];
    // assign spriteViewRamDataO04 = spriteViewRam[spriteViewRamIndex04];
    // assign spriteViewRamDataO05 = spriteViewRam[spriteViewRamIndex05];
    // assign spriteViewRamDataO06 = spriteViewRam[spriteViewRamIndex06];
    // assign spriteViewRamDataO07 = spriteViewRam[spriteViewRamIndex07];
    // assign spriteViewRamDataO08 = spriteViewRam[spriteViewRamIndex08];
    // assign spriteViewRamDataO09 = spriteViewRam[spriteViewRamIndex09];
    // assign spriteViewRamDataO10 = spriteViewRam[spriteViewRamIndex10];
    // assign spriteViewRamDataO11 = spriteViewRam[spriteViewRamIndex11];
    // assign spriteViewRamDataO12 = spriteViewRam[spriteViewRamIndex12];
    // assign spriteViewRamDataO13 = spriteViewRam[spriteViewRamIndex13];
    // assign spriteViewRamDataO14 = spriteViewRam[spriteViewRamIndex14];
    // assign spriteViewRamDataO15 = spriteViewRam[spriteViewRamIndex15];
    // assign spriteViewRamDataO16 = spriteViewRam[spriteViewRamIndex16];
    // assign spriteViewRamDataO17 = spriteViewRam[spriteViewRamIndex17];
    // assign spriteViewRamDataO18 = spriteViewRam[spriteViewRamIndex18];
    // assign spriteViewRamDataO19 = spriteViewRam[spriteViewRamIndex19];
    // assign spriteViewRamDataO20 = spriteViewRam[spriteViewRamIndex20];
    // assign spriteViewRamDataO21 = spriteViewRam[spriteViewRamIndex21];
    // assign spriteViewRamDataO22 = spriteViewRam[spriteViewRamIndex22];
    // assign spriteViewRamDataO23 = spriteViewRam[spriteViewRamIndex23];
    // assign spriteViewRamDataO24 = spriteViewRam[spriteViewRamIndex24];
    // assign spriteViewRamDataO25 = spriteViewRam[spriteViewRamIndex25];
    // assign spriteViewRamDataO26 = spriteViewRam[spriteViewRamIndex26];
    // assign spriteViewRamDataO27 = spriteViewRam[spriteViewRamIndex27];
    // assign spriteViewRamDataO28 = spriteViewRam[spriteViewRamIndex28];
    // assign spriteViewRamDataO29 = spriteViewRam[spriteViewRamIndex29];
    // assign spriteViewRamDataO30 = spriteViewRam[spriteViewRamIndex30];
    // assign spriteViewRamDataO31 = spriteViewRam[spriteViewRamIndex31];
    // assign spriteViewRamDataO32 = spriteViewRam[spriteViewRamIndex32];
    // assign spriteViewRamDataO33 = spriteViewRam[spriteViewRamIndex33];
    // assign spriteViewRamDataO34 = spriteViewRam[spriteViewRamIndex34];
    // assign spriteViewRamDataO35 = spriteViewRam[spriteViewRamIndex35];
    // assign spriteViewRamDataO36 = spriteViewRam[spriteViewRamIndex36];
    // assign spriteViewRamDataO37 = spriteViewRam[spriteViewRamIndex37];
    // assign spriteViewRamDataO38 = spriteViewRam[spriteViewRamIndex38];
    // assign spriteViewRamDataO39 = spriteViewRam[spriteViewRamIndex39];
    // assign spriteViewRamDataO40 = spriteViewRam[spriteViewRamIndex40];
    // assign spriteViewRamDataO41 = spriteViewRam[spriteViewRamIndex41];
    // assign spriteViewRamDataO42 = spriteViewRam[spriteViewRamIndex42];
    // assign spriteViewRamDataO43 = spriteViewRam[spriteViewRamIndex43];
    // assign spriteViewRamDataO44 = spriteViewRam[spriteViewRamIndex44];
    // assign spriteViewRamDataO45 = spriteViewRam[spriteViewRamIndex45];
    // assign spriteViewRamDataO46 = spriteViewRam[spriteViewRamIndex46];
    // assign spriteViewRamDataO47 = spriteViewRam[spriteViewRamIndex47];
    // assign spriteViewRamDataO48 = spriteViewRam[spriteViewRamIndex48];
    // assign spriteViewRamDataO49 = spriteViewRam[spriteViewRamIndex49];
    // assign spriteViewRamDataO50 = spriteViewRam[spriteViewRamIndex50];
    // assign spriteViewRamDataO51 = spriteViewRam[spriteViewRamIndex51];
    // assign spriteViewRamDataO52 = spriteViewRam[spriteViewRamIndex52];
    // assign spriteViewRamDataO53 = spriteViewRam[spriteViewRamIndex53];
    // assign spriteViewRamDataO54 = spriteViewRam[spriteViewRamIndex54];
    // assign spriteViewRamDataO55 = spriteViewRam[spriteViewRamIndex55];
    // assign spriteViewRamDataO56 = spriteViewRam[spriteViewRamIndex56];
    // assign spriteViewRamDataO57 = spriteViewRam[spriteViewRamIndex57];
    // assign spriteViewRamDataO58 = spriteViewRam[spriteViewRamIndex58];
    // assign spriteViewRamDataO59 = spriteViewRam[spriteViewRamIndex59];
    // assign spriteViewRamDataO60 = spriteViewRam[spriteViewRamIndex60];
    // assign spriteViewRamDataO61 = spriteViewRam[spriteViewRamIndex61];
    // assign spriteViewRamDataO62 = spriteViewRam[spriteViewRamIndex62];
    // assign spriteViewRamDataO63 = spriteViewRam[spriteViewRamIndex63];
    
    assign spriteViewRamDataO00 = spriteViewRam[00];
    assign spriteViewRamDataO01 = spriteViewRam[01];
    assign spriteViewRamDataO02 = spriteViewRam[02];
    assign spriteViewRamDataO03 = spriteViewRam[03];
    assign spriteViewRamDataO04 = spriteViewRam[04];
    assign spriteViewRamDataO05 = spriteViewRam[05];
    assign spriteViewRamDataO06 = spriteViewRam[06];
    assign spriteViewRamDataO07 = spriteViewRam[07];
    assign spriteViewRamDataO08 = spriteViewRam[08];
    assign spriteViewRamDataO09 = spriteViewRam[09];
    assign spriteViewRamDataO10 = spriteViewRam[10];
    assign spriteViewRamDataO11 = spriteViewRam[11];
    assign spriteViewRamDataO12 = spriteViewRam[12];
    assign spriteViewRamDataO13 = spriteViewRam[13];
    assign spriteViewRamDataO14 = spriteViewRam[14];
    assign spriteViewRamDataO15 = spriteViewRam[15];
    assign spriteViewRamDataO16 = spriteViewRam[16];
    assign spriteViewRamDataO17 = spriteViewRam[17];
    assign spriteViewRamDataO18 = spriteViewRam[18];
    assign spriteViewRamDataO19 = spriteViewRam[19];
    assign spriteViewRamDataO20 = spriteViewRam[20];
    assign spriteViewRamDataO21 = spriteViewRam[21];
    assign spriteViewRamDataO22 = spriteViewRam[22];
    assign spriteViewRamDataO23 = spriteViewRam[23];
    assign spriteViewRamDataO24 = spriteViewRam[24];
    assign spriteViewRamDataO25 = spriteViewRam[25];
    assign spriteViewRamDataO26 = spriteViewRam[26];
    assign spriteViewRamDataO27 = spriteViewRam[27];
    assign spriteViewRamDataO28 = spriteViewRam[28];
    assign spriteViewRamDataO29 = spriteViewRam[29];
    assign spriteViewRamDataO30 = spriteViewRam[30];
    assign spriteViewRamDataO31 = spriteViewRam[31];
    assign spriteViewRamDataO32 = spriteViewRam[32];
    assign spriteViewRamDataO33 = spriteViewRam[33];
    assign spriteViewRamDataO34 = spriteViewRam[34];
    assign spriteViewRamDataO35 = spriteViewRam[35];
    assign spriteViewRamDataO36 = spriteViewRam[36];
    assign spriteViewRamDataO37 = spriteViewRam[37];
    assign spriteViewRamDataO38 = spriteViewRam[38];
    assign spriteViewRamDataO39 = spriteViewRam[39];
    assign spriteViewRamDataO40 = spriteViewRam[40];
    assign spriteViewRamDataO41 = spriteViewRam[41];
    assign spriteViewRamDataO42 = spriteViewRam[42];
    assign spriteViewRamDataO43 = spriteViewRam[43];
    assign spriteViewRamDataO44 = spriteViewRam[44];
    assign spriteViewRamDataO45 = spriteViewRam[45];
    assign spriteViewRamDataO46 = spriteViewRam[46];
    assign spriteViewRamDataO47 = spriteViewRam[47];
    assign spriteViewRamDataO48 = spriteViewRam[48];
    assign spriteViewRamDataO49 = spriteViewRam[49];
    assign spriteViewRamDataO50 = spriteViewRam[50];
    assign spriteViewRamDataO51 = spriteViewRam[51];
    assign spriteViewRamDataO52 = spriteViewRam[52];
    assign spriteViewRamDataO53 = spriteViewRam[53];
    assign spriteViewRamDataO54 = spriteViewRam[54];
    assign spriteViewRamDataO55 = spriteViewRam[55];
    assign spriteViewRamDataO56 = spriteViewRam[56];
    assign spriteViewRamDataO57 = spriteViewRam[57];
    assign spriteViewRamDataO58 = spriteViewRam[58];
    assign spriteViewRamDataO59 = spriteViewRam[59];
    assign spriteViewRamDataO60 = spriteViewRam[60];
    assign spriteViewRamDataO61 = spriteViewRam[61];
    assign spriteViewRamDataO62 = spriteViewRam[62];
    assign spriteViewRamDataO63 = spriteViewRam[63];
endmodule