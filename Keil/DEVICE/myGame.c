#include "stdlib.h"
#include "myGame.h"
#include "spriteRam.h"
#include "ahb_plane.h"
#include "uart.h"
#include "led.h"

extern const uint8_t ANGLE_NUMMAX;
extern const int16_t sin_array[10];
extern const int16_t cos_array[10];
extern const float tan_array[10];

extern const uint8_t BULLET_NUMMAX; 
extern BULLETType bullet[3];

extern const uint8_t ENEMY_BULLETS_NUMMAX;
extern BULLETType enmeyBullets[5];

extern const uint8_t M_ENEMY_NUMMAX;
extern M_PLANEType M_enmeyPlane[1];

extern MYPLANEType myplane;

extern const uint8_t ENEMY_NUMMAX; 
extern PLANEType enmeyPlane[5];

extern const uint8_t BOOM_NUMMAX;
extern BOOMType boom[3];

extern BUFFType buff;

extern const uint8_t routeCircle[18][2];

extern uint32_t GameShootBulletsCnt;//子弹发射数量计数器
extern uint32_t GameShootDownCnt;//击落数量统计

int16_t myInt16_abs(int16_t a,int16_t b){
    if(a<b)
        return (b-a);
    else
        return (a-b);
}

void bulletInit(void){
    for(int i=0;i<BULLET_NUMMAX;i++)
        bullet[i].liveFlag=0;
}

void createOneBullet(void){
    if(myplane.liveFlag!=0){
        if(myplane.bulletOnceNum==0){
            for(int i=0;i<5;i++){
                if(bullet[i].liveFlag==0){
                    bullet[i].PosX=myplane.PosX+8;
                    bullet[i].PosY=myplane.PosY-8;
                    bullet[i].liveFlag=1;
                    GameShootBulletsCnt+=1;
                    break;
                }
            }
        }
        else if(myplane.bulletOnceNum==1){
            for(int i=0;i<10;i++){
                if(bullet[i].liveFlag==0&&bullet[i+1].liveFlag==0){
                    bullet[i].PosX=myplane.PosX+4;
                    bullet[i].PosY=myplane.PosY-8;
                    bullet[i].liveFlag=1;
                    bullet[i+1].PosX=myplane.PosX+12;
                    bullet[i+1].PosY=myplane.PosY-8;
                    bullet[i+1].liveFlag=1;
                    GameShootBulletsCnt+=2;
                    break;
                }
            }
        }
        else if(myplane.bulletOnceNum==2){
            for(int i=0;i<20;i++){
                if(bullet[i].liveFlag==0&&bullet[i+1].liveFlag==0&&bullet[i+2].liveFlag==0&&bullet[i+3].liveFlag==0){
                    bullet[i].PosX=myplane.PosX-4;
                    bullet[i].PosY=myplane.PosY-8;
                    bullet[i].liveFlag=1;
                    bullet[i+1].PosX=myplane.PosX+4;
                    bullet[i+1].PosY=myplane.PosY-8;
                    bullet[i+1].liveFlag=1;
                    bullet[i+2].PosX=myplane.PosX+12;
                    bullet[i+2].PosY=myplane.PosY-8;
                    bullet[i+2].liveFlag=1;
                    bullet[i+3].PosX=myplane.PosX+20;
                    bullet[i+3].PosY=myplane.PosY-8;
                    bullet[i+3].liveFlag=1;
                    GameShootBulletsCnt+=4;
                    break;
                }
            }
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

void bulletDraw(uint8_t* spriteRamAddr){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0){
            writeOneSprite((*spriteRamAddr),bullet[i].PosX,bullet[i].PosY,0x31,0x10);
            (*spriteRamAddr)+=1;
        }
    }
}

void myPlaneInit(void){
    myplane.PosX=120;
    myplane.PosY=180;
    myplane.liveFlag=1;
    myplane.actFlag=0;
    myplane.actFpsCnt=0;
    myplane.attitude=0;
    myplane.bulletOnceNum=1;
    myplane.hp=1;
}

//敌机相关函数
void enmeyPlaneInit(void){
    for(int i=0;i<ENEMY_NUMMAX;i++)
        enmeyPlane[i].liveFlag=0;
}

void M_enmeyPlaneInit(M_PLANEType* M_enmeyPlane){
    // for (int i = 0; i < M_ENEMY_NUMMAX; i++)
    // {
    //     M_enmeyPlane[i].liveFlag=0;
    // }
    ahb_plane_Init(50,20);
}

void createOneEnmeyPlane(PLANEType* enmeyPlaneCanshu){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag==0){
            // enmeyPlane[i].PosX=myplane.PosX+30;
            // enmeyPlane[i].PosY=myplane.PosY-20;
            enmeyPlane[i].PosX=enmeyPlaneCanshu->PosX;
            enmeyPlane[i].PosY=enmeyPlaneCanshu->PosY;
            enmeyPlane[i].type=enmeyPlaneCanshu->type;
            enmeyPlane[i].liveFlag=1;
            enmeyPlane[i].FpsCnt=0;
            enmeyPlane[i].attitude=0;
            enmeyPlane[i].shootFlag=enmeyPlaneCanshu->shootFlag;
            enmeyPlane[i].route.route0  =enmeyPlaneCanshu->route.route0  ;
            enmeyPlane[i].route.route1  =enmeyPlaneCanshu->route.route1  ;
            enmeyPlane[i].route.turnLine=enmeyPlaneCanshu->route.turnLine;
            enmeyPlane[i].shootPosY=enmeyPlane[i].route.turnLine;
            enmeyPlane[i].route.routeCnt=0;
            enmeyPlane[i].route.routeCircleCnt=enmeyPlaneCanshu->route.routeCircleCnt;
            break;
        }
    }
}

