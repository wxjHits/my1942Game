#ifndef GAME_INTERFACE
#define GAME_INTERFACE

#include "gameInterFace.h"
void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score,uint8_t* spriteRamAddr){
    uint8_t ge = score%10;
    uint8_t shi = (score/10)%10;
    uint8_t bai = (score/100)%10;
    uint8_t qian = (score/1000)%10;
    writeOneSprite((*spriteRamAddr)+0,PosX,PosY,qian,0x30);
    writeOneSprite((*spriteRamAddr)+1,PosX+8,PosY,bai,0x30);
    writeOneSprite((*spriteRamAddr)+2,PosX+16,PosY,shi,0x30);
    writeOneSprite((*spriteRamAddr)+3,PosX+24,PosY,ge,0x30);
    *spriteRamAddr+=4;
}

/*******************游戏开始界面显示******************************/
uint8_t GAME_LOGO_1942[5][18]={
   0xD1,0xD2,0xD3,0xFF,0xD1,0xDE,0xDF,0xE0,0xFF,0xFF,0xED,0xEE,0xD3,0xFF,0xF8,0xF9,0xF9,0xE0,
   0xD4,0xD5,0xD6,0xFF,0xE1,0xE2,0xE3,0xE4,0xFF,0xEF,0xF0,0xD5,0xD6,0xFF,0xFA,0xFB,0xFC,0xE4,
   0xD7,0xD5,0xD6,0xFF,0xE5,0xE6,0xE7,0xE4,0xFF,0xF1,0xF2,0xD9,0xF3,0xFF,0xFD,0xFE,0xC0,0xC1,
   0xD8,0xD9,0xDA,0xFF,0xE8,0xE9,0xEA,0xEB,0xFF,0xF4,0xF5,0xF6,0xF7,0xFF,0xC2,0xC3,0xC4,0xD0,
   0xDB,0xDC,0xDD,0xFF,0xDB,0xDC,0xDC,0xEC,0xFF,0xFF,0xDB,0xDC,0xDD,0xFF,0xDB,0xDC,0xDC,0xDD
};
uint8_t GAME_VERSION[12]={0x17,0xFF,0x02,0x00,0x02,0x03,0xFF,0x15,0xFF,0x16,0xFF,0x18};
uint8_t GAME_START_CHAR[8]={0x10,0xFF,0x12,0xFF,0x13,0xFF,0x14,0xFF};
uint8_t GAME_STOP_CHAR[8]={0x11,0xFF,0x12,0xFF,0x13,0xFF,0x14,0xFF};

uint8_t endInterFaceArray[20][3]={ 
   32+00,64+00,0x12,//"游"
   32+16,64+00,0x13,//"戏"
   32+32,64+00,0x1B,//"击"
   32+48,64+00,0x1C,//"落"

   32+48+108+00,64+00,0x00,//"qian"
   32+48+108+ 8,64+00,0x00,//"bai"
   32+48+108+16,64+00,0x00,//"shi"
   32+48+108+24,64+00,0x00,//"ge"

   32+00,64+16,0x12,//"游"
   32+16,64+16,0x13,//"戏"
   32+32,64+16,0x1D,//"命"
   32+48,64+16,0x1E,//"中"
   32+64,64+16,0x1F,//"率"

   32+64+96+ 8,64+16,0x00,//"命中率shi"
   32+64+96+16,64+16,0x00,//"命中率ge"
   32+64+96+24,64+16,0x25,//"%"

   110+00,160+00,0x12,//"游"
   110+16,160+00,0x13,//"戏"
   110+32,160+00,0x14,//"结"
   110+48,160+00,0x15,//"束"
};
void gameStartInterfaceShow(uint8_t x,uint8_t y){
    uint8_t x0=x,y0=y;
    for(uint8_t i=0;i<32;i++){//显示 “1942” LOGO
        for(uint8_t j=0;j<30;j++){
            if((i>=x0&&i<x0+18)&&(j>=y0&&j<y0+5))
                writeOneNametable(i,j,GAME_LOGO_1942[j-y0][i-x0]);
        }
    }
    uint8_t x1=x0+6,y1=y0+8;
    for(uint8_t i=0;i<32;i++){//显示“单人游戏”
        for(uint8_t j=0;j<30;j++){
            if((i>=x1&&i<x1+8)&&(j==y1))
                writeOneNametable(i,j,GAME_START_CHAR[i-x1]);
        }
    }
    uint8_t x2=x1,y2=y1+2;
    for(uint8_t i=0;i<32;i++){//显示“双人游戏”
        for(uint8_t j=0;j<30;j++){
            if((i>=x2&&i<x2+8)&&(j==y2))
                writeOneNametable(i,j,GAME_STOP_CHAR[i-x2]);
        }
    }
    uint8_t x3=x1-4,y3=y1+8;
    for(uint8_t i=0;i<32;i++){//显示游戏信息（年份，开发团队）
        for(uint8_t j=0;j<30;j++){
            if((i>=x3&&i<x3+12)&&(j==y3))
                writeOneNametable(i,j,GAME_VERSION[i-x3]);
        }
    }
}

extern GAMECURSORType gameCursor;//游戏的指示光标
void gameCursorDraw(GAMECURSORType* gameCursor){
    uint8_t PosX=84;
    uint8_t PosY=0;
    switch (gameCursor->state)
    {
        case GAME_START:
            PosY=128;
            break;
        case GAME_OTHER:
            PosY=128+16;
            break;
        default:PosY=128;
            break;
    }
    uint8_t num=0x40;
    writeOneSprite(0,PosX+0,PosY+0,0x40,0xA0);
    writeOneSprite(1,PosX+8,PosY+0,0x41,0xA0);
    writeOneSprite(2,PosX+4,PosY+8,0x42,0xA0);
}

/*******************游戏结算界面显示******************************/
/*
    游戏界面显示
    fpsCnt外部传进行来的帧率计数器
    drawSpeed:当drawSpeed==fpsCnt时候fpsCnt=0 arrayCnt+=1;
*/
extern uint8_t endInterFaceArray[endInterFaceCharNum][3];
void endInterFaceDraw(uint8_t* DrawFlag,uint8_t* arrayCnt,uint32_t GameShootDownCnt,float GameHitRate){
    uint8_t ge   = GameShootDownCnt%10;
    uint8_t shi  = (GameShootDownCnt/10)%10;
    uint8_t bai  = (GameShootDownCnt/100)%10;
    uint8_t qian = (GameShootDownCnt/1000)%10;
    endInterFaceArray[4][2]=qian;
    endInterFaceArray[5][2]=bai ;
    endInterFaceArray[6][2]=shi ;
    endInterFaceArray[7][2]=ge  ;

    uint8_t GameHitRate_100 = (uint8_t)(GameHitRate*100);
    ge  = GameHitRate_100%10;
    shi = (GameHitRate_100/10)%10;
    endInterFaceArray[13][2]=shi ;
    endInterFaceArray[14][2]=ge  ;

    if((*DrawFlag==1) && (*arrayCnt<endInterFaceCharNum)){
        writeOneSprite(*arrayCnt,endInterFaceArray[*arrayCnt][0],endInterFaceArray[*arrayCnt][1],endInterFaceArray[*arrayCnt][2],0x00);
        (*arrayCnt)+=1;
        LED_toggle(5);
        *DrawFlag=0;
    }
}
#endif