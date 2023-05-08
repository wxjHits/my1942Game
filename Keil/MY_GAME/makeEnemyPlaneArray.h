#ifndef MAKEENEMYPLANEARRAY_H
#define MAKEENEMYPLANEARRAY_H

#include <stdint.h>
#include <stdbool.h>
#include "enemyPlane.h"

//灰色小飞机
void s_grey_createPlane_111(S_GREY_PLANEType* plane);
void s_grey_createPlane_122(S_GREY_PLANEType* plane);
void s_grey_createPlane_123(S_GREY_PLANEType* plane);
void s_grey_createPlane_144(S_GREY_PLANEType* plane);
void s_grey_createPlane_145(S_GREY_PLANEType* plane);
void s_grey_createPlane_166(S_GREY_PLANEType* plane);
//绿色小飞机
void s_green_createPlane_221(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY);
void s_green_createPlane_222(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY);
void s_green_createPlane_243(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY);

//绿色/灰色从下到上直飞的中型机
void m_straight_createPlane_411(M_STRAIGHT_PLANEType* plane,int16_t myPlanePosX);
void m_straight_createPlane_422(M_STRAIGHT_PLANEType* plane,int16_t myPlanePosX);

//绿色大型机
void b_green_createPlane_511(B_GREEN_PLANEType* plane);

#endif
