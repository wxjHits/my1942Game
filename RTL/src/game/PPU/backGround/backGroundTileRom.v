/*
    精灵tile的素材库
*/
`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module backGroundTileRom(
    //from backTileDraw.v
    input   wire    [`SPRITE_TILEROM_ADDRBIT-1:0]  backTileIndex,
    output  wire    [`SPRITE_TILEDATA_BIT-1:0]     backTileDataI
);
    (* ram_style="block" *)reg  [`SPRITE_TILEDATA_BIT-1:0] backGroundTileRom [0:`SPRITE_TILEROM_DEEPTH-1];
    initial begin
        $readmemh("C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/ppuDocTxt/game1942BackgroundTile.txt", backGroundTileRom);
    end

    assign backTileDataI = backGroundTileRom[backTileIndex];

endmodule