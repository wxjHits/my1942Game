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