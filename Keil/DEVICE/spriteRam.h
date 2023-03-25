#ifndef SPRITERAM_H
#define SPRITERAM_H

#include <stdint.h>
#include <stdbool.h>
//SPTITERAM
// BASE_ADDR:0x50010000

//-------------------------------------
#define SPRITERAM_BASE         (0x50010000)
typedef struct{
    volatile uint8_t BYTE0;
    volatile uint8_t SPRITE_TILEINDEX;
    volatile uint8_t SPRITE_POSY;
    volatile uint8_t SPRITE_POSX;
}SPRITEType;


typedef struct{
    volatile SPRITEType SPRITE[64];
}SPRITERAMType;

//typedef struct{
//    volatile uint32_t SPRITERAM_VALUE[64];
//}SPRITERAMType;

#define SPRITERAM ((SPRITERAMType *)SPRITERAM_BASE)

void writeOneSprite(uint8_t num,uint8_t PosX,uint8_t PosY,uint8_t tileIndex,uint8_t byte0);



/********************nameTable************************/
#define NAMETABLE_BASE         (0x50020000)
typedef struct{
    volatile uint8_t NAMETABLE_VALUE[64][32];
}NAMETABLE_Type;

#define NAMETABLE ((NAMETABLE_Type *)NAMETABLE_BASE)

void clearNameTableAll(void);
void clearNameTableOneline(uint8_t lineNum);
void writeOneNametable(uint16_t nameTable_X,uint16_t nameTable_Y,uint8_t backgroundTileIndex);

void nameTablePicture(uint16_t y,uint8_t* array);

#endif