void createOne_M_EnmeyPlane(void){
    // for (int i = 0; i < M_ENEMY_NUMMAX; i++){
    //     if (M_enmeyPlane[i].liveFlag==0){
    //         M_enmeyPlane[i].attitude=0;
    //         M_enmeyPlane[i].FpsCnt=0;
    //         M_enmeyPlane[i].hp=10;
    //         M_enmeyPlane[i].liveFlag=1;
    //         M_enmeyPlane[i].PosX=80;
    //         M_enmeyPlane[i].PosY=20;
    //         M_enmeyPlane[i].x_turn0=M_enmeyPlane[i].PosX+20;
    //         M_enmeyPlane[i].x_turn1=M_enmeyPlane[i].PosX+20+80;
    //         M_enmeyPlane[i].y_turn0=M_enmeyPlane[i].PosY+50;
    //         M_enmeyPlane[i].y_turn1=M_enmeyPlane[i].PosY+50+20;
    //         M_enmeyPlane[i].y_turn2=M_enmeyPlane[i].PosY+50+20+40;
    //         M_enmeyPlane[i].y_turn3=M_enmeyPlane[i].PosY+50+20+40+20;
    //     }
    // }
    if(AHBPLANE->isLive==0)
        ahb_plane_create();
}

void move_M_EnmeyPlane(M_PLANEType* M_enmeyPlane_){
    ahb_plane_Update();
    // for(int i=0;i<M_ENEMY_NUMMAX;i++){
    //     if((M_enmeyPlane_+i)->liveFlag!=0){
    //         if((M_enmeyPlane_+i)->FpsCnt==ENEMY_FPS_MAX){
    //             (M_enmeyPlane_+i)->FpsCnt=0;
    //             if((M_enmeyPlane_+i)->PosX<LEFT_LINE||(M_enmeyPlane_+i)->PosX>RIGHT_LINE||(M_enmeyPlane_+i)->PosY<TOP_LINE||(M_enmeyPlane_+i)->PosY>BOTTOM_LINE)
    //                 (M_enmeyPlane_+i)->liveFlag=0;
    //             else{//坐标更新
    //                 switch ((M_enmeyPlane_+i)->attitude){//状态转换
    //                     case 0:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn2)<1)
    //                             (M_enmeyPlane_+i)->attitude=1;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX+=0;
    //                             (M_enmeyPlane_+i)->PosY+=1;
    //                         }
    //                         break;
    //                     case 1:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn3)<1)
    //                             (M_enmeyPlane_+i)->attitude=2;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX+=1;
    //                             (M_enmeyPlane_+i)->PosY+=1;
    //                         }
    //                         break;
    //                     case 2:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosX,(M_enmeyPlane_+i)->x_turn1)<1)
    //                             (M_enmeyPlane_+i)->attitude=3;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX+=1;
    //                             (M_enmeyPlane_+i)->PosY+=0;
    //                         }
    //                         break;
    //                     case 3:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn2)<1)
    //                             (M_enmeyPlane_+i)->attitude=4;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX+=1;
    //                             (M_enmeyPlane_+i)->PosY-=1;
    //                         }
                            
    //                         break;
    //                     case 4:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn1)<1)
    //                             (M_enmeyPlane_+i)->attitude=5;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX+=0;
    //                             (M_enmeyPlane_+i)->PosY-=1;
    //                         }
                            
    //                         break;
    //                     case 5:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn0)<1)
    //                             (M_enmeyPlane_+i)->attitude=6;
    //                         else {
    //                             (M_enmeyPlane_+i)->PosX-=1;
    //                             (M_enmeyPlane_+i)->PosY-=1;
    //                         }
    //                         break;
    //                     case 6:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosX,(M_enmeyPlane_+i)->x_turn0)<1)
    //                             (M_enmeyPlane_+i)->attitude=7;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX-=1;
    //                             (M_enmeyPlane_+i)->PosY-=0;
    //                         }
    //                         break;
    //                     case 7:
    //                         if(myInt16_abs((M_enmeyPlane_+i)->PosY,(M_enmeyPlane_+i)->y_turn1)<1)
    //                             (M_enmeyPlane_+i)->attitude=8;
    //                         else{
    //                             (M_enmeyPlane_+i)->PosX-=1;
    //                             (M_enmeyPlane_+i)->PosY+=1;
    //                         }
    //                         break;
    //                     case 8:
    //                         (M_enmeyPlane_+i)->PosX+=0;
    //                         (M_enmeyPlane_+i)->PosY+=1;
    //                         (M_enmeyPlane_+i)->attitude=8;
    //                         break;
    //                     default:
    //                         (M_enmeyPlane_+i)->PosX+=0;
    //                         (M_enmeyPlane_+i)->PosY+=0;
    //                         (M_enmeyPlane_+i)->attitude=(M_enmeyPlane_+i)->attitude;
    //                         LED_toggle(2);
    //                         break;
    //                 }
    //             }
    //         }
    //         else{
    //             M_enmeyPlane[i].FpsCnt+=1;
    //         }
    //     } 
    // }
}

