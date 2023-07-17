#include "gameHitCheck.h"
#include "boom.h"
#include "apu.h"

extern const uint8_t MYPLANE_BULLET_NUMMAX;
extern const uint8_t ENEMY_BULLETS_NUMMAX;
extern const uint8_t S_GREY_NUMMAX;
extern const uint8_t S_GREEN_NUMMAX;
extern const uint8_t M_STRAIGHT_NUMMAX;
extern const uint8_t B_GREEN_NUMMAX;
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
void enemyAndBulletMapCreate(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,B_GREEN_PLANEType* b_green_enmeyPlane,BULLETType* enmeyBullet,hitMapType* hitMap){
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
    for (int i=0;i<B_GREEN_NUMMAX;i++){
        if((b_green_enmeyPlane+i)->liveFlag!=0){
            tileMap((b_green_enmeyPlane+i)->PosX+ 0,(b_green_enmeyPlane+i)->PosY+14,hitMap);
            tileMap((b_green_enmeyPlane+i)->PosX- 7,(b_green_enmeyPlane+i)->PosY+12,hitMap);
            tileMap((b_green_enmeyPlane+i)->PosX+ 7,(b_green_enmeyPlane+i)->PosY+12,hitMap);
            tileMap((b_green_enmeyPlane+i)->PosX-14,(b_green_enmeyPlane+i)->PosY+10,hitMap);
            tileMap((b_green_enmeyPlane+i)->PosX+14,(b_green_enmeyPlane+i)->PosY+10,hitMap);
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
            //爆炸音效
                set_noise_00(0x8F);
                set_noise_01(0x00);
                set_noise_10(0x95);
                set_noise_11(0x98);
        }
    }
}

extern uint32_t GameScore;
void isHit_s_EnemyPlane(S_GREY_PLANEType* s_grey_enmeyPlane,S_GREEN_PLANEType* s_green_enmeyPlane,hitMapType* hitMap,BOOMType* boom){
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
                
                //爆炸音效
                set_noise_00(0x8F);
                set_noise_01(0x00);
                set_noise_10(0x95);
                set_noise_11(0x98);
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
                GameScore+=15;

                //爆炸音效
                set_noise_00(0x8F);
                set_noise_01(0x00);
                set_noise_10(0x95);
                set_noise_11(0x98);
            }
        }
    }
}

void isHit_m_straight_EnemyPlane(M_STRAIGHT_PLANEType* m_straight_enmeyPlane,hitMapType* hitMap,BOOMType* boom){
    for(int i=0;i<M_STRAIGHT_NUMMAX;i++){
        if((m_straight_enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((m_straight_enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((m_straight_enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap->map[gridPosY+1] & (1<<(gridPosX+0)))|
                (hitMap->map[gridPosY+1] & (1<<(gridPosX+1)))
            );

            if(isHitFlag!=0){
                (m_straight_enmeyPlane+i)->hp--;
                new_createOneBoom((m_straight_enmeyPlane+i)->PosX,(m_straight_enmeyPlane+i)->PosY+8,boom);
                if((m_straight_enmeyPlane+i)->hp==0){
                    (m_straight_enmeyPlane+i)->liveFlag=0;
                    (m_straight_enmeyPlane+i)->PosX=253;
                    (m_straight_enmeyPlane+i)->PosY=239;
                    GameScore+=50;
                }
            }
        }
    }
}

void isHit_b_EnemyPlane(B_GREEN_PLANEType* b_green_enmeyPlane,hitMapType* hitMap,BOOMType* boom){
    for(int i=0;i<B_GREEN_NUMMAX;i++){//小型敌机的碰撞检测
        if((b_green_enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((b_green_enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((b_green_enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap->map[gridPosY+2] & (1<<(gridPosX+0)))|
                (hitMap->map[gridPosY+2] & (1<<(gridPosX-1)))|
                (hitMap->map[gridPosY+2] & (1<<(gridPosX+1)))|
                (hitMap->map[gridPosY+2] & (1<<(gridPosX-2)))|
                (hitMap->map[gridPosY+2] & (1<<(gridPosX+2)))
            );

            if(isHitFlag!=0){
                (b_green_enmeyPlane+i)->hp--;
                new_createOneBoom((b_green_enmeyPlane+i)->PosX-8,(b_green_enmeyPlane+i)->PosY+20,boom);
                if((b_green_enmeyPlane+i)->hp==0){
                    (b_green_enmeyPlane+i)->liveFlag=0;
                    (b_green_enmeyPlane+i)->PosX=253;
                    (b_green_enmeyPlane+i)->PosY=239;
                    GameScore+=200;
                }
            }
        }
    }
}

extern uint32_t GameShootDownCnt;//游戏击落数
void isHit_myBullets(BULLETType* myBullet,hitMapType* enemyPlaneAndBullet_HitMap){
    for (int i=0;i<MYPLANE_BULLET_NUMMAX;i++){
        if((myBullet+i)->liveFlag!=0){
            uint8_t gridPosX=((myBullet+i)->PosX >>3);
            uint8_t gridPosY=((myBullet+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (enemyPlaneAndBullet_HitMap->map[gridPosY+0] & (1<<(gridPosX+0)))
            );

            if(isHitFlag!=0){
                (myBullet+i)->liveFlag=0;
                (myBullet+i)->PosX=253;
                (myBullet+i)->PosY=239;
                GameShootDownCnt++;
            }
        }
    }
}
