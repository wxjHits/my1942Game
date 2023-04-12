#ifndef MYPLANE_H
#define MYPLANE_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"

/****************myPlane action**********************/
#define MYPLANE_ACT_FPSCNT_MAX 10
#define MYPLANE_ACT_ATTITUDE_MAX 7 //飞机动画一共有几帧
//飞机动画对应的tile索引
#define MYPLANE_ACT_0_0 0x33
#define MYPLANE_ACT_0_1 0x34
#define MYPLANE_ACT_0_2 MYPLANE_ACT_0_0
#define MYPLANE_ACT_0_3 0x35
#define MYPLANE_ACT_0_4 0x36
#define MYPLANE_ACT_1_0 0x37
#define MYPLANE_ACT_1_1 0x38
#define MYPLANE_ACT_1_2 MYPLANE_ACT_1_0
#define MYPLANE_ACT_1_3 0x39
#define MYPLANE_ACT_1_4 MYPLANE_ACT_1_3
#define MYPLANE_ACT_2_0 0x3A
#define MYPLANE_ACT_2_1 0x3B
#define MYPLANE_ACT_2_2 MYPLANE_ACT_2_0
#define MYPLANE_ACT_3_0 0x3C
#define MYPLANE_ACT_3_1 0x3D
#define MYPLANE_ACT_3_2 0x3E
#define MYPLANE_ACT_3_3 0x3D
#define MYPLANE_ACT_4_0 0x3F
#define MYPLANE_ACT_4_1 0xF0
#define MYPLANE_ACT_4_2 0xF1
#define MYPLANE_ACT_4_3 0xF2
#define MYPLANE_ACT_4_4 0xF3
#define MYPLANE_ACT_4_5 0xF4
#define MYPLANE_ACT_4_6 0xF5
#define MYPLANE_ACT_5_0 0xF6
#define MYPLANE_ACT_5_1 MYPLANE_ACT_5_0
#define MYPLANE_ACT_5_2 0xF7
#define MYPLANE_ACT_5_3 0xF8
#define MYPLANE_ACT_5_4 MYPLANE_ACT_5_2

#define MYBULLET_SPEED 3 //不要过大

void myPlane_Init(MYPLANEType* myPlane);
void myPlane_createOneBullet(MYPLANEType* myPlane,BULLETType* mybullet);
// void myPlaneMapCreate(MYPLANEType* myPlane,hitMapType* hitMap);
// void isMyPlaneHit(MYPLANEType* myPlane,hitMapType* enemyPlaneHitMap,hitMapType* enmeyBulletsHitMap,BUFFType* buff,hitMapType* myPlaneHitMap);
void myPlane_Draw(MYPLANEType* myPlane,uint8_t* spriteRamAddr);
void myPlane_Act(MYPLANEType* myPlane,uint8_t* start);

void myPlane_bulletInit(BULLETType* mybullet);
void myPlane_updateBulletData(BULLETType* mybullet);
void myPlane_bulletDraw(BULLETType* mybullet,uint8_t* spriteRamAddr);
#endif
