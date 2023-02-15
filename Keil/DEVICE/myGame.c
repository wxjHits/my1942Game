#include "myGame.h"
#include "spriteRam.h"
#include "uart.h"

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
            bullet[i].PosX=myplane.PosX+8;
            bullet[i].PosY=myplane.PosY-8;
            bullet[i].liveFlag=1;
            break;
        }
    }
}

void updateBulletData(void){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0){
            bullet[i].PosY-=2;
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
    if(myplane.liveFlag!=0){
        writeOneSprite(10,PosX+0,PosY,10,0x30);
        writeOneSprite(11,PosX+8,PosY,11,0x30);
        writeOneSprite(12,PosX+16,PosY,10,0x70);
        writeOneSprite(13,PosX+4,PosY+8,12,0x30);
        writeOneSprite(14,PosX+12,PosY+8,13,0x30);
    }
    else{
        writeOneSprite(10,PosX-8,PosY,31,0x10);
        writeOneSprite(11,PosX+0,PosY,31,0x10);
        writeOneSprite(12,PosX+8,PosY,31,0x50);
        writeOneSprite(13,PosX-4,PosY+8,31,0x10);
        writeOneSprite(14,PosX+4,PosY+8,31,0x10);
    }
    
}

//敌机相关函数
void enmeyPlaneInit(void){
    for(int i=0;i<ENEMY_NUMMAX;i++)
        enmeyPlane[i].liveFlag=0;
}

void createOneEnmeyPlane(uint8_t PosX,uint8_t PosY){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag==0){
            // enmeyPlane[i].PosX=myplane.PosX+30;
            // enmeyPlane[i].PosY=myplane.PosY-20;

            enmeyPlane[i].PosX=PosX;
            enmeyPlane[i].PosY=PosY;
            enmeyPlane[i].liveFlag=1;
            break;
        }
    }
}

void enmeyPlaneDraw(void){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag!=0){
            writeOneSprite(40+i*3+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,15,0x20);
            writeOneSprite(40+i*3+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,16,0x20);
            writeOneSprite(40+i*3+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY-8,17,0x20);
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
    writeOneSprite(0,PosX,PosY,qian,0x30);
    writeOneSprite(1,PosX+8,PosY,bai,0x30);
    writeOneSprite(2,PosX+16,PosY,shi,0x30);
    writeOneSprite(3,PosX+24,PosY,ge,0x30);
}

//碰撞相关函数
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap){
    uint8_t gridPosX=(PosX>>3);
    uint8_t gridPosY=PosY>>3;

    uint32_t mask = 1<<(gridPosX);
    hitMap->map[gridPosY]=hitMap->map[gridPosY]|mask;
}
void myPlaneMapCreate(uint8_t PosX,uint8_t PosY,hitMapType* hitMap){
    tileMap(PosX,PosY,hitMap);
    tileMap(PosX+8,PosY,hitMap);
    tileMap(PosX+16,PosY,hitMap);
    tileMap(PosX+4,PosY+8,hitMap);
    tileMap(PosX+12,PosY+8,hitMap);
}

void bulletsMapCreate(BULLETType* bullet,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0)
            tileMap((bullet[i]).PosX,(bullet[i]).PosY,hitMap);
    }
}

void enemyMapCreate(PLANEType* enmeyPlane,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<ENEMY_NUMMAX;i++){
        if((enmeyPlane+i)->liveFlag!=0){
            tileMap((enmeyPlane+i)->PosX,(enmeyPlane+i)->PosY,hitMap);
            tileMap((enmeyPlane+i)->PosX+8,(enmeyPlane+i)->PosY,hitMap);
            tileMap((enmeyPlane+i)->PosX+4,(enmeyPlane+i)->PosY-8,hitMap);   
        }
    }
}

bool isMyPlaneHit(PLANEType* myPlane,hitMapType* enemyPlaneHitMap){
    // for(int i=0;i<32;i++){
    //     enemyPlaneHitMap->map[i]=0;
    // }
    enemyMapCreate(&enmeyPlane,enemyPlaneHitMap);

    uint8_t gridPosX=(myPlane->PosX >>3);
    uint8_t gridPosY=myPlane->PosY >>3;

    uint32_t isHitFlag = 
            (
                (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+2)))|
                (enemyPlaneHitMap->map[gridPosY+1] & (1<<(gridPosX+0)))|
                (enemyPlaneHitMap->map[gridPosY+1] & (1<<(gridPosX+1)))
            )
            ;
    // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
    
    if(isHitFlag==0){
        myPlane->liveFlag=myPlane->liveFlag;
        return false;
    }
    else{
        // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
        boomDraw(myplane.PosX,myplane.PosY);
        myPlane->PosX=255;
        myPlane->PosY=239;
        myPlane->liveFlag=0;
        return true;
    }
}

extern uint32_t GameScore;
void isEnemyPlaneHit(PLANEType* enmeyPlane,hitMapType bulletsHitMap){
    
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if((enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (bulletsHitMap.map[gridPosY+0] & (1<<(gridPosX+0)))|
                (bulletsHitMap.map[gridPosY+0] & (1<<(gridPosX+1)))|
                (bulletsHitMap.map[gridPosY-1] & (1<<(gridPosX+1)))
            );
            if(isHitFlag==0){
                (enmeyPlane+i)->liveFlag=(enmeyPlane+i)->liveFlag;
            }
            else{
                // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
                boomDraw((enmeyPlane+i)->PosX,(enmeyPlane+i)->PosY);
                (enmeyPlane+i)->liveFlag=0;
                (enmeyPlane+i)->PosX=253;
                (enmeyPlane+i)->PosY=239;
                GameScore+=10;
            }
        }
    }
    

}

void isBulletsHit(BULLETType* bullet,hitMapType hitMap){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if((bullet+i)->liveFlag!=0){
            uint8_t gridPosX=((bullet+i)->PosX >>3);
            uint8_t gridPosY=((bullet+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+0)))
            );
            if(isHitFlag==0){
                (bullet+i)->liveFlag=(bullet+i)->liveFlag;
            }
            else{
                // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
                (bullet+i)->liveFlag=0;
                (bullet+i)->PosX=253;
                (bullet+i)->PosY=239;
            }
        }
    }
}   