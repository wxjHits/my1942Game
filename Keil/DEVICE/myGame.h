#ifndef MYGAME_H
#define MYGAME_H

#include <stdint.h>
#include <stdbool.h>
/*
    初始化-->作图-->碰撞检测(更新单位的存在性、计分、爆炸效果)-->路径坐标更新(我方/敌方子弹、敌方飞机的路径)-->越界检测-->作图
*/

#define GAME_WIDTH 256
#define GAME_HEIGHT 240

#define TOP_LINE 10 //敌机越界检测，超过这些边界后，敌机消失
#define BOTTOM_LINE 230
#define LEFT_LINE 5
#define RIGHT_LINE (GAME_WIDTH-LEFT_LINE)

#define CIRCLELOGNTH_MAX 18 //圆形路径数据数组的长度

#define ENEMY_FPS_MAX 2//敌机每x帧刷新坐标

#define BOOM_FPS_MAX 14//爆炸每x帧刷新

#define MYBULLET_SPEED 3 //不要过大

#define SPRITE_RAM_ADDR_START_SCORE 0
#define SPRITE_RAM_ADDR_START_FPS   0+4
#define SPRITE_RAM_ADDR_START_MYPLANE 0+4+4
#define SPRITE_RAM_ADDR_START_BULLET 0+4+4+5
#define SPRITE_RAM_ADDR_START_ENEMYPLANE 20
#define SPRITE_RAM_ADDR_START_BOOM 55

typedef struct{
    volatile uint8_t route0;
    volatile uint8_t turnLine;//针对于两段路线的转折线
    volatile uint8_t route1;
    volatile uint8_t routeCnt;
    volatile uint8_t routeCircleCnt;
}ROUTEType;//路径规划

typedef enum{
    UP=1,
    UP_LEFT,
    UP_RIGHT,
    DOWN,
    DOWN_LEFT,
    DOWN_RIGHT,
    LEFT,
    RIGHT,
    CIRCLE
}ROUTEDIR;

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
    ROUTEType route;
    volatile uint8_t FpsCnt;
}PLANEType;


typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
}BULLETType;

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t BoomCnt;//爆炸一共有三帧
    volatile uint8_t FpsCnt;//一帧持续多长时间（以整个程序运行一个周期为单位）
}BOOMType;

//我方子弹
void bulletInit(void);
void createOneBullet(void);
void updateBulletData(void);

//我方飞机
void myPlaneInit(void);

//敌机
void enmeyPlaneInit(void);
void createOneEnmeyPlane(uint8_t PosX,uint8_t PosY,ROUTEType route);
void moveEnmeyPlane(PLANEType* enmeyPlane);

//爆炸初始化
void boomInit(BOOMType* boom);
void createOneBoom(uint8_t PosX,uint8_t PosY,BOOMType* boom);
void updateBoomData(BOOMType* boom);
//碰撞检测,后续可以将创建bitmask碰撞图和碰撞检测部分采用硬件实现
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

//作图函数,每一次作图均从精灵0开始,精灵存活一个，计数器+1,最大为64
void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score);
void gameFPSDraw(uint32_t fps);
void bulletDraw(void);
void myPlaneDraw(uint8_t PosX,uint8_t PosY);
void enmeyPlaneDraw(void);
void boomDraw(void);

#endif


