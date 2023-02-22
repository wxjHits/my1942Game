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

#define BOOM_FPS_MAX 10//爆炸每x帧刷新

#define MYBULLET_SPEED 3 //不要过大

#define SPRITE_RAM_ADDR_MAX 64
#define SPRITE_RAM_ADDR_START_SCORE 0
#define SPRITE_RAM_ADDR_START_FPS   0+4
#define SPRITE_RAM_ADDR_START_MYPLANE 0+4+4
#define SPRITE_RAM_ADDR_START_BULLET 0+4+4+5
#define SPRITE_RAM_ADDR_START_ENEMYPLANE 20
#define SPRITE_RAM_ADDR_START_BOOM 55

/****************buff parameter*************************/
//buff tile的位置
#define BUFF_TYPE0_0 0x2C
#define BUFF_TYPE0_1 0x2D
#define BUFF_TYPE0_2 0x2E
#define BUFF_TYPE1_0 0x2F
#define BUFF_TYPE1_1 0x6F
#define BUFF_TYPE1_2 0xEF
//buff type
#define BUFF_POWER 1
#define BUFF_HP  2
//buff fps
#define BUFF_FPS 5

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t buffType;//一次发射子弹的形态 0：绿色，加子弹个数最多一个发射三颗子弹 1：红色加声明
    volatile uint8_t FpsCnt;//buff下降速度
}BUFFType;

typedef struct{
    volatile uint8_t PosX;
    volatile uint8_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
    volatile uint8_t bulletOnceNum;//一次发射子弹的形态 0：一颗 1：两颗 2：三颗
    volatile uint8_t attitude;//飞机姿态
}MYPLANEType;

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
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器

    volatile uint8_t shootFlag;//敌机会发射子弹
    volatile uint8_t bulletOnceNum;//一次发射子弹的形态 0：一颗 1：两颗 2：三颗
    volatile uint8_t type;//对绘图和运动路径都有关系
    volatile uint8_t attitude;//飞机姿态
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
    volatile uint8_t BoomCnt;//爆炸一共有四帧
    volatile uint8_t FpsCnt;//一帧持续多长时间（以整个程序运行一个周期为单位）
}BOOMType;

typedef struct{
    uint32_t map [30];
}hitMapType;

//初始化
void myPlaneInit(void);
void bulletInit(void);
void enmeyPlaneInit(void);
void boomInit(BOOMType* boom);
void buffInit(BUFFType* buff);
//创建单位
void createOneBullet(void);//发射一次子弹
void createOneEnmeyPlane(uint8_t PosX,uint8_t PosY,ROUTEType route);
void createOneBoom(uint8_t PosX,uint8_t PosY,BOOMType* boom);
void createOneBuff(uint8_t PosX,uint8_t PosY,uint8_t buffType,BUFFType* buff);
//单位的数据更新
void updateBulletData(void);
void moveEnmeyPlane(PLANEType* enmeyPlane);
void updateBoomData(BOOMType* boom);
void updateBuffData(BUFFType* buff);
//碰撞检测,后续可以将创建bitmask碰撞图和碰撞检测部分采用硬件实现
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap);
void myPlaneMapCreate(MYPLANEType* myPlane,hitMapType* hitMap);
void bulletsMapCreate(BULLETType* bullet,hitMapType* hitMap);
void enemyMapCreate(PLANEType* enmeyPlane,hitMapType* hitMap);
void isMyPlaneHit(MYPLANEType* myPlane,hitMapType* enemyPlaneHitMap,BUFFType* buff,hitMapType* myPlaneHitMap);
void isEnemyPlaneHit(PLANEType* enmeyPlane,hitMapType hitMap);
void isBulletsHit(BULLETType* bullet,hitMapType hitMap);

//作图函数,每一次作图均从精灵0开始,精灵存活一个，计数器+1,最大为64
void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score,uint8_t* spriteRamAddr);
void gameFPSDraw(uint32_t fps,uint8_t* spriteRamAddr);
void myPlaneDraw(uint8_t PosX,uint8_t PosY,uint8_t* spriteRamAddr);
void bulletDraw(uint8_t* spriteRamAddr);
void enmeyPlaneDraw(uint8_t* spriteRamAddr);
void boomDraw(uint8_t* spriteRamAddr);
void buffDraw(uint8_t* spriteRamAddr);

#endif


