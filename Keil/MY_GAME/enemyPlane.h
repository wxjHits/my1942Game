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

//绿色/灰色从下到上直飞的中型机
void m_straight_planeInit(M_STRAIGHT_PLANEType* plane);
void m_straight_createOnePlane(M_STRAIGHT_PLANEType* plane,int16_t myPlanePosX);
void m_straight_movePlane(M_STRAIGHT_PLANEType* plane);
void m_straight_drawPlane(M_STRAIGHT_PLANEType* plane,uint8_t* spriteRamAddr);

//绿色大型机
void b_green_planeInit(B_GREEN_PLANEType* plane);
void b_green_createOnePlane(B_GREEN_PLANEType* plane);
void b_green_movePlane(B_GREEN_PLANEType* plane);
void b_green_drawPlane(B_GREEN_PLANEType* plane,uint8_t* spriteRamAddr);

#endif
