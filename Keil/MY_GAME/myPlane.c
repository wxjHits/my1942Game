#include "myPlane.h"
#include "spriteRam.h"
#include "led.h"

void myPlane_Init(MYPLANEType* myPlane){
    myPlane->PosX=120;
    myPlane->PosY=180;
    myPlane->liveFlag=1;
    myPlane->actFlag=0;
    myPlane->actFpsCnt=0;
    myPlane->attitude=0;
    myPlane->bulletOnceNum=1;
    myPlane->hp=1;
}
extern uint32_t GameShootBulletsCnt;//发射子弹的数量
void myPlane_createOneBullet(MYPLANEType* myPlane,BULLETType* mybullet){
    if(myPlane->liveFlag!=0){
        if(myPlane->bulletOnceNum==0){
            for(int i=0;i<4;i++){
                if((mybullet+i)->liveFlag==0){
                    (mybullet+i)->PosX=myPlane->PosX+8;
                    (mybullet+i)->PosY=myPlane->PosY-8;
                    (mybullet+i)->liveFlag=1;
                    GameShootBulletsCnt+=1;
                    break;
                }
            }
        }
        else if(myPlane->bulletOnceNum==1){
            for(int i=0;i<8;i++){
                if((mybullet+i)->liveFlag==0&&(mybullet+i+1)->liveFlag==0){
                    (mybullet+i)->PosX=myPlane->PosX+4;
                    (mybullet+i)->PosY=myPlane->PosY-8;
                    (mybullet+i)->liveFlag=1;
                    (mybullet+i+1)->PosX=myPlane->PosX+12;
                    (mybullet+i+1)->PosY=myPlane->PosY-8;
                    (mybullet+i+1)->liveFlag=1;
                    GameShootBulletsCnt+=2;
                    break;
                }
            }
        }
        else if(myPlane->bulletOnceNum==2){
            for(int i=0;i<16;i++){
                if(mybullet->liveFlag==0&&(mybullet+i+1)->liveFlag==0&&(mybullet+i+2)->liveFlag==0&&(mybullet+i+3)->liveFlag==0){
                    mybullet->PosX=myPlane->PosX-4;
                    mybullet->PosY=myPlane->PosY-8;
                    mybullet->liveFlag=1;
                    (mybullet+i+1)->PosX=myPlane->PosX+4;
                    (mybullet+i+1)->PosY=myPlane->PosY-8;
                    (mybullet+i+1)->liveFlag=1;
                    (mybullet+i+2)->PosX=myPlane->PosX+12;
                    (mybullet+i+2)->PosY=myPlane->PosY-8;
                    (mybullet+i+2)->liveFlag=1;
                    (mybullet+i+3)->PosX=myPlane->PosX+20;
                    (mybullet+i+3)->PosY=myPlane->PosY-8;
                    (mybullet+i+3)->liveFlag=1;
                    GameShootBulletsCnt+=4;
                    break;
                }
            }
        }
    }
}
// void myPlane_mapCreate(MYPLANEType* myPlane,hitMapType* hitMap);
// void myPlane_isHit(MYPLANEType* myPlane,hitMapType* enemyPlaneHitMap,hitMapType* enmeyBulletsHitMap,BUFFType* buff,hitMapType* myPlaneHitMap);
void myPlane_Act(MYPLANEType* myPlane,uint8_t* start){
    if(myPlane->actFlag==0){
        if(*start==1){
            myPlane->actFlag=1;
            myPlane->actFpsCnt=0;
            myPlane->attitude=1;
            *start=0;
        }
    }
    else{
        if((myPlane->actFpsCnt== MYPLANE_ACT_FPSCNT_MAX>>1) || (myPlane->actFpsCnt==MYPLANE_ACT_FPSCNT_MAX)){
            if(myPlane->attitude<=4)
                myPlane->PosY-=3;
            else
                myPlane->PosY+=3;
        }
        
        if(myPlane->actFpsCnt>=MYPLANE_ACT_FPSCNT_MAX){
            myPlane->actFpsCnt=0;
            
            if(myPlane->attitude>=MYPLANE_ACT_ATTITUDE_MAX){
                myPlane->actFlag=0;
                myPlane->attitude=0;
            }
            else{
                myPlane->attitude+=1;
            }
        }
        else
            myPlane->actFpsCnt+=1;
    }
}

