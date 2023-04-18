#ifndef GAME_HIT_H
#define GAME_HIT_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"

//创建bitMask hit map 
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap);
void myBulletsMapCreate(BULLETType* myBullet,hitMapType* hitMap);
void enemyAndBulletMapCreate(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,B_GREEN_PLANEType* b_green_enmeyPlane,BULLETType* enmeyBullet,hitMapType* hitMap);

//碰撞检测
void isMyPlaneHit(MYPLANEType* myPlane,hitMapType* enemyPlaneAndBullet_HitMap,BOOMType* boom);
void isHit_s_EnemyPlane(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,hitMapType* hitMap,BOOMType* boom);
void isHit_m_straight_EnemyPlane(M_STRAIGHT_PLANEType* m_straight_enmeyPlane,hitMapType* hitMap,BOOMType* boom);
void isHit_b_EnemyPlane(B_GREEN_PLANEType* b_green_enmeyPlane,hitMapType* hitMap,BOOMType* boom);
void isHit_myBullets(BULLETType* myBullet,hitMapType* enemyPlaneAndBullet_HitMap);

#endif
