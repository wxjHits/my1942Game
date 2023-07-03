#ifndef GAME_INTERFACE
#define GAME_INTERFACE

#include "gameInterFace.h"
#include "spriteRam.h"
#include "spi_flash.h"
// #include "backgroundPicture.h"
extern uint8_t saveGameScoreArray[256];
extern uint32_t nowFlashGameScore;
extern uint32_t saveGameScoreAddr;
extern uint8_t nowFlashGameScore_buffer[6];
void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score,uint8_t* spriteRamAddr){
    uint8_t ge = score%10;
    uint8_t shi = (score/10)%10;
    uint8_t bai = (score/100)%10;
    uint8_t qian = (score/1000)%10;
    uint8_t wan = (score/10000)%10;
    uint8_t shiwan = (score/100000)%10;
    writeOneSprite((*spriteRamAddr)+0,PosX+ 0,PosY,shiwan,0x30);
    writeOneSprite((*spriteRamAddr)+1,PosX+ 8,PosY,wan   ,0x30);
    writeOneSprite((*spriteRamAddr)+2,PosX+16,PosY,qian  ,0x30);
    writeOneSprite((*spriteRamAddr)+3,PosX+24,PosY,bai   ,0x30);
    writeOneSprite((*spriteRamAddr)+4,PosX+32,PosY,shi   ,0x30);
    writeOneSprite((*spriteRamAddr)+5,PosX+40,PosY,ge    ,0x30);
    *spriteRamAddr+=6;
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

extern uint8_t map_start[1024];
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

    for(int i=0;i<32;i++){
       for(int j=0;j<32;j++)
          writeOneNametable(j,i,map_start[i*32+j]);
    }
}

extern GAMECURSORType gameCursor;//游戏开始界面的指示光标
void gameCursorDraw(GAMECURSORType* gameCursor){
    uint8_t PosX=80;
    uint8_t PosY=0;
    switch (gameCursor->state)
    {
        case GAME_SELECT_START:
            PosY=128;
            break;
        case GAME_SELECT_PIFU:
            PosY=128+16;
            break;
        case GAME_SELECT_CAOZUO:
            PosY=128+32;
            break;
        default:PosY=128;
            break;
    }
    writeOneSprite(0,PosX+0,PosY+0,0x40,0x80|0x08);
    writeOneSprite(1,PosX+8,PosY+0,0x41,0x80|0x08);
    writeOneSprite(2,PosX+4,PosY+8,0x42,0x80|0x08);
}

/*******************游戏新关卡开始的显示**************************/
void newGuanqiaInterFaceDraw(uint8_t guanQiaNum,uint8_t* spriteRamAddr){
    uint8_t PosX = 120;
    uint8_t PosY = 100;
    writeOneSprite((*spriteRamAddr),  PosX+ 0,    PosY   ,0x0c ,0x20);(*spriteRamAddr)+=1;//"持"
    writeOneSprite((*spriteRamAddr),  PosX+16,    PosY   ,0x0d ,0x20);(*spriteRamAddr)+=1;//"续"

    writeOneSprite((*spriteRamAddr),  PosX- 8,    PosY+16,guanQiaNum ,0x20);(*spriteRamAddr)+=1;//"num",表示第几关
    writeOneSprite((*spriteRamAddr),  PosX+ 8,    PosY+16,0x0e ,0x20);(*spriteRamAddr)+=1;//"关"
    writeOneSprite((*spriteRamAddr),  PosX+24,    PosY+16,0x0f ,0x20);(*spriteRamAddr)+=1;//"卡"

    writeOneSprite((*spriteRamAddr),  PosX+ 0,    PosY+32,0x10 ,0x20);(*spriteRamAddr)+=1;//"准"
    writeOneSprite((*spriteRamAddr),  PosX+16,    PosY+32,0x11 ,0x20);(*spriteRamAddr)+=1;//"备"
}
/*******************游戏结算界面显示******************************/
/*
    游戏界面显示
    fpsCnt外部传进行来的帧率计数器
    drawSpeed:当drawSpeed==fpsCnt时候fpsCnt=0 arrayCnt+=1;
*/
uint8_t endInterFaceArray[24][3]={
    16+32       ,64-16,0x18,//"分"
    16+32+16*2  ,64-16,0x19,//"数"
    16+48+104+ 0,64-16,0x00,//"shiwan"
    16+48+104+ 8,64-16,0x00,//"wan"
    16+48+104+16,64-16,0x00,//"qian"
    16+48+104+24,64-16,0x00,//"bai"
    16+48+104+32,64-16,0x00,//"shi"
    16+48+104+40,64-16,0x00,//"ge"

    16+32           ,64+00,0x1B,//"击"
    16+32+16*2      ,64+00,0x1C,//"落"
    16+48+104+16+ 0 ,64+00,0x00,//"qian"
    16+48+104+16+ 8 ,64+00,0x00,//"bai"
    16+48+104+16+16 ,64+00,0x00,//"shi"
    16+48+104+16+24 ,64+00,0x00,//"ge"

    16+32           ,64+16,0x1D,//"命"
    16+48           ,64+16,0x1E,//"中"
    16+64           ,64+16,0x1F,//"率"
    16+64+104+ 8    ,64+16,0x00,//"命中率shi"
    16+64+104+16    ,64+16,0x00,//"命中率ge"
    16+64+104+24    ,64+16,0x25,//"%"

    110+00,160+00,0x12,//"游"
    110+16,160+00,0x13,//"戏"
    110+32,160+00,0x14,//"结"
    110+48,160+00,0x15,//"束"
};