void moveEnmeyPlane(PLANEType* enmeyPlane){
    for(int i=0;i<ENEMY_NUMMAX;i++){

        //
        // if(enmeyPlane[i].PosY>=enmeyPlane[i].shootPosY && enmeyPlane[i].shootFlag==1){//敌机发射子弹的点
        //     createOneEnmeyBullet(&enmeyPlane[i]);
        //     enmeyPlane[i].shootFlag=0;
        // }

        

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
                    if(enmeyPlane[i].PosY>=myplane.PosY-20-rand()%20){//敌机转折点
                        enmeyPlane[i].route.routeCnt=1;
                        if(enmeyPlane[i].shootFlag==1){
                            createOneEnmeyBullet(&enmeyPlane[i]);
                            enmeyPlane[i].shootFlag=0;
                        }
                    }
                    switch (enmeyPlane[i].route.route0)
                    {
                        case DOWN:
                                enmeyPlane[i].PosX += 0;
                                enmeyPlane[i].PosY += 5;
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
                else if(enmeyPlane[i].route.routeCnt==1){//敌机动画部分
                    if(enmeyPlane[i].type==1){
                        enmeyPlane[i].PosX += 0;
                        enmeyPlane[i].PosY += 0;
                        if(enmeyPlane[i].attitude<4){
                            enmeyPlane[i].attitude+=1;
                            if(enmeyPlane[i].attitude==4)
                                enmeyPlane[i].route.routeCnt=2;
                        }
                    }
                    else
                        enmeyPlane[i].route.routeCnt=2;
                }
                else if(enmeyPlane[i].route.routeCnt==2){
                        switch (enmeyPlane[i].route.route1)
                        {
                            case UP:
                                    enmeyPlane[i].PosX += 0;
                                    enmeyPlane[i].PosY -= 4;
                                    break;
                            case UP_LEFT:
                                    enmeyPlane[i].PosX -= 2;
                                    enmeyPlane[i].PosY -= 3;
                                    break;
                            case UP_RIGHT:
                                    enmeyPlane[i].PosX += 2;
                                    enmeyPlane[i].PosY -= 3;
                                    break;
                            case DOWN:
                                    enmeyPlane[i].PosX += 0;
                                    enmeyPlane[i].PosY += 5;
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
                }
            else
                enmeyPlane[i].FpsCnt+=1;
        } 
    }
}

void enmeyPlaneDraw(uint8_t* spriteRamAddr){
    for(int i=0;i<ENEMY_NUMMAX;i++){
        if(enmeyPlane[i].liveFlag!=0){
            uint8_t pallet=0;//调色板
            if(enmeyPlane[i].type==0)
                pallet=0<<4;
            else if(enmeyPlane[i].type==1)
                pallet=2<<4;
            
            switch (enmeyPlane[i].attitude)
            {
                uint8_t num=0;
                case 0://正常向下
                    num=0x40;
                    writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num+1,pallet);
                    writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY-8,num+2,pallet);
                    (*spriteRamAddr)+=3;
                    break;

                case 1://
                    num=0x43;
                    writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY-8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;
                case 2://
                    num=0x45;
                    writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num,pallet|0x40);
                    // writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY-8,num+1,pallet);
                    (*spriteRamAddr)+=2;
                    break;
                case 3://
                    num=0x46;
                    writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY+8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;
                case 4://
                    num=0x48;
                    writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX,enmeyPlane[i].PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+4,enmeyPlane[i].PosY+8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;

            default:
                break;
            }
            // else if(enmeyPlane[i].type==2){
            //     uint8_t num=0x90;
            //     writeOneSprite((*spriteRamAddr)+0,enmeyPlane[i].PosX+0,enmeyPlane[i].PosY+0,num,0x10);
            //     writeOneSprite((*spriteRamAddr)+1,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY+0,num+1,0x10);
            //     writeOneSprite((*spriteRamAddr)+2,enmeyPlane[i].PosX+0,enmeyPlane[i].PosY+8,num+2,0x10);
            //     writeOneSprite((*spriteRamAddr)+3,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY+8,num+3,0x10);
            //     writeOneSprite((*spriteRamAddr)+4,enmeyPlane[i].PosX+0,enmeyPlane[i].PosY+16,num+4,0x10);
            //     writeOneSprite((*spriteRamAddr)+5,enmeyPlane[i].PosX+8,enmeyPlane[i].PosY+16,num+5,0x10);
            //     writeOneSprite((*spriteRamAddr)+6,enmeyPlane[i].PosX-8,enmeyPlane[i].PosY+4,num+6,0x10);
            //     writeOneSprite((*spriteRamAddr)+7,enmeyPlane[i].PosX+16,enmeyPlane[i].PosY+4,num+6,0x50);
            //     (*spriteRamAddr)+=8;
            // }
            
        }
    }
}

