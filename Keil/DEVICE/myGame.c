#include "myGame.h"
#include "spriteRam.h"
#include "uart.h"

extern const uint8_t BULLET_NUMMAX; 
extern BULLETType bullet[3];

extern PLANEType myplane;

extern const uint8_t ENEMY_NUMMAX; 
extern PLANEType enmeyPlane[5];

extern const uint8_t BOOM_NUMMAX;
extern BOOMType boom[3];

extern const uint8_t routeCircle[18][2];

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
            bullet[i].PosY-=MYBULLET_SPEED;
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
            writeOneSprite(SPRITE_RAM_ADDR_START_BULLET+i,bullet[i].PosX,bullet[i].PosY,0x31,0x10);
        }
        else{
            writeOneSprite(SPRITE_RAM_ADDR_START_BULLET+i,bullet[i].PosX,bullet[i].PosY,0xff,0x10);
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
    uint8_t ram_num=SPRITE_RAM_ADDR_START_MYPLANE;
    uint8_t sprite_num = 0x33;
    if(myplane.liveFlag!=0){
        writeOneSprite(ram_num+0,PosX+0,PosY,sprite_num+0,0x30);
        writeOneSprite(ram_num+1,PosX+8,PosY,sprite_num+1,0x30);
        writeOneSprite(ram_num+2,PosX+16,PosY,sprite_num+0,0x70);
        writeOneSprite(ram_num+3,PosX+4,PosY+8,sprite_num+2,0x30);
        writeOneSprite(ram_num+4,PosX+12,PosY+8,sprite_num+3,0x30);
    }
    else{
        writeOneSprite(ram_num+0,PosX-8,PosY,31,0x10);
        writeOneSprite(ram_num+1,PosX+0,PosY,31,0x10);
        writeOneSprite(ram_num+2,PosX+8,PosY,31,0x50);
        writeOneSprite(ram_num+3,PosX-4,PosY+8,31,0x10);
        writeOneSprite(ram_num+4,PosX+4,PosY+8,31,0x10);
    }
    
}

//敌机相关函数
void enmeyPlaneInit(void){
    for(int i=0;i<ENEMY_NUMMAX;i++)
        enmeyPlane[i].liveFlag=0;
}

void createOneEnmeyPlane(uint8_t PosX,uint8_t PosY,ROUTEType route){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag==0){
            // enmeyPlane[i].PosX=myplane.PosX+30;
            // enmeyPlane[i].PosY=myplane.PosY-20;

            enmeyPlane[i].PosX=PosX;
            enmeyPlane[i].PosY=PosY;
            enmeyPlane[i].liveFlag=1;
            enmeyPlane[i].FpsCnt=0;

            enmeyPlane[i].route.route0  =route.route0  ;
            enmeyPlane[i].route.route1  =route.route1  ;
            enmeyPlane[i].route.turnLine=route.turnLine;
            enmeyPlane[i].route.routeCnt=route.routeCnt;
            enmeyPlane[i].route.routeCircleCnt=route.routeCircleCnt;

            break;
        }
    }
}