extern uint8_t pifuNum;
void myPlane_Draw(MYPLANEType* myPlane,uint8_t* spriteRamAddr){
    uint8_t ram_num=(*spriteRamAddr);
    uint8_t spriteRamAddr_add;
    uint8_t pallet=0;
    if (pifuNum==0)
        pallet = 0x00|0x08;
    else if(pifuNum==1)
        pallet = 0x20|0x08;
    else if(pifuNum==2)
        pallet = 0x30|0x00;
    
    // uint8_t pallet = 0x00|0x08;
    // uint8_t pallet = 0x20|0x08;
    // uint8_t pallet = 0x30|0x00;
    if(myPlane->liveFlag!=0){
        switch (myPlane->attitude)
        {
            case 0://正常形式&动画第0帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY  ,MYPLANE_ACT_0_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY  ,MYPLANE_ACT_0_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY  ,MYPLANE_ACT_0_2,0x40|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+4 ,myPlane->PosY+7,MYPLANE_ACT_0_3,0x00|pallet);
                writeOneSprite(ram_num+4,myPlane->PosX+12,myPlane->PosY+7,MYPLANE_ACT_0_4,0x00|pallet);
            break;
            case 1://动画第1帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY  ,MYPLANE_ACT_1_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY  ,MYPLANE_ACT_1_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY  ,MYPLANE_ACT_1_2,0x40|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+4 ,myPlane->PosY+7,MYPLANE_ACT_1_3,0x00|pallet);
                writeOneSprite(ram_num+4,myPlane->PosX+12,myPlane->PosY+7,MYPLANE_ACT_1_4,0x00|pallet);
            break;
            case 2://动画第2帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=3;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY,MYPLANE_ACT_2_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY,MYPLANE_ACT_2_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY,MYPLANE_ACT_2_2,0x40|pallet);
            break;
            case 3://动画第4帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=4;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY+0,MYPLANE_ACT_3_1,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY+0,MYPLANE_ACT_3_2,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY+0,MYPLANE_ACT_3_3,0x40|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+8 ,myPlane->PosY-7,MYPLANE_ACT_3_0,0x40|pallet);
            break;
            case 4://动画第5帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=7;
                writeOneSprite(ram_num+0,myPlane->PosX+4 ,myPlane->PosY-15,MYPLANE_ACT_4_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+12,myPlane->PosY-15,MYPLANE_ACT_4_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+4 ,myPlane->PosY-7 ,MYPLANE_ACT_4_2,0x00|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+12,myPlane->PosY-7 ,MYPLANE_ACT_4_3,0x00|pallet);
                writeOneSprite(ram_num+4,myPlane->PosX+0 ,myPlane->PosY+0 ,MYPLANE_ACT_4_4,0x00|pallet);
                writeOneSprite(ram_num+5,myPlane->PosX+8 ,myPlane->PosY+0 ,MYPLANE_ACT_4_5,0x00|pallet);
                writeOneSprite(ram_num+6,myPlane->PosX+16,myPlane->PosY+0 ,MYPLANE_ACT_4_6,0x00|pallet);
            break;
            case 5://动画第6帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=6;
                writeOneSprite(ram_num+0,myPlane->PosX+4 ,myPlane->PosY-7,MYPLANE_ACT_5_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+12,myPlane->PosY-7,MYPLANE_ACT_5_1,0x40|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+0 ,myPlane->PosY+0,MYPLANE_ACT_5_2,0x00|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+8 ,myPlane->PosY+0,MYPLANE_ACT_5_3,0x00|pallet);
                writeOneSprite(ram_num+4,myPlane->PosX+16,myPlane->PosY+0,MYPLANE_ACT_5_4,0x40|pallet);
            break;
            case 6://动画第7帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=3;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY,MYPLANE_ACT_2_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY,MYPLANE_ACT_2_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY,MYPLANE_ACT_2_2,0x40|pallet);
            break;
            case 7://正常形式&动画第0帧
                // uint8_t sprite_num = 0x33;
                spriteRamAddr_add=5;
                writeOneSprite(ram_num+0,myPlane->PosX+0 ,myPlane->PosY  ,MYPLANE_ACT_0_0,0x00|pallet);
                writeOneSprite(ram_num+1,myPlane->PosX+8 ,myPlane->PosY  ,MYPLANE_ACT_0_1,0x00|pallet);
                writeOneSprite(ram_num+2,myPlane->PosX+16,myPlane->PosY  ,MYPLANE_ACT_0_2,0x40|pallet);
                writeOneSprite(ram_num+3,myPlane->PosX+4 ,myPlane->PosY+7,MYPLANE_ACT_0_3,0x00|pallet);
                writeOneSprite(ram_num+4,myPlane->PosX+12,myPlane->PosY+7,MYPLANE_ACT_0_4,0x00|pallet);
            break;
        default:
            break;
        }
        *spriteRamAddr+=spriteRamAddr_add;
    }
}

extern const uint8_t MYPLANE_BULLET_NUMMAX;

void myPlane_bulletInit(BULLETType* mybullet){
    for(int i=0;i<MYPLANE_BULLET_NUMMAX;i++)
        (mybullet+i)->liveFlag=0;
}
void myPlane_updateBulletData(BULLETType* mybullet){
    for(int i=0;i<MYPLANE_BULLET_NUMMAX;i++){
        if((mybullet+i)->liveFlag!=0){
            (mybullet+i)->PosY-=MYBULLET_SPEED;
            if((mybullet+i)->PosY<5)//超出边界
                (mybullet+i)->liveFlag=0;
        }
    }
}
void myPlane_bulletDraw(BULLETType* mybullet,uint8_t* spriteRamAddr){
    for(int i=0;i<MYPLANE_BULLET_NUMMAX;i++){
        if((mybullet+i)->liveFlag!=0){
            writeOneSprite((*spriteRamAddr),(mybullet+i)->PosX,(mybullet+i)->PosY,0x31,0x10);
            (*spriteRamAddr)+=1;
        }
    }
}
