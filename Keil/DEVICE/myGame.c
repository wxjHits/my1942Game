#include "myGame.h"
#include "spriteRam.h"

extern const uint8_t BULLET_NUMMAX; 
extern BULLETType bullet[3];
extern PLANEType myplane;
extern const uint8_t ENEMY_NUMMAX; 
extern PLANEType enmeyPlane[5];

void bulletInit(void){
    for(int i=0;i<BULLET_NUMMAX;i++)
        bullet[i].liveFlag=0;
}
void createOneBullet(void){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag==0&&myplane.liveFlag!=0){
            bullet[i].PosX=myplane.PosX;
            bullet[i].PosY=myplane.PosY-8;
            bullet[i].liveFlag=1;
            break;
        }
    }
}

void updateBulletData(void){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0){
            bullet[i].PosY-=4;
            if(bullet[i].PosY<5)//超出边界
                bullet[i].liveFlag=0;
            // else{
            //     for(int j=0;j<ENEMY_NUMMAX;j++){
            //         if(enmeyPlane[j].liveFlag==1&&(bullet[i].PosX-enmeyPlane[j].PosX)<10&&(bullet[i].PosY-enmeyPlane[j].PosX<10))
            //             bullet[i].liveFlag=0;
            //     }
            // }
        }
    }
}

void bulletDraw(void){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0){
            writeOneSprite(20+i,bullet[i].PosX,bullet[i].PosY,14,0x10);
        }
        else{
            writeOneSprite(20+i,bullet[i].PosX,bullet[i].PosY,31,0x10);
        }
            
    }
}

void myPlaneInit(void){
    myplane.PosX=120;
    myplane.PosY=180;
    myplane.liveFlag=1;
    myplane.hp=15;
}

void myPlaneDraw(uint8_t PosX,uint8_t PosY){
    writeOneSprite(10,PosX-8,PosY,10,0x10);
    writeOneSprite(11,PosX+0,PosY,11,0x10);
    writeOneSprite(12,PosX+8,PosY,10,0x50);
    writeOneSprite(13,PosX-4,PosY+8,12,0x10);
    writeOneSprite(14,PosX+4,PosY+8,13,0x10);
}

//敌机相关函数
void enmeyPlaneInit(void){
    for(int i=0;i<ENEMY_NUMMAX;i++)
        enmeyPlane[i].liveFlag=0;
}

void createOneEnmeyPlane(void){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag==0&&myplane.liveFlag!=0){
            enmeyPlane[i].PosX=myplane.PosX+20;
            enmeyPlane[i].PosY=myplane.PosY-100;
            enmeyPlane[i].liveFlag=1;
            break;
        }
    }
}

void updateEnmeyPlaneData(void){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag!=0){
            // enmeyPlane[i].PosY-=4;
            if(enmeyPlane[i].PosY>200)//超出边界
                enmeyPlane[i].liveFlag=0;
            else{
                for(int j=0;j<BULLET_NUMMAX;j++){
                    if(bullet[j].liveFlag==1&&(bullet[j].PosX-enmeyPlane[i].PosX)<5&&(bullet[j].PosY-enmeyPlane[i].PosY<5))
                        enmeyPlane[i].liveFlag=0;
                }
            }
        }
    }
}

void enmeyPlaneDraw(void){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag!=0){
            writeOneSprite(40+i*3+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,15,0x20);
            writeOneSprite(40+i*3+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,16,0x20);
            writeOneSprite(40+i*3+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY+8,17,0x20);
        }
        else{
            writeOneSprite(40+i*3+0,0,0,31,0x20);
            writeOneSprite(40+i*3+1,0,0,31,0x20);
            writeOneSprite(40+i*3+2,0,0,31,0x20);
        }
            
    }
}

void boomDraw(uint8_t PosX,uint8_t PosY){
    writeOneSprite(4,PosX,PosY,19,0x10);
    writeOneSprite(5,PosX+8,PosY,20,0x10);
    writeOneSprite(6,PosX,PosY+8,20,0xD0);
    writeOneSprite(7,PosX+8,PosY+8,19,0xD0);
}

void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score){
    uint8_t ge = score%10;
    uint8_t shi = (score/10)%10;
    uint8_t bai = (score/100)%10;
    uint8_t qian = (score/1000)%10;
    writeOneSprite(0,PosX,PosY,qian,0x10);
    writeOneSprite(1,PosX+8,PosY,bai,0x10);
    writeOneSprite(2,PosX+16,PosY,shi,0x10);
    writeOneSprite(3,PosX+24,PosY,ge,0x10);
}