void moveEnmeyPlane(PLANEType* enmeyPlane){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        // if(enmeyPlane[i].PosY>=enmeyPlane[i].route.turnLine)
        //     enmeyPlane[i].route.routeCnt=1;
        if(enmeyPlane[i].PosY>=myplane.PosY+rand()%10)
            enmeyPlane[i].route.routeCnt=1;

        if(enmeyPlane[i].liveFlag!=0){
            if(enmeyPlane[i].FpsCnt==ENEMY_FPS_MAX){
                enmeyPlane[i].FpsCnt=0;
                if  (
                        enmeyPlane[i].PosX<LEFT_LINE||
                        enmeyPlane[i].PosX>RIGHT_LINE||
                        enmeyPlane[i].PosY<TOP_LINE||
                        enmeyPlane[i].PosY>BOTTOM_LINE
                    )
                    enmeyPlane[i].liveFlag=0;
                else if(enmeyPlane[i].route.routeCnt==0){
                    switch (enmeyPlane[i].route.route0)
                    {
                        case DOWN:
                                enmeyPlane[i].PosX += 0;
                                enmeyPlane[i].PosY += 2;
                                break;
                        case DOWN_LEFT:
                                enmeyPlane[i].PosX -= 2;
                                enmeyPlane[i].PosY += 3;
                                break;
                        case DOWN_RIGHT:
                                enmeyPlane[i].PosX += 2;
                                enmeyPlane[i].PosY += 3;
                                break;
                        default: break;
                    }
                }
                else if(enmeyPlane[i].route.routeCnt==1){
                    switch (enmeyPlane[i].route.route1)
                    {
                        case UP:
                                enmeyPlane[i].PosX += 0;
                                enmeyPlane[i].PosY -= 2;
                                break;
                        case UP_LEFT:
                                enmeyPlane[i].PosX -= 2;
                                enmeyPlane[i].PosY -= 3;
                                break;
                        case UP_RIGHT:
                                enmeyPlane[i].PosX += 2;
                                enmeyPlane[i].PosY -= 3;
                                break;
                        // case CIRCLE:
                        //         enmeyPlane[i].PosX = routeCircle[enmeyPlane[i].route.routeCircleCnt][0];
                        //         enmeyPlane[i].PosY = routeCircle[enmeyPlane[i].route.routeCircleCnt][1];
                        //     break;
                        default: break;
                    }
                    // enmeyPlane[i].route.routeCircleCnt+=1;
                    // if(enmeyPlane[i].route.routeCircleCnt>=CIRCLELOGNTH_MAX){
                    //     enmeyPlane[i].route.routeCircleCnt =0;
                    //     enmeyPlane[i].route.routeCnt =3;
                    // }
                }
            }
            else
                enmeyPlane[i].FpsCnt+=1;
        }    
    }
}

void enmeyPlaneDraw(void){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        uint8_t num=0x40;
        if(enmeyPlane[i].liveFlag!=0){
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,0x20);
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num+1,0x20);
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY-8,num+2,0x20);
        }
        else{
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+0,0,0,0xff,0x20);
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+1,0,0,0xff,0x20);
            writeOneSprite(SPRITE_RAM_ADDR_START_ENEMYPLANE+i*3+2,0,0,0xff,0x20);
        }     
    }
}

//爆炸效果作图函数，后续应该添加爆炸的第几帧，每一帧持续多长时间
//1942游戏的敌机爆炸一共四帧
void boomInit(BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        boom[i].liveFlag=0;
    }
}

void createOneBoom(uint8_t PosX,uint8_t PosY,BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if(boom[i].liveFlag==0){
            boom[i].BoomCnt=0;
            boom[i].PosX=PosX;
            boom[i].PosY=PosY;
            boom[i].liveFlag=1;
            boom[i].FpsCnt=0;
            break;
        }
    }
}