//中型敌机的绘制,只有一架
void M_enmeyPlaneDraw(uint8_t* spriteRamAddr,M_PLANEType* M_enmeyPlane){
    uint8_t atti = AHBPLANE->Attitude;
    uint8_t posx = AHBPLANE->PosX_out;
	uint8_t posy = AHBPLANE->PosY_out;
    switch (atti)
    {
        case 0://下
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0x94,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+1,posx+ 8, posy+ 0,0x95,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+2,posx+ 0, posy+ 7,0x92,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+3,posx+ 8, posy+ 7,0x93,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+4,posx+ 0, posy+14,0x90,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+5,posx+ 8, posy+14,0x91,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+6,posx- 8, posy+10,0x96,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+7,posx+16, posy+10,0x96,0x20|0xC0);
            (*spriteRamAddr)+=8;
            break;
        case 1://右下
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0xa1,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+1,posx+ 6, posy+ 6,0xa0,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+2,posx- 6, posy- 6,0xa2,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+3,posx- 2, posy+ 7,0x9e,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+4,posx+ 7, posy- 2,0x9f,0x20|0x80);
            (*spriteRamAddr)+=8;
            break;
        case 2://右
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0x9B,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+1,posx+ 8, posy+ 0,0x99,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+2,posx+16, posy+ 0,0x97,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+3,posx+ 0, posy+ 7,0x9C,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+4,posx+ 8, posy+ 7,0x9A,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+5,posx+16, posy+ 7,0x98,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+6,posx+10, posy- 7,0x9D,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+7,posx+10, posy+15,0x9D,0x20|0xC0);
            (*spriteRamAddr)+=8;
            break;
        case 3://右上
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0xA1,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+1,posx+ 6, posy- 6,0xa0,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+2,posx- 6, posy+ 6,0xa2,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+3,posx- 2, posy- 7,0x9e,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+4,posx+ 7, posy+ 1,0x9f,0x20|0x00);
            (*spriteRamAddr)+=5;
            break;
        case 4://上
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0x94,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+1,posx+ 8, posy+ 0,0x95,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+2,posx+ 0, posy- 7,0x92,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+3,posx+ 8, posy- 7,0x93,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+4,posx+ 0, posy-14,0x90,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+5,posx+ 8, posy-14,0x91,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+6,posx- 8, posy-10,0x96,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+7,posx+16, posy-10,0x96,0x20|0x40);
            (*spriteRamAddr)+=8;
            break;
        case 5://左上
            // writeOneSprite( 0,20- 0, 100- 0,0xa1,0x20|0x40);
            // writeOneSprite( 1,20- 6, 100- 6,0xa0,0x20|0x40);
            // writeOneSprite( 2,20+ 6, 100+ 6,0xa2,0x20|0x40);
            // writeOneSprite( 3,20+ 2, 100- 7,0x9e,0x20|0x40);
            // writeOneSprite( 4,20- 7, 100+ 1,0x9f,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+0,posx- 0, posy- 0,0xa1,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+1,posx- 6, posy- 6,0xa0,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+2,posx+ 6, posy+ 6,0xa2,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+3,posx+ 2, posy- 7,0x9e,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+4,posx- 7, posy+ 1,0x9f,0x20|0x40);
            (*spriteRamAddr)+=5;
            break;
        case 6://左
            writeOneSprite((*spriteRamAddr)+0,posx- 0, posy+ 0,0x9B,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+1,posx- 8, posy+ 0,0x99,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+2,posx-16, posy+ 0,0x97,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+3,posx- 0, posy+ 7,0x9C,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+4,posx- 8, posy+ 7,0x9A,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+5,posx-16, posy+ 7,0x98,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+6,posx-10, posy- 7,0x9D,0x20|0x00);
            writeOneSprite((*spriteRamAddr)+7,posx-10, posy+15,0x9D,0x20|0x80);
            (*spriteRamAddr)+=8;
            break;
        case 7://左下
            writeOneSprite((*spriteRamAddr)+0,posx- 0, posy- 0,0xA1,0x20|0xC0);
            writeOneSprite((*spriteRamAddr)+1,posx- 6, posy+ 6,0xa0,0x20|0xC0);
            writeOneSprite((*spriteRamAddr)+2,posx+ 6, posy- 6,0xa2,0x20|0xC0);
            writeOneSprite((*spriteRamAddr)+3,posx+ 2, posy+ 7,0x9e,0x20|0xC0);
            writeOneSprite((*spriteRamAddr)+4,posx- 7, posy- 1,0x9f,0x20|0xC0);
            (*spriteRamAddr)+=5;
            break;
        case 8://下
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0x94,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+1,posx+ 8, posy+ 0,0x95,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+2,posx+ 0, posy+ 7,0x92,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+3,posx+ 8, posy+ 7,0x93,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+4,posx+ 0, posy+14,0x90,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+5,posx+ 8, posy+14,0x91,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+6,posx- 8, posy+10,0x96,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+7,posx+16, posy+10,0x96,0x20|0xC0);
            (*spriteRamAddr)+=8;
            break;
    default:
            writeOneSprite((*spriteRamAddr)+0,posx+ 0, posy+ 0,0x94,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+1,posx+ 8, posy+ 0,0x95,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+2,posx+ 0, posy+ 7,0x92,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+3,posx+ 8, posy+ 7,0x93,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+4,posx+ 0, posy+14,0x90,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+5,posx+ 8, posy+14,0x91,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+6,posx- 8, posy+10,0x96,0x20|0x80);
            writeOneSprite((*spriteRamAddr)+7,posx+16, posy+10,0x96,0x20|0xC0);
            (*spriteRamAddr)+=8;
            break;
    }
    // for(int i=0;i<M_ENEMY_NUMMAX;i++){
    //     if(M_enmeyPlane[i].liveFlag!=0){
    //         uint8_t pallet=2<<4;//调色板
    //         uint8_t atti = AHBPLANE->Attitude;
    //         switch (M_enmeyPlane[i].attitude)
    //         {
    //             case 0://下
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0x94,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 0,0x95,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 7,0x92,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 7,0x93,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+14,0x90,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+14,0x91,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY+10,0x96,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY+10,0x96,0x20|0xC0);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //             case 1://右下
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0xa1,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 6, M_enmeyPlane[i].PosY+ 6,0xa0,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX- 6, M_enmeyPlane[i].PosY- 6,0xa2,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX- 2, M_enmeyPlane[i].PosY+ 7,0x9e,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 7, M_enmeyPlane[i].PosY- 2,0x9f,0x20|0x80);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //             case 2://右
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0x9B,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 0,0x99,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY+ 0,0x97,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 7,0x9C,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 7,0x9A,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY+ 7,0x98,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX+10, M_enmeyPlane[i].PosY- 7,0x9D,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX+10, M_enmeyPlane[i].PosY+15,0x9D,0x20|0xC0);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //             case 3://右上
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0xA1,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 6, M_enmeyPlane[i].PosY- 6,0xa0,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX- 6, M_enmeyPlane[i].PosY+ 6,0xa2,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX- 2, M_enmeyPlane[i].PosY- 7,0x9e,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 7, M_enmeyPlane[i].PosY+ 1,0x9f,0x20|0x00);
    //                 (*spriteRamAddr)+=5;
    //                 break;
    //             case 4://上
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0x94,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 0,0x95,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY- 7,0x92,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY- 7,0x93,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY-14,0x90,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY-14,0x91,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY-10,0x96,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY-10,0x96,0x20|0x40);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //             case 5://左上
    //                 // writeOneSprite( 0,20- 0, 100- 0,0xa1,0x20|0x40);
    //                 // writeOneSprite( 1,20- 6, 100- 6,0xa0,0x20|0x40);
    //                 // writeOneSprite( 2,20+ 6, 100+ 6,0xa2,0x20|0x40);
    //                 // writeOneSprite( 3,20+ 2, 100- 7,0x9e,0x20|0x40);
    //                 // writeOneSprite( 4,20- 7, 100+ 1,0x9f,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX- 0, M_enmeyPlane[i].PosY- 0,0xa1,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX- 6, M_enmeyPlane[i].PosY- 6,0xa0,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 6, M_enmeyPlane[i].PosY+ 6,0xa2,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 2, M_enmeyPlane[i].PosY- 7,0x9e,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX- 7, M_enmeyPlane[i].PosY+ 1,0x9f,0x20|0x40);
    //                 (*spriteRamAddr)+=5;
    //                 break;
    //             case 6://左
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX- 0, M_enmeyPlane[i].PosY+ 0,0x9B,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY+ 0,0x99,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX-16, M_enmeyPlane[i].PosY+ 0,0x97,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX- 0, M_enmeyPlane[i].PosY+ 7,0x9C,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY+ 7,0x9A,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX-16, M_enmeyPlane[i].PosY+ 7,0x98,0x20|0x40);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX-10, M_enmeyPlane[i].PosY- 7,0x9D,0x20|0x00);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX-10, M_enmeyPlane[i].PosY+15,0x9D,0x20|0x80);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //             case 7://左下
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX- 0, M_enmeyPlane[i].PosY- 0,0xA1,0x20|0xC0);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX- 6, M_enmeyPlane[i].PosY+ 6,0xa0,0x20|0xC0);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 6, M_enmeyPlane[i].PosY- 6,0xa2,0x20|0xC0);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 2, M_enmeyPlane[i].PosY+ 7,0x9e,0x20|0xC0);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX- 7, M_enmeyPlane[i].PosY- 1,0x9f,0x20|0xC0);
    //                 (*spriteRamAddr)+=5;
    //                 break;
    //             case 8://下
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0x94,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 0,0x95,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 7,0x92,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 7,0x93,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+14,0x90,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+14,0x91,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY+10,0x96,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY+10,0x96,0x20|0xC0);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //         default:
    //                 writeOneSprite((*spriteRamAddr)+0,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 0,0x94,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+1,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 0,0x95,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+2,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+ 7,0x92,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+3,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+ 7,0x93,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+4,M_enmeyPlane[i].PosX+ 0, M_enmeyPlane[i].PosY+14,0x90,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+5,M_enmeyPlane[i].PosX+ 8, M_enmeyPlane[i].PosY+14,0x91,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+6,M_enmeyPlane[i].PosX- 8, M_enmeyPlane[i].PosY+10,0x96,0x20|0x80);
    //                 writeOneSprite((*spriteRamAddr)+7,M_enmeyPlane[i].PosX+16, M_enmeyPlane[i].PosY+10,0x96,0x20|0xC0);
    //                 (*spriteRamAddr)+=8;
    //                 break;
    //         }
    //     }
    // }
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
            else{
                boom[i].FpsCnt=0;
                boom[i].BoomCnt+=1;
                if(boom[i].BoomCnt>=4){
                    // printf("boom[i].FpsCnt=%d\nboom[i].BoomCnt=%d\n",boom[i].FpsCnt,boom[i].BoomCnt);
                    boom[i].liveFlag=0;
                }
            }
        }
    }
}
void boomDraw(uint8_t* spriteRamAddr){
    for(int i=0;i<BOOM_NUMMAX;i++){
        if(boom[i].liveFlag!=0){
            uint8_t step=(boom[i].BoomCnt)<<1;
            writeOneSprite((*spriteRamAddr)+0,boom[i].PosX   ,boom[i].PosY   ,0xe0+step,0x10);
            writeOneSprite((*spriteRamAddr)+1,boom[i].PosX+8 ,boom[i].PosY   ,0xe1+step,0x10);
            writeOneSprite((*spriteRamAddr)+2,boom[i].PosX   ,boom[i].PosY+7 ,0xe1+step,0xD0);
            writeOneSprite((*spriteRamAddr)+3,boom[i].PosX+8 ,boom[i].PosY+7 ,0xe0+step,0xD0);
            (*spriteRamAddr)+=4;
        }
    }
}

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

