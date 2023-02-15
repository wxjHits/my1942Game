#ifndef MYGAME_H
#define MYGAME_H

#include <stdint.h>
#include <stdbool.h>

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
}PLANEType;

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
}BULLETType;


//我方子弹
void bulletInit(void);
void createOneBullet(void);
void updateBulletData(void);
void bulletDraw(void);

//我方飞机
void myPlaneInit(void);
void myPlaneDraw(uint8_t PosX,uint8_t PosY);

//敌机
void enmeyPlaneInit(void);
void createOneEnmeyPlane(uint8_t PosX,uint8_t PosY);
void enmeyPlaneDraw(void);

//碰撞检测
typedef struct{
    uint32_t map [30];
}hitMapType;
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap);
void myPlaneMapCreate(uint8_t PosX,uint8_t PosY,hitMapType* hitMap);
void bulletsMapCreate(BULLETType* bullet,hitMapType* hitMap);
void enemyMapCreate(PLANEType* enmeyPlane,hitMapType* hitMap);
bool isMyPlaneHit(PLANEType* myPlane,hitMapType* hitMap);
void isEnemyPlaneHit(PLANEType* enmeyPlane,hitMapType hitMap);
void isBulletsHit(BULLETType* bullet,hitMapType hitMap);

void boomDraw(uint8_t PosX,uint8_t PosY);

void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score);

#endif