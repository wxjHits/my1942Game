#include "boom.h"
#include "spriteRam.h"
extern const uint8_t BOOM_NUMMAX;

void new_boomInit(BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        (boom+i)->liveFlag=0;
    }
}
void new_createOneBoom(int16_t PosX,int16_t PosY,BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if((boom+i)->liveFlag==0){
            (boom+i)->BoomCnt=0;
            (boom+i)->PosX=PosX;
            (boom+i)->PosY=PosY;
            (boom+i)->liveFlag=1;
            (boom+i)->FpsCnt=0;
            break;
        }
    }
}
void new_updateBoomData(BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if((boom+i)->liveFlag!=0){
            if((boom+i)->FpsCnt<BOOM_FPS_MAX)
                (boom+i)->FpsCnt+=1;
            else{
                (boom+i)->FpsCnt=0;
                (boom+i)->BoomCnt+=1;
                if((boom+i)->BoomCnt>=4)
                    (boom+i)->liveFlag=0;
            }
        }
    }
}
void new_boomDraw(BOOMType* boom,uint8_t* spriteRamAddr){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if((boom+i)->liveFlag!=0){
            uint8_t step=((boom+i)->BoomCnt)<<1;
            writeOneSprite((*spriteRamAddr)+0,(boom+i)->PosX   ,(boom+i)->PosY   ,0xe0+step,0x10);
            writeOneSprite((*spriteRamAddr)+1,(boom+i)->PosX+8 ,(boom+i)->PosY   ,0xe1+step,0x10);
            writeOneSprite((*spriteRamAddr)+2,(boom+i)->PosX   ,(boom+i)->PosY+7 ,0xe1+step,0xD0);
            writeOneSprite((*spriteRamAddr)+3,(boom+i)->PosX+8 ,(boom+i)->PosY+7 ,0xe0+step,0xD0);
            (*spriteRamAddr)+=4;
        }
    }
}