//碰撞相关函数
void tileMap(uint8_t PosX,uint8_t PosY,hitMapType* hitMap){
    uint8_t gridPosX=(PosX>>3);
    uint8_t gridPosY=PosY>>3;

    uint32_t mask = 1<<(gridPosX);
    hitMap->map[gridPosY]=hitMap->map[gridPosY]|mask;
}
void myPlaneMapCreate(MYPLANEType* myPlane,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    if(myPlane->liveFlag!=0){
        tileMap(myPlane->PosX   ,myPlane->PosY,hitMap);
        tileMap(myPlane->PosX+8 ,myPlane->PosY,hitMap);
        tileMap(myPlane->PosX+16,myPlane->PosY,hitMap);
        tileMap(myPlane->PosX+4 ,myPlane->PosY+8,hitMap);
        tileMap(myPlane->PosX+12,myPlane->PosY+8,hitMap);
    }
}

void bulletsMapCreate(BULLETType* bullet,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<BULLET_NUMMAX;i++){
        if(bullet[i].liveFlag!=0)
            tileMap((bullet[i]).PosX,(bullet[i]).PosY,hitMap);
    }
}

void enemyMapCreate(PLANEType* enmeyPlane,M_PLANEType* M_enmeyPlane,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<ENEMY_NUMMAX;i++){
        if((enmeyPlane+i)->liveFlag!=0){
            tileMap((enmeyPlane+i)->PosX,(enmeyPlane+i)->PosY,hitMap);
            tileMap((enmeyPlane+i)->PosX+8,(enmeyPlane+i)->PosY,hitMap);
            tileMap((enmeyPlane+i)->PosX+4,(enmeyPlane+i)->PosY-8,hitMap);   
        }
    }

    // for (int i = 0; i < M_ENEMY_NUMMAX; i++)//中型飞机
    // {
    //     if((M_enmeyPlane+i)->liveFlag!=0){
    //         tileMap((M_enmeyPlane+i)->PosX+0,(M_enmeyPlane+i)->PosY+0,hitMap);
    //         tileMap((M_enmeyPlane+i)->PosX+8,(M_enmeyPlane+i)->PosY+0,hitMap);
    //         tileMap((M_enmeyPlane+i)->PosX+4,(M_enmeyPlane+i)->PosY-8,hitMap);
    //     }
    // }

    //中型飞机
    if(AHBPLANE->isLive!=0){
        tileMap(AHBPLANE->PosX_out+0,AHBPLANE->PosY_out+0,hitMap);
        tileMap(AHBPLANE->PosX_out+8,AHBPLANE->PosY_out+0,hitMap);
        tileMap(AHBPLANE->PosX_out+4,AHBPLANE->PosY_out-8,hitMap);
    }
}

