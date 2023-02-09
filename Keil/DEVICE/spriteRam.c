#include "spriteRam.h"

void writeOneSprite(uint8_t num,uint8_t PosX,uint8_t PosY,uint8_t tileIndex,uint8_t byte0){
    uint32_t data;
    data = PosX<<24|PosY<<16|tileIndex<<8|byte0;
    SPRITERAM->SPRITERAM_VALUE[num]=data;
}

void myPlaneDraw(uint8_t PosX,uint8_t PosY){
    writeOneSprite(0,PosX,PosY,10,0x10);
    writeOneSprite(1,PosX+8,PosY,11,0x10);
    writeOneSprite(2,PosX+16,PosY,10,0x50);
    writeOneSprite(3,PosX+4,PosY+8,12,0x10);
    writeOneSprite(4,PosX+12,PosY+8,13,0x10);
}

void boomDraw(uint8_t PosX,uint8_t PosY){
    writeOneSprite(0,PosX,PosY,19,0x10);
    writeOneSprite(1,PosX+8,PosY,20,0x10);
    writeOneSprite(2,PosX,PosY+8,20,0xD0);
    writeOneSprite(3,PosX+8,PosY+8,19,0xD0);
}