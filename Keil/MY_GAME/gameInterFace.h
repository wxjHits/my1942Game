#ifndef GAME_INTERFACE_H
#define GAME_INTERFACE_H

#include <stdint.h>
#include <stdbool.h>
#include "gameStruct.h"

void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score,uint8_t* spriteRamAddr);

#define GAME_START 0
#define GAME_OTHER 1
typedef struct{
    volatile uint8_t state;//不同state对应不同的PosY
}GAMECURSORType;

void gameStartInterfaceShow(uint8_t x,uint8_t y);
void gameCursorDraw(GAMECURSORType* gameCursor);

//游戏打通一小关后新的一关开始的画面
void newGuanqiaInterFaceDraw(uint8_t guanQiaNum,uint8_t* spriteRamAddr);

//游戏结算画面，文字应该是隔几帧再进行打印（一个一个打印），和初始界面瞬间显示出来不同
#define endInterFaceCharNum 24
void endInterFaceDraw(uint8_t* DrawFlag,uint8_t* arrayCnt,uint32_t score, uint32_t GameShootDownCnt,float GameHitRate);


//最高记录的存储与显示
uint32_t read_GameScoreRecord(void);
void save_GameScoreRecord(uint32_t score);
void show_GameScoreRecord(void);

#endif