//我方飞机可以被敌方子弹和敌方飞机摧毁并产生爆炸效果(我方飞机后续可以添加护盾效果,更换调色板表示进行赤红状态,可以承受一次撞击)
void isMyPlaneHit(MYPLANEType* myPlane,hitMapType* enemyPlaneHitMap,hitMapType* enmeyBulletsHitMap,BUFFType* buff,hitMapType* myPlaneHitMap){
    // for(int i=0;i<32;i++){
    //     enemyPlaneHitMap->map[i]=0;
    // }
    // enemyMapCreate(&enmeyPlane,enemyPlaneHitMap);
    if(myPlane->actFlag==1)
        ;
    else{
        uint8_t gridPosX=(myPlane->PosX >>3);
        uint8_t gridPosY=myPlane->PosY >>3;

        //与敌机的撞击测试
        uint32_t isEnemyHitFlag=(
                                    (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                                    (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                                    (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+2)))|
                                    (enemyPlaneHitMap->map[gridPosY+1] & (1<<(gridPosX+0)))|
                                    (enemyPlaneHitMap->map[gridPosY+1] & (1<<(gridPosX+1)))
                                );
        //与敌机子弹的撞击测试
        uint32_t isEnemyBulletsHitFlag=(
                                    (enmeyBulletsHitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                                    (enmeyBulletsHitMap->map[gridPosY+0] & (1<<(gridPosX+1)))|
                                    (enmeyBulletsHitMap->map[gridPosY+0] & (1<<(gridPosX+2)))|
                                    (enmeyBulletsHitMap->map[gridPosY+1] & (1<<(gridPosX+0)))|
                                    (enmeyBulletsHitMap->map[gridPosY+1] & (1<<(gridPosX+1)))
                                );
        
        if(isEnemyBulletsHitFlag==0 && isEnemyHitFlag==0){
            myPlane->liveFlag=myPlane->liveFlag;
        }
        else{
            // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
            createOneBoom(myplane.PosX,myplane.PosY,&boom);
            myPlane->PosX=255;
            myPlane->PosY=239;
            myPlane->liveFlag=0;
        }

        //与buff的撞击测试
        uint8_t buffMapGridPosX=buff->PosX>>3;
        uint8_t buffMapGridPosY=buff->PosY>>3;
        uint32_t isBuffHitFlag=(
                                    (myPlaneHitMap->map[buffMapGridPosY+0] & (1<<(buffMapGridPosX+0)))|
                                    (myPlaneHitMap->map[buffMapGridPosY+0] & (1<<(buffMapGridPosX+1)))|
                                    (myPlaneHitMap->map[buffMapGridPosY+0] & (1<<(buffMapGridPosX+2)))|
                                    (myPlaneHitMap->map[buffMapGridPosY+1] & (1<<(buffMapGridPosX+0)))|
                                    (myPlaneHitMap->map[buffMapGridPosY+1] & (1<<(buffMapGridPosX+1)))
                                );
        if(isBuffHitFlag==0){
        }
        else{
            buff->liveFlag=0;
            buff->PosX=255;
            buff->PosY=239;
            if(buff->buffType==BUFF_POWER&&myPlane->bulletOnceNum<2){
                myPlane->bulletOnceNum+=1;
            }
            else if(buff->buffType==BUFF_HP)
                myPlane->hp+=1;
        }
    }
}

extern uint32_t GameScore;
//敌方飞机只能被我方子弹摧毁
void isEnemyPlaneHit(PLANEType* enmeyPlane,M_PLANEType* M_enmeyPlane,hitMapType hitMap){
    for(int i=0;i<ENEMY_NUMMAX;i++){//小型敌机的碰撞检测
        if((enmeyPlane+i)->liveFlag!=0){
            uint8_t gridPosX=((enmeyPlane+i)->PosX >>3);
            uint8_t gridPosY=((enmeyPlane+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+0)))|
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+1)))|
                (hitMap.map[gridPosY-1] & (1<<(gridPosX+1)))
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
        if(AHBPLANE->isLive!=0){
            AHBPLANE->Hit=0;
            uint8_t gridPosX=AHBPLANE->PosX_out>>3;
            uint8_t gridPosY=AHBPLANE->PosY_out>>3;

            uint32_t isHitFlag = 
            (
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+0)))|
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+1)))|
                (hitMap.map[gridPosY-1] & (1<<(gridPosX+1)))|
                (hitMap.map[gridPosY+0] & (1<<(gridPosX+2)))
            );
            if(isHitFlag==0){
                AHBPLANE->Hit=0;
            }
            else{
                AHBPLANE->Hit=1;
                createOneBoom(AHBPLANE->PosX_out,AHBPLANE->PosY_out,&boom);
            }
        }

    // for (int i = 0; i < M_ENEMY_NUMMAX; i++){//中型敌机的碰撞检测
    //     if((M_enmeyPlane+i)->liveFlag!=0){
    //         uint8_t gridPosX=((M_enmeyPlane+i)->PosX >>3);
    //         uint8_t gridPosY=((M_enmeyPlane+i)->PosY >>3);

    //         uint32_t isHitFlag = 
    //         (
    //             (hitMap.map[gridPosY+0] & (1<<(gridPosX+0)))|
    //             (hitMap.map[gridPosY+0] & (1<<(gridPosX+1)))|
    //             (hitMap.map[gridPosY-1] & (1<<(gridPosX+1)))|
    //             (hitMap.map[gridPosY+0] & (1<<(gridPosX+2)))
    //         );
    //         if(isHitFlag==0){
    //             (M_enmeyPlane+i)->liveFlag=(M_enmeyPlane+i)->liveFlag;
    //         }
    //         else{
    //             if((M_enmeyPlane+i)->hp==0){
    //                 createOneBoom((M_enmeyPlane+i)->PosX,(M_enmeyPlane+i)->PosY,&boom);
    //                 (M_enmeyPlane+i)->liveFlag=0;
    //                 (M_enmeyPlane+i)->PosX=253;
    //                 (M_enmeyPlane+i)->PosY=239;
    //                 GameScore+=50;
    //             }
    //             else{
    //                 createOneBoom((M_enmeyPlane+i)->PosX,(M_enmeyPlane+i)->PosY,&boom);
    //                 (M_enmeyPlane+i)->hp--;
    //             }
    //         }
    //     }
    // }
}

