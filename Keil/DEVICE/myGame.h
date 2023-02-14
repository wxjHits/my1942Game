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


void bulletInit(void);
void createOneBullet(void);
void updateBulletData(void);
void bulletDraw(void);

void myPlaneInit(void);
void myPlaneDraw(uint8_t PosX,uint8_t PosY);

void enmeyPlaneInit(void);
void createOneEnmeyPlane(void);
void updateEnmeyPlaneData(void);
void enmeyPlaneDraw(void);

void boomDraw(uint8_t PosX,uint8_t PosY);

void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score);

#endif