extern uint8_t endInterFaceArray[endInterFaceCharNum][3];
void endInterFaceDraw(uint8_t* DrawFlag,uint8_t* arrayCnt,uint32_t score,uint32_t GameShootDownCnt,float GameHitRate){
    uint8_t score_ge = score%10;
    uint8_t score_shi = (score/10)%10;
    uint8_t score_bai = (score/100)%10;
    uint8_t score_qian = (score/1000)%10;
    uint8_t score_wan = (score/10000)%10;
    uint8_t score_shiwan = (score/100000)%10;
    endInterFaceArray[2][2]=score_shiwan;
    endInterFaceArray[3][2]=score_wan;
    endInterFaceArray[4][2]=score_qian;
    endInterFaceArray[5][2]=score_bai;
    endInterFaceArray[6][2]=score_shi;
    endInterFaceArray[7][2]=score_ge;

    uint8_t ge   = GameShootDownCnt%10;
    uint8_t shi  = (GameShootDownCnt/10)%10;
    uint8_t bai  = (GameShootDownCnt/100)%10;
    uint8_t qian = (GameShootDownCnt/1000)%10;
    endInterFaceArray[10][2]=qian;
    endInterFaceArray[11][2]=bai ;
    endInterFaceArray[12][2]=shi ;
    endInterFaceArray[13][2]=ge  ;

    uint8_t GameHitRate_100 = (uint8_t)(GameHitRate*100);
    ge  = GameHitRate_100%10;
    shi = (GameHitRate_100/10)%10;
    endInterFaceArray[17][2]=shi ;
    endInterFaceArray[18][2]=ge  ;

    if((*DrawFlag==1) && (*arrayCnt<endInterFaceCharNum)){
        writeOneSprite(*arrayCnt,endInterFaceArray[*arrayCnt][0],endInterFaceArray[*arrayCnt][1],endInterFaceArray[*arrayCnt][2],0x00);
        (*arrayCnt)+=1;
        *DrawFlag=0;
    }
}

/*************************最高分数的存储与读写***************************/
const uint32_t gameScoreFlashAddr = 0x008000;//擦除一整个扇区
uint32_t read_GameScoreRecord(void){
    uint32_t recordTemp=0;
    uint32_t readOut[3];
    SPI_Flash_Read(readOut,gameScoreFlashAddr,3);
    recordTemp=(readOut[0]<<16)|(readOut[1]<<8)|readOut[2];
    return recordTemp;
}

void save_GameScoreRecord(uint32_t score){
    uint32_t recordTemp = read_GameScoreRecord();
    printf("score=%u\n",score);
    printf("recordTemp=%u\n",recordTemp);
    if(score>recordTemp){
        uint8_t writeIn[256]={0};
        writeIn[0]=score>>16;
        writeIn[1]=score>>8;
        writeIn[2]=score;
        printf("writeIn[0]=%u",writeIn[0]);
        printf("writeIn[1]=%u",writeIn[1]);
        printf("writeIn[2]=%u",writeIn[2]);
        SPI_Flash_Erase_Block(gameScoreFlashAddr);
        SPI_Flash_Write_Page(writeIn,gameScoreFlashAddr,256);
    }
}

void show_GameScoreRecord(void){
    uint32_t recordNow = read_GameScoreRecord();
    printf("recordNow=%u\n",recordNow);
    uint8_t score_ge = recordNow%10;
    uint8_t score_shi = (recordNow/10)%10;
    uint8_t score_bai = (recordNow/100)%10;
    uint8_t score_qian = (recordNow/1000)%10;
    uint8_t score_wan = (recordNow/10000)%10;
    uint8_t score_shiwan = (recordNow/100000)%10;
    writeOneSprite(3+0,(20-1)*8+0*8,(4-1)*8,score_shiwan  ,0x30);
    writeOneSprite(3+1,(20-1)*8+1*8,(4-1)*8,score_wan     ,0x30);
    writeOneSprite(3+2,(20-1)*8+2*8,(4-1)*8,score_qian    ,0x30);
    writeOneSprite(3+3,(20-1)*8+3*8,(4-1)*8,score_bai     ,0x30);
    writeOneSprite(3+4,(20-1)*8+4*8,(4-1)*8,score_shi     ,0x30);
    writeOneSprite(3+5,(20-1)*8+5*8,(4-1)*8,score_ge      ,0x30);
}

#endif
