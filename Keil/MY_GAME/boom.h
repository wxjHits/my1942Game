#ifndef BOOM_H
#define BOOM_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"

#define BOOM_FPS_MAX 10//爆炸每x帧刷新
void new_boomInit(BOOMType* boom);
void new_createOneBoom(int16_t PosX,int16_t PosY,BOOMType* boom);
void new_updateBoomData(BOOMType* boom);
void new_boomDraw(BOOMType* boom,uint8_t* spriteRamAddr);

#endif