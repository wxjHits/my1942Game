`include "define.v"
module spriteTileRom(
    //from tiltDraw.v
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex00,   //tile的索引值
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex01,   //tile的索引值
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex02,   //tile的索引值
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex03,   //tile的索引值
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex04,   //tile的索引值
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  tileIndex05,   //tile的索引值
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO00,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO01,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO02,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO03,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO04,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     tileDataO05
);
    /*****图片素材ROM的初始化*****/
    reg  [`SPRITE_TILEDATA_BIT-1:0] spritemem [0:`SPRITE_TILEROM_DEEPTH-1];
    initial begin
	    $readmemh("C:/Users/hp/Desktop/my_1942/spriteTile.txt", spritemem);
	end

    assign tileDataO00 = spritemem[tileIndex00];
    assign tileDataO01 = spritemem[tileIndex01];
    assign tileDataO02 = spritemem[tileIndex02];
    assign tileDataO03 = spritemem[tileIndex03];
    assign tileDataO04 = spritemem[tileIndex04];
    assign tileDataO05 = spritemem[tileIndex05];

endmodule