#include "spriteRam.h"

void writeOneSprite(uint8_t num,uint8_t PosX,uint8_t PosY,uint8_t tileIndex,uint8_t byte0){
//    uint32_t data;
//    data = PosX<<24|PosY<<16|tileIndex<<8|byte0;
//    SPRITERAM->SPRITERAM_VALUE[num]=data;
    SPRITERAM->SPRITE[num].SPRITE_POSX=PosX;
    SPRITERAM->SPRITE[num].SPRITE_POSY=PosY;
    SPRITERAM->SPRITE[num].SPRITE_TILEINDEX=tileIndex;
    SPRITERAM->SPRITE[num].BYTE0=byte0;
}

/*
    nameTable_X:0~31
    nameTable_Y:0~29
    backgroundTileIndex:0~255
*/

void clearNameTableAll(void){
    for(uint8_t i=0;i<30;i++){
        for(uint8_t j=0;j<32;j++)
            writeOneNametable(j,i,0xFF);
    }
}

void clearNameTableOneline(uint8_t lineNum){
    for(uint8_t j=0;j<32;j++)
        writeOneNametable(j,lineNum,0xFF);
}

void writeOneNametable(uint16_t nameTable_X,uint16_t nameTable_Y,uint8_t backgroundTileIndex){
    NAMETABLE->NAMETABLE_VALUE[nameTable_Y][nameTable_X]=backgroundTileIndex;
}

void nameTablePicture(uint16_t y,uint8_t* array){
        uint16_t x=0;
        for (x = 0; x < 32; x++){
            NAMETABLE->NAMETABLE_VALUE[y][x]=*(array+x);
        }
};

void scroll_Init(uint32_t scrollCntMax,uint32_t flashAddrStart,uint32_t mapBackgroundMax){
    NAMETABLE->scrollCntMax;
}
