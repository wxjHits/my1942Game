#ifndef GAMESTRUCT_H
#define GAMESTRUCT_H

#include <stdint.h>
#include <stdbool.h>

#define GAME_WIDTH 256
#define GAME_HEIGHT 240
#define TOP_LINE 10 //敌机越界检测，超过这些边界后，敌机消失
#define BOTTOM_LINE 230
#define LEFT_LINE 5
#define RIGHT_LINE (GAME_WIDTH-LEFT_LINE)
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
    uint32_t map [30];
}hitMapType;

typedef struct{
    volatile int16_t PosX;
    volatile int16_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
    volatile uint8_t bulletOnceNum;//一次发射子弹的形态 0：一颗 1：两颗 2：三颗

    volatile uint8_t actFlag;//飞机躲避子弹的动画，该过程中飞机不进行碰撞检测
    volatile uint8_t actFpsCnt;//飞机躲避动画时的帧率设置
    volatile uint8_t attitude;//飞机动画姿态的计数
}MYPLANEType;

typedef struct{
    volatile int16_t PosX;
    volatile int16_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器
    volatile int16_t PosX_ADD;//只是针对于敌方子弹的发出时的初始化方向
    volatile int16_t PosY_ADD;//只是针对于敌方子弹的发出时的初始化方向
}BULLETType;

/****敌机类型定义*****/
#define S_GREY_FPSMAX 2
typedef struct{
    volatile uint8_t liveFlag;
    volatile uint8_t hp;//恒定值为1
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器
    volatile int16_t PosX;
    volatile int16_t PosY;
    volatile uint8_t shootFlag;//敌机会发射子弹
    volatile uint8_t isBack;//0:不返回 1：返回
    volatile uint8_t route;//0:第一段 1：动画过程 2：第二段 类似于状态机的第几段
    volatile uint8_t routeOneDir;//第一段的方向 0：右下 1：下 ：2左下 由产生该飞机时与我方飞机的相对位置决定
    volatile int8_t routeOneDir_AddX;//第一段路径的增量
    volatile int8_t routeOneDir_AddY;//第一段路径的增量
    volatile uint8_t routeTwoDir;//第二段的方向 由在转择点位置与我方飞机的相对位置决定
    volatile uint8_t actDraw;//动作过程绘制的类型
}S_GREY_PLANEType;

#define S_GREEN_FPSMAX 1
typedef struct{
    volatile uint8_t liveFlag;
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器
    volatile int16_t PosX;
    volatile int16_t PosY;
    // volatile uint8_t shootFlag;//敌机会发射子弹

    volatile uint8_t route;//0:第一段 1：第二段 进入状态机 第二段：退出状态机
    volatile int8_t routeOneDir_AddX;//第一段路径的增量
    volatile int8_t routeOneDir_AddY;//第一段路径的增量
    volatile uint8_t routeTwoState;//第二段的状态机：0~7 转折由我方飞机决定
    volatile int16_t turnPoint_0;//状态机器的几个转择点
    volatile int16_t turnPoint_1;
    volatile int16_t turnPoint_2;
    volatile int16_t turnPoint_3;
    volatile int16_t turnPoint_4;
    volatile int16_t turnPoint_5;
    volatile int16_t turnPoint_6;
    volatile int16_t turnPoint_7;
    // volatile int16_t routeThreeDir;
    volatile uint8_t actDraw;//动作过程绘制的类型
}S_GREEN_PLANEType;

#define M_STRAIGHT_FPSMAX 2
typedef struct{
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器
    volatile int16_t PosX;
    volatile int16_t PosY;
    // volatile uint8_t shootFlag;//敌机会发射子弹
    volatile int8_t route_AddY;//第一段路径的增量
    volatile uint8_t typeDraw;//飞机类型
    volatile uint8_t Color;//飞机色彩
}M_STRAIGHT_PLANEType;

#define B_GREEN_FPSMAX 2
typedef struct{
    volatile uint8_t liveFlag;
    volatile uint8_t hp;
    volatile uint8_t FpsCnt;//用于敌机的数据更新的计数器
    volatile int16_t PosX;
    volatile int16_t PosY;
    volatile uint8_t route;//第一段，直飞入场；第二段，画面上半部分徘徊（为平行四边形）；第三段退场
    volatile uint8_t route1_state;//第二段徘徊状态的状态，0，1，2，3
    volatile uint8_t route1_allStateCnt;//第二段徘徊状态圈数计数器，转3圈后退出（如果没有被击毁）
    volatile int16_t route0_AddY;//第一段路径的增量,进入画面
    volatile int16_t route1_turnY_0;
    volatile int16_t route1_turnY_1;
    volatile int16_t route1_turnX_0;
    volatile int16_t route1_turnX_1;
    volatile int16_t route1_turnX_2;
    volatile int16_t route1_turnX_3;
}B_GREEN_PLANEType;

typedef struct{
    volatile int16_t PosX;
    volatile int16_t PosY;
    volatile uint8_t liveFlag;
    volatile uint8_t BoomCnt;//爆炸一共有四帧
    volatile uint8_t FpsCnt;//一帧持续多长时间（以整个程序运行一个周期为单位）
}BOOMType;

#endif

