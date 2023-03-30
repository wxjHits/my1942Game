#ifndef ENEMYBULLET_H
#define ENEMYBULLET_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"


void enmey_BulletInit(BULLETType* bullet);
void s_grey_createOneEnmeyBullet(BULLETType* bullet,S_GREY_PLANEType* plane,MYPLANEType* myplane);//敌机发射一次子弹
void updateEnemyBulletData(BULLETType* bullet);
void enmeyBulletDraw(BULLETType* bullet,uint8_t* spriteRamAddr);

#endif