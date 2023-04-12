#include "gameHitCheck.h"
#include "boom.h"

extern const uint8_t MYPLANE_BULLET_NUMMAX;
extern const uint8_t ENEMY_BULLETS_NUMMAX;
extern const uint8_t S_GREY_NUMMAX;
extern const uint8_t S_GREEN_NUMMAX;
//创建bitMask hit map 
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap){
    uint8_t gridPosX=(PosX>>3);
    uint8_t gridPosY=PosY>>3;

    uint32_t mask = 1<<(gridPosX);
    hitMap->map[gridPosY]=hitMap->map[gridPosY]|mask;
}
void myBulletsMapCreate(BULLETType* myBullet,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<MYPLANE_BULLET_NUMMAX;i++){
        if((myBullet+i)->liveFlag!=0)
            tileMap((myBullet+i)->PosX,(myBullet+i)->PosY,hitMap);
    }
}
void enemyAndBulletMapCreate(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,BULLETType* enmeyBullet,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<S_GREY_NUMMAX;i++){
        if((s_grey_enmeyPlane+i)->liveFlag!=0){
            tileMap((s_grey_enmeyPlane+i)->PosX,(s_grey_enmeyPlane+i)->PosY,hitMap);
            tileMap((s_grey_enmeyPlane+i)->PosX+8,(s_grey_enmeyPlane+i)->PosY,hitMap);
            tileMap((s_grey_enmeyPlane+i)->PosX+4,(s_grey_enmeyPlane+i)->PosY-8,hitMap);   
        }
    }
    for (int i=0;i<S_GREEN_NUMMAX;i++){
        if((s_green_enmeyPlane+i)->liveFlag!=0){
            tileMap((s_green_enmeyPlane+i)->PosX+0,(s_green_enmeyPlane+i)->PosY,hitMap);
            tileMap((s_green_enmeyPlane+i)->PosX+8,(s_green_enmeyPlane+i)->PosY,hitMap);
            tileMap((s_green_enmeyPlane+i)->PosX+4,(s_green_enmeyPlane+i)->PosY-8,hitMap);   
        }
    }
    for (int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if((enmeyBullet+i)->liveFlag!=0)
            tileMap((enmeyBullet+i)->PosX,(enmeyBullet+i)->PosY,hitMap);
    }
}

void isMyPlaneHit(MYPLANEType* myPlane,hitMapType* enemyPlaneAndBullet_HitMap,BOOMType* boom){
    if(myPlane->actFlag==1)
        ;
    else{
        uint8_t gridPosX=(myPlane->PosX >>3);
        uint8_t gridPosY=myPlane->PosY >>3;

        //与敌机的撞击测试
        uint32_t isEnemyHitFlag=(
                                    (enemyPlaneAndBullet_HitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                                    (enemyPlaneAndBullet_HitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                                    (enemyPlaneAndBullet_HitMap->map[gridPosY+0] & (1<<(gridPosX+2)))|
                                    (enemyPlaneAndBullet_HitMap->map[gridPosY+1] & (1<<(gridPosX+0)))|
                                    (enemyPlaneAndBullet_HitMap->map[gridPosY+1] & (1<<(gridPosX+1)))
                                );
        if(isEnemyHitFlag==0){
            myPlane->liveFlag=myPlane->liveFlag;
        }
        else{
            new_createOneBoom(myPlane->PosX,myPlane->PosY,boom);
            myPlane->PosX=255;
            myPlane->PosY=239;
            myPlane->liveFlag=0;
        }
    }
}

extern uint32_t GameScore;
void isHit_s_grey_EnemyPlane(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,hitMapType* hitMap,BOOMType* boom){
    for(int i=0;i<S_GREY_NUMMAX;i++){//小型敌机的碰撞检测
        if((s_grey_enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((s_grey_enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((s_grey_enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                (hitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                (hitMap->map[gridPosY-1] & (1<<(gridPosX+1)))
            );

            if(isHitFlag!=0){
                new_createOneBoom((s_grey_enmeyPlane+i)->PosX,(s_grey_enmeyPlane+i)->PosY,boom);
                (s_grey_enmeyPlane+i)->liveFlag=0;
                (s_grey_enmeyPlane+i)->PosX=253;
                (s_grey_enmeyPlane+i)->PosY=239;
                GameScore+=10;
            }
        }
    }
    for(int i=0;i<S_GREEN_NUMMAX;i++){//小型敌机的碰撞检测
        if((s_green_enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((s_green_enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((s_green_enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                (hitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                (hitMap->map[gridPosY-1] & (1<<(gridPosX+1)))
            );

            if(isHitFlag!=0){
                new_createOneBoom((s_green_enmeyPlane+i)->PosX,(s_green_enmeyPlane+i)->PosY,boom);
                (s_green_enmeyPlane+i)->liveFlag=0;
                (s_green_enmeyPlane+i)->PosX=253;
                (s_green_enmeyPlane+i)->PosY=239;
                GameScore+=10;
            }
        }
    }
}