//我方子弹可以被敌方子弹和敌方飞机摧毁(我方子弹最后可以添加无敌效果)
// void isBulletsHit(BULLETType* bullet,hitMapType hitMap){
void isBulletsHit(BULLETType* bullet,hitMapType* enemyPlaneHitMap,hitMapType* enmeyBulletsHitMap){
    for(int i=0;i<BULLET_NUMMAX;i++){
        if((bullet+i)->liveFlag!=0){
            uint8_t gridPosX=((bullet+i)->PosX >>3);
            uint8_t gridPosY=((bullet+i)->PosY >>3);

            uint32_t isHitFlag = 
            (
                (enemyPlaneHitMap->map[gridPosY+0] & (1<<(gridPosX+0)))|
                (enmeyBulletsHitMap->map[gridPosY+0] & (1<<(gridPosX+0)))
            );
            if(isHitFlag==0){
                (bullet+i)->liveFlag=(bullet+i)->liveFlag;
            }
            else{
                // printf("hitMap->map[gridPosY+0]==%x",enemyPlaneHitMap.map[gridPosY+0]);
                (bullet+i)->liveFlag=0;
                (bullet+i)->PosX=253;
                (bullet+i)->PosY=239;
                GameShootDownCnt+=1;
            }
        }
    }
} 

void gameFPSDraw(uint32_t fps,uint8_t* spriteRamAddr){
    uint8_t ge = fps%10;
    uint8_t shi = (fps/10)%10;
    uint8_t bai = (fps/100)%10;
    uint8_t qian = (fps/1000)%10;

    writeOneSprite((*spriteRamAddr)+0,220+0 ,220,qian,0x30);
    writeOneSprite((*spriteRamAddr)+1,220+8 ,220,bai,0x30);
    writeOneSprite((*spriteRamAddr)+2,220+16,220,shi,0x30);
    writeOneSprite((*spriteRamAddr)+3,220+24,220,ge,0x30);
}

void buffInit(BUFFType* buff){
    buff->liveFlag=0;
}

void createOneBuff(uint8_t PosX,uint8_t PosY,uint8_t buffType,BUFFType* buff){
    if(buff->liveFlag==0){
        buff->liveFlag=1;
        buff->PosX=PosX;
        buff->PosY=PosY;
        buff->buffType=buffType;
        buff->FpsCnt=0;
    }
}

void updateBuffData(BUFFType* buff){
    if(buff->liveFlag!=0){

        if(buff->FpsCnt>=BUFF_FPS){
            buff->PosY+=1;
            buff->FpsCnt=0;
            if(buff->PosY>BOTTOM_LINE)//超出边界
                buff->liveFlag=0;
        }   
        else
            buff->FpsCnt+=1;
    }
}

void buffDraw(uint8_t* spriteRamAddr){
    if(buff.liveFlag!=0){
        if(buff.buffType==BUFF_POWER){
            writeOneSprite((*spriteRamAddr)+0,buff.PosX+0,buff.PosY-7,BUFF_TYPE0_0,0x00);
            writeOneSprite((*spriteRamAddr)+1,buff.PosX+0,buff.PosY+0,BUFF_TYPE0_1,0x00);
            writeOneSprite((*spriteRamAddr)+2,buff.PosX+8,buff.PosY+0,BUFF_TYPE0_2,0x00);
            *spriteRamAddr+=3;
        }
        else if(buff.buffType==BUFF_HP){
            writeOneSprite((*spriteRamAddr)+0,buff.PosX+0,buff.PosY-7,BUFF_TYPE1_0,0x30);
            writeOneSprite((*spriteRamAddr)+1,buff.PosX+0,buff.PosY+0,BUFF_TYPE1_1,0x30);
            writeOneSprite((*spriteRamAddr)+2,buff.PosX+8,buff.PosY+0,BUFF_TYPE1_2,0x30);
            *spriteRamAddr+=3;
        }
    }
}

//敌方子弹的相关函数
void enmeyBulletInit(void){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++)
        enmeyBullets[i].liveFlag=0;
}

void createOneEnmeyBullet(PLANEType* enmeyPlane){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if(enmeyBullets[i].liveFlag==0){
            enmeyBullets[i].PosX=enmeyPlane->PosX+8;
            enmeyBullets[i].PosY=enmeyPlane->PosY-8;
            enmeyBullets[i].liveFlag=1;

            int16_t enemy_x = (enmeyPlane->PosX);
            int16_t enemy_y = (enmeyPlane->PosY);
            int16_t myplane_x = myplane.PosX;
            int16_t myplane_y = myplane.PosY;

            int16_t PosX_SUB = myplane.PosX-(enmeyPlane->PosX);
            int16_t PosY_SUB = myplane.PosY-(enmeyPlane->PosY);
            float PosX_SUB_Abs= (PosX_SUB<0)?(-PosX_SUB):PosX_SUB;//绝对值
            float PosY_SUB_Abs= (PosY_SUB<0)?(-PosY_SUB):PosY_SUB;//绝对值
            float tanValue = PosY_SUB_Abs/PosX_SUB_Abs;
            for(int j=0;j<ANGLE_NUMMAX;j++){
                if(tan_array[j]-tanValue>=0){
                    enmeyBullets[i].PosX_ADD=cos_array[j];
                    enmeyBullets[i].PosY_ADD=sin_array[j];
                    if(PosX_SUB<0)
                        enmeyBullets[i].PosX_ADD=-enmeyBullets[i].PosX_ADD;
                    if(PosY_SUB<0)
                        enmeyBullets[i].PosY_ADD=-enmeyBullets[i].PosY_ADD;
                    break;
                }
            }
            // enmeyBullets[i].PosX_ADD=1;
            // enmeyBullets[i].PosY_ADD=1;
            break;
        }
    }
}

void updateEnemyBulletData(void){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if(enmeyBullets[i].FpsCnt==ENEMY_BULLET_FPS_MAX){
            enmeyBullets[i].FpsCnt=0;
            if(enmeyBullets[i].liveFlag!=0){
                enmeyBullets[i].PosY+=enmeyBullets[i].PosY_ADD;
                enmeyBullets[i].PosX+=enmeyBullets[i].PosX_ADD;
                if(enmeyBullets[i].PosY>BOTTOM_LINE||enmeyBullets[i].PosY<TOP_LINE)//超出边界
                    enmeyBullets[i].liveFlag=0;
                else if(enmeyBullets[i].PosX>RIGHT_LINE||enmeyBullets[i].PosX<LEFT_LINE)//超出边界
                    enmeyBullets[i].liveFlag=0;
            }
        }
        else
            enmeyBullets[i].FpsCnt+=1;
    }
}