void updateBoomData(BOOMType* boom){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if(boom[i].liveFlag!=0){
            // printf("boom[i].FpsCnt=%d\nboom[i].BoomCnt=%d\n",boom[i].FpsCnt,boom[i].BoomCnt);
            // printf("boom[i].FpsCnt=%d\nboom[i].BoomCnt=%d\n",boom[i].FpsCnt,boom[i].BoomCnt);
            if(boom[i].FpsCnt<BOOM_FPS_MAX)
                boom[i].FpsCnt+=1;
            else {
                boom[i].FpsCnt=0;
                boom[i].BoomCnt+=1;
                if(boom[i].BoomCnt==4){
                    // printf("boom[i].FpsCnt=%d\nboom[i].BoomCnt=%d\n",boom[i].FpsCnt,boom[i].BoomCnt);
                    boom[i].liveFlag=0;
                }
                    
            }
        }
    }
}
void boomDraw(void){
    uint8_t num=SPRITE_RAM_ADDR_START_BOOM;
    for(int i=0;i<BOOM_NUMMAX;i++){
        if(boom[i].liveFlag!=0){
            uint8_t step=2*(boom[i].BoomCnt);
            writeOneSprite(num+0,boom[i].PosX   ,boom[i].PosY   ,0xe0+step,0x30);
            writeOneSprite(num+1,boom[i].PosX+8 ,boom[i].PosY   ,0xe1+step,0x30);
            writeOneSprite(num+2,boom[i].PosX   ,boom[i].PosY+8 ,0xe1+step,0xF0);
            writeOneSprite(num+3,boom[i].PosX+8 ,boom[i].PosY+8 ,0xe0+step,0xF0);
            
            // writeOneSprite(num+0,boom[i].PosX   ,boom[i].PosY   ,19+boom[i].BoomCnt,0x10);
            // writeOneSprite(num+1,boom[i].PosX+8 ,boom[i].PosY   ,20+boom[i].BoomCnt,0x10);
            // writeOneSprite(num+2,boom[i].PosX   ,boom[i].PosY+8 ,20+boom[i].BoomCnt,0xD0);
            // writeOneSprite(num+3,boom[i].PosX+8 ,boom[i].PosY+8 ,19+boom[i].BoomCnt,0xD0);
            num += 4;
            // printf("boom[i].FpsCnt=%d\nboom[i].BoomCnt=%d\n",boom[i].FpsCnt,boom[i].BoomCnt);
        }
        else{
            writeOneSprite(num+0,250,239,31,0x10);
            writeOneSprite(num+1,250,239,31,0x10);
            writeOneSprite(num+2,250,239,31,0xD0);
            writeOneSprite(num+3,250,239,31,0xD0);
        }
    }
}

void gameScoreDraw(uint8_t PosX,uint8_t PosY, uint32_t score){
    uint8_t ge = score%10;
    uint8_t shi = (score/10)%10;
    uint8_t bai = (score/100)%10;
    uint8_t qian = (score/1000)%10;
    writeOneSprite(SPRITE_RAM_ADDR_START_SCORE+0,PosX,PosY,qian,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_SCORE+1,PosX+8,PosY,bai,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_SCORE+2,PosX+16,PosY,shi,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_SCORE+3,PosX+24,PosY,ge,0x30);
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

//我方飞机可以被敌方子弹和敌方飞机摧毁并产生爆炸效果(我方飞机后续可以添加护盾效果,更换调色板表示进行赤红状态,可以承受一次撞击)
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
        createOneBoom(myplane.PosX,myplane.PosY,&boom);
        myPlane->PosX=255;
        myPlane->PosY=239;
        myPlane->liveFlag=0;
        return true;
    }
}

extern uint32_t GameScore;
//敌方飞机只能被我方子弹摧毁
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
                createOneBoom((enmeyPlane+i)->PosX,(enmeyPlane+i)->PosY,&boom);
                (enmeyPlane+i)->liveFlag=0;
                (enmeyPlane+i)->PosX=253;
                (enmeyPlane+i)->PosY=239;
                GameScore+=10;
            }
        }
    }
}

//我方子弹可以被敌方子弹和敌方飞机摧毁(我方子弹最后可以添加无敌效果)
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

void gameFPSDraw(uint32_t fps){
    uint8_t ge = fps%10;
    uint8_t shi = (fps/10)%10;
    uint8_t bai = (fps/100)%10;
    uint8_t qian = (fps/1000)%10;

    writeOneSprite(SPRITE_RAM_ADDR_START_FPS+0,220+0 ,220,qian,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_FPS+1,220+8 ,220,bai,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_FPS+2,220+16,220,shi,0x30);
    writeOneSprite(SPRITE_RAM_ADDR_START_FPS+3,220+24,220,ge,0x30);
}