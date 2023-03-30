#ifndef ENEMYPLANE_H
#define ENEMYPLANE_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"

//灰色小飞机
void s_grey_planeInit(S_GREY_PLANEType* plane);
void s_grey_createOnePlane(S_GREY_PLANEType* plane,S_GREY_PLANEType* planeParameter,int16_t myPlanePosX,int16_t myPlanePosY);
void s_grey_movePlane(S_GREY_PLANEType* plane,MYPLANEType* myPlane,BULLETType* bullet);
void s_grey_drawPlane(S_GREY_PLANEType* plane,uint8_t* spriteRamAddr);

//绿色小飞机
void s_green_planeInit(S_GREEN_PLANEType* plane);
void s_green_createOnePlane(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY);
void s_green_movePlane(S_GREEN_PLANEType* plane,MYPLANEType* myPlane,BULLETType* bullet);
void s_green_drawPlane(S_GREEN_PLANEType* plane,uint8_t* spriteRamAddr);

#endif