void enemyBulletsMapCreate(BULLETType* enmeyBullet,hitMapType* hitMap){
    for(int i=0;i<30;i++)
        hitMap->map[i]=0;
    for (int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if(enmeyBullets[i].liveFlag!=0)
            tileMap((enmeyBullets[i]).PosX,(enmeyBullets[i]).PosY,hitMap);
    }
}

void enmeyBulletDraw(uint8_t* spriteRamAddr){
    for(int i=0;i<ENEMY_BULLETS_NUMMAX;i++){
        if(enmeyBullets[i].liveFlag!=0){
            writeOneSprite((*spriteRamAddr),enmeyBullets[i].PosX,enmeyBullets[i].PosY,0x30,0x10);
            (*spriteRamAddr)+=1;
        }
    }
}

//这里的start应该是先置1后马上置0，目前计划放在定时中断中
void myPlaneAct(uint8_t* start){
    if(myplane.actFlag==0){
        if(*start==1){
            myplane.actFlag=1;
            myplane.actFpsCnt=0;
            myplane.attitude=1;
            *start=0;
            LED_toggle(3);
        }
    }
    else{
        if((myplane.actFpsCnt== MYPLANE_ACT_FPSCNT_MAX>>1) || (myplane.actFpsCnt==MYPLANE_ACT_FPSCNT_MAX)){
            if(myplane.attitude<=4)
                myplane.PosY-=1;
            else
                myplane.PosY+=1;
        }
        
        if(myplane.actFpsCnt>=MYPLANE_ACT_FPSCNT_MAX){
            myplane.actFpsCnt=0;
            
            if(myplane.attitude>=MYPLANE_ACT_ATTITUDE_MAX){
                myplane.actFlag=0;
                myplane.attitude=0;
            }
            else{
                myplane.attitude+=1;
            }
        }
        else
            myplane.actFpsCnt+=1;
    }
}

void myPlaneDraw(uint8_t PosX,uint8_t PosY,uint8_t* spriteRamAddr){
    uint8_t ram_num=(*spriteRamAddr);
    uint8_t spriteRamAddr_add;
    if(myplane.liveFlag!=0){
        switch (myplane.attitude)
        {
            case 0://正常形式&动画第0帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_0_0,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_0_1,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_0_2,0x70);
                writeOneSprite(ram_num+3,PosX+4,PosY+8,MYPLANE_ACT_0_3,0x30);
                writeOneSprite(ram_num+4,PosX+12,PosY+8,MYPLANE_ACT_0_4,0x30);
            break;
            case 1://动画第1帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_1_0,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_1_1,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_1_2,0x70);
                writeOneSprite(ram_num+3,PosX+4,PosY+8,MYPLANE_ACT_1_3,0x30);
                writeOneSprite(ram_num+4,PosX+12,PosY+8,MYPLANE_ACT_1_4,0x30);
            break;
            case 2://动画第2帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=3;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_2_0,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_2_1,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_2_2,0x70);
            break;
            case 3://动画第4帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=4;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_3_1,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_3_2,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_3_3,0x70);
                writeOneSprite(ram_num+3,PosX+8,PosY-8,MYPLANE_ACT_3_0,0x70);
            break;
            case 4://动画第5帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=7;
                writeOneSprite(ram_num+0,PosX+4,PosY-16,MYPLANE_ACT_4_0,0x30);
                writeOneSprite(ram_num+1,PosX+12,PosY-16,MYPLANE_ACT_4_1,0x30);
                writeOneSprite(ram_num+2,PosX+4,PosY-8,MYPLANE_ACT_4_2,0x30);
                writeOneSprite(ram_num+3,PosX+12,PosY-8,MYPLANE_ACT_4_3,0x30);
                writeOneSprite(ram_num+4,PosX+0,PosY+0,MYPLANE_ACT_4_4,0x30);
                writeOneSprite(ram_num+5,PosX+8,PosY+0,MYPLANE_ACT_4_5,0x30);
                writeOneSprite(ram_num+6,PosX+16,PosY+0,MYPLANE_ACT_4_6,0x30);
            break;
            case 5://动画第6帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=6;
                writeOneSprite(ram_num+0,PosX+4,PosY-8,MYPLANE_ACT_5_0,0x30);
                writeOneSprite(ram_num+1,PosX+12,PosY-8,MYPLANE_ACT_5_1,0x70);
                writeOneSprite(ram_num+2,PosX+0,PosY+0,MYPLANE_ACT_5_2,0x30);
                writeOneSprite(ram_num+3,PosX+8,PosY+0,MYPLANE_ACT_5_3,0x30);
                writeOneSprite(ram_num+4,PosX+16,PosY+0,MYPLANE_ACT_5_4,0x70);
            break;
            case 6://动画第7帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=3;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_2_0,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_2_1,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_2_2,0x70);
            break;
            case 7://正常形式&动画第0帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,PosX+0,PosY,MYPLANE_ACT_0_0,0x30);
                writeOneSprite(ram_num+1,PosX+8,PosY,MYPLANE_ACT_0_1,0x30);
                writeOneSprite(ram_num+2,PosX+16,PosY,MYPLANE_ACT_0_2,0x70);
                writeOneSprite(ram_num+3,PosX+4,PosY+8,MYPLANE_ACT_0_3,0x30);
                writeOneSprite(ram_num+4,PosX+12,PosY+8,MYPLANE_ACT_0_4,0x30);
            break;
        default:
            break;
        }
        *spriteRamAddr+=spriteRamAddr_add;
    }
}

/*******************游戏开始界面显示******************************/
extern uint8_t GAME_LOGO_1942[5][18];
extern uint8_t GAME_START_CHAR[8];
extern uint8_t GAME_STOP_CHAR[8];
extern uint8_t GAME_VERSION[12];
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
        writeOneSprite(*arrayCnt,endInterFaceArray[*arrayCnt][0],endInterFaceArray[*arrayCnt][1],endInterFaceArray[*arrayCnt][2],0x20);
        (*arrayCnt)+=1;
        LED_toggle(5);
        *DrawFlag=0;
    }
}