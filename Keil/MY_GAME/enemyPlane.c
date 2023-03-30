#include "stdlib.h"
#include "enemyPlane.h"
#include "enemyBullet.h"
#include "gameStruct.h"
#include "spriteRam.h"
#include "uart.h"
#include "led.h"

/*****灰色小飞机*****/
extern const uint8_t S_GREY_NUMMAX;
void s_grey_planeInit(S_GREY_PLANEType* plane){
    for (int i = 0; i < S_GREY_NUMMAX; i++){
        (plane+i)->PosX=0;
        (plane+i)->PosY=0;
        (plane+i)->liveFlag=0;
        (plane+i)->hp=1;
        (plane+i)->FpsCnt=0;
        (plane+i)->shootFlag=0;
        (plane+i)->isBack=1;
    }
}
void s_grey_createOnePlane(S_GREY_PLANEType* plane,S_GREY_PLANEType* planeParameter,int16_t myPlanePosX,int16_t myPlanePosY){
    for (int i = 0; i < S_GREY_NUMMAX; i++){
        if((plane+i)->liveFlag==0){
            (plane+i)->hp=1;
            (plane+i)->liveFlag=1;
            (plane+i)->actDraw=0;
            (plane+i)->FpsCnt=0;
            (plane+i)->route=0;
            (plane+i)->isBack=planeParameter->isBack;
            (plane+i)->shootFlag=1;
            (plane+i)->PosX = planeParameter->PosX;
            (plane+i)->PosY = TOP_LINE+5;

            (plane+i)->routeOneDir = planeParameter->routeOneDir;
            if((plane+i)->routeOneDir==DOWN){
                (plane+i)->routeOneDir_AddX=0;
                (plane+i)->routeOneDir_AddY=3;
                uint8_t randnum = rand()%2;
                if(randnum==0)
                    (plane+i)->routeTwoDir=UP_LEFT;
                else
                    (plane+i)->routeTwoDir=UP_RIGHT;
            }
            else if((plane+i)->routeOneDir==DOWN_LEFT){
                (plane+i)->routeOneDir_AddX=-2;
                (plane+i)->routeOneDir_AddY=3;
                (plane+i)->routeTwoDir=UP_LEFT;
            }
            else if((plane+i)->routeOneDir==DOWN_RIGHT){
                (plane+i)->routeOneDir_AddX=2;
                (plane+i)->routeOneDir_AddY=3;
                (plane+i)->routeTwoDir=UP_RIGHT;
            }
            break;
        }
    }
}
void s_grey_movePlane(S_GREY_PLANEType* plane,MYPLANEType* myPlane,BULLETType* bullet){
    for(int i=0;i<S_GREY_NUMMAX;i++){
        if((plane+i)->liveFlag!=0){
            if((plane+i)->FpsCnt==S_GREY_FPSMAX){
                (plane+i)->FpsCnt=0;
                if  ((plane+i)->PosX<LEFT_LINE||(plane+i)->PosX>RIGHT_LINE||(plane+i)->PosY<TOP_LINE||(plane+i)->PosY>BOTTOM_LINE){
                    (plane+i)->liveFlag=0;//出界检测
                    (plane+i)->PosX=0;
                    (plane+i)->PosY=0;
                }
                else if((plane+i)->route==0){//第一段
                    if((plane+i)->PosY>=myPlane->PosY-20-rand()%20){//到达转折点
                        if((plane+i)->shootFlag==1){//发射子弹
                            // s_grey_createOneEnmeyBullet((plane+i));
                            s_grey_createOneEnmeyBullet(bullet,(plane+i),myPlane);
                            (plane+i)->shootFlag=0;
                        }
                        
                        //确定第二段的方向，如果是不返回类型
                        if((plane+i)->isBack==0){
                            // uint
                            if((plane+i)->PosX<myPlane->PosX && (myPlane->PosX-((plane+i)->PosX))<60&& (myPlane->PosX-((plane+i)->PosX))>0)
                                (plane+i)->routeTwoDir=DOWN_RIGHT;
                            else if((plane+i)->PosX>myPlane->PosX && (((plane+i)->PosX)-myPlane->PosX)<50&& (((plane+i)->PosX)-myPlane->PosX)>0)
                                (plane+i)->routeTwoDir=DOWN_LEFT;
                            else
                                (plane+i)->routeTwoDir=DOWN;
                        }
                        else {//返回类型
                            if((plane+i)->routeOneDir==DOWN){
                                (plane+i)->routeOneDir_AddX=0;
                                (plane+i)->routeOneDir_AddY=3;
                                uint8_t randnum = rand()%2;
                                if(randnum==0)
                                    (plane+i)->routeTwoDir=UP_LEFT;
                                else
                                    (plane+i)->routeTwoDir=UP_RIGHT;
                            }
                            else if((plane+i)->routeOneDir==DOWN_LEFT)
                                (plane+i)->routeTwoDir=UP_LEFT;
                            else if((plane+i)->routeOneDir==DOWN_RIGHT)
                                (plane+i)->routeTwoDir=UP_RIGHT;
                        }

                        //动画的选择
                        if((plane+i)->isBack==1){//返回类型动画帧从第0帧开始
                            (plane+i)->actDraw=0;
                            (plane+i)->route=1;//进入动画部分
                        }
                        else {
                            if((plane+i)->routeTwoDir==DOWN)
                                (plane+i)->route=2;
                            else{
                                (plane+i)->route=1;//进入动画部分
                                (plane+i)->actDraw=5;
                            }
                        }
                    }
                    else {//没有到达转折点，继续移动
                        (plane+i)->PosX+=(plane+i)->routeOneDir_AddX;
                        (plane+i)->PosY+=(plane+i)->routeOneDir_AddY;
                    }
                    
                }
                else if((plane+i)->route==1){//第二段:敌机动画部分
                    if((plane+i)->isBack==1){//返回类型
                        (plane+i)->PosX += 0;
                        (plane+i)->PosY += 0;
                        if((plane+i)->actDraw<4){ //一共四帧动画
                            (plane+i)->actDraw+=1;
                            if((plane+i)->actDraw==4)
                                (plane+i)->route=2;
                        }
                    }
                    else {
                        (plane+i)->PosX += 0;
                        (plane+i)->PosY += 0;
                        if((plane+i)->actDraw<7){ //一共3帧动画
                            (plane+i)->actDraw+=1;
                            if((plane+i)->actDraw==7)
                                (plane+i)->route=2;
                        }
                    }
                }
                else if((plane+i)->route==2){//第二段
                        switch ((plane+i)->routeTwoDir)
                        {
                            case UP:
                                    (plane+i)->PosX += 0;
                                    (plane+i)->PosY -= 4;
                                    break;
                            case UP_LEFT:
                                    (plane+i)->PosX -= 2;
                                    (plane+i)->PosY -= 3;
                                    break;
                            case UP_RIGHT:
                                    (plane+i)->PosX += 2;
                                    (plane+i)->PosY -= 3;
                                    break;
                            case DOWN:
                                    (plane+i)->PosX += 0;
                                    (plane+i)->PosY += 5;
                                    break;
                            case DOWN_LEFT:
                                    (plane+i)->PosX -= 2;
                                    (plane+i)->PosY += 3;
                                    break;
                            case DOWN_RIGHT:
                                    (plane+i)->PosX += 2;
                                    (plane+i)->PosY += 3;
                                    break;
                            default: break;
                        }
                    }
                }
            else
                (plane+i)->FpsCnt+=1;
        } 
    }
}
void s_grey_drawPlane(S_GREY_PLANEType* plane,uint8_t* spriteRamAddr){
    for(int i=0;i<S_GREEN_FPSMAX;i++){
        if( (plane+i)->liveFlag!=0){
            uint8_t pallet=0;//调色板
            switch ( (plane+i)->actDraw)
            {
                uint8_t num=0;
                case 0://正常向下
                    num=0x40;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX, (plane+i)->PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY,num+1,pallet);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-8,num+2,pallet);
                    (*spriteRamAddr)+=3;
                    break;

                case 1://
                    num=0x43;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX, (plane+i)->PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;
                case 2://
                    num=0x45;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX, (plane+i)->PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY,num,pallet|0x40);
                    // writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-8,num+1,pallet);
                    (*spriteRamAddr)+=2;
                    break;
                case 3://
                    num=0x46;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX, (plane+i)->PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY+8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;
                case 4://
                    num=0x48;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX, (plane+i)->PosY,num,pallet);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY,num,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY+8,num+1,pallet);
                    (*spriteRamAddr)+=3;
                    break;
                case 5://不返回第一帧
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX+0, (plane+i)->PosY+0,0x4B,pallet|0x00);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY+0,0x4a,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-8,0x4c,pallet|0x00);
                    (*spriteRamAddr)+=3;
                    break;
                case 6://不返回第二帧
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX+0, (plane+i)->PosY+0,0x4d,pallet|0x00);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+0, (plane+i)->PosY-8,0x4e,pallet|0x40);
                    (*spriteRamAddr)+=2;
                    break;
                case 7://不返回第三帧
                    num=0x4a;
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX+0, (plane+i)->PosY+0,0x50,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY+0,0x4f,pallet|0x40);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-7,0x51,pallet|0x40);
                    (*spriteRamAddr)+=3;
                    break;
            default:
                break;
            }
        }
    }
}


/*****绿色小飞机*****/
extern const uint8_t S_GREEN_NUMMAX;
void s_green_planeInit(S_GREEN_PLANEType* plane){
    for (int i = 0; i < S_GREEN_NUMMAX; i++){
        (plane+i)->PosX=0;
        (plane+i)->PosY=0;
        (plane+i)->liveFlag=0;
        (plane+i)->FpsCnt=0;

        // (plane+i)->shootFlag=0;
        // (plane+i)->isBack=1;
    }
}
void s_green_createOnePlane(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY){
    for (int i = 0; i < S_GREEN_NUMMAX; i++){
        if((plane+i)->liveFlag==0){
            (plane+i)->liveFlag=1;
            (plane+i)->FpsCnt=0;
            (plane+i)->PosX = LEFT_LINE+10;
            (plane+i)->PosY = myPlanePosY-40-rand()%60;

            (plane+i)->route=0;
            (plane+i)->routeOneDir_AddX=rand()%2+2;
            (plane+i)->routeOneDir_AddY=rand()%2+0;

            (plane+i)->turnPoint_0 = myPlanePosX - 50+rand()%20;
            (plane+i)->turnPoint_1 = (plane+i)->turnPoint_0 + 60;
            (plane+i)->turnPoint_2 = myPlanePosY-20;
            (plane+i)->turnPoint_3 = (plane+i)->turnPoint_2+20+rand()%30;
            (plane+i)->turnPoint_4 = (plane+i)->turnPoint_1 - 30;

            (plane+i)->actDraw=0;
        }
    }
}
void s_green_movePlane(S_GREEN_PLANEType* plane,MYPLANEType* myPlane,BULLETType* bullet){
    for(int i=0;i<S_GREEN_NUMMAX;i++){
        if((plane+i)->liveFlag!=0){
            if((plane+i)->FpsCnt==S_GREY_FPSMAX){
                (plane+i)->FpsCnt=0;
                if  ((plane+i)->PosX<LEFT_LINE||(plane+i)->PosX>RIGHT_LINE||(plane+i)->PosY<TOP_LINE||(plane+i)->PosY>BOTTOM_LINE)
                    (plane+i)->liveFlag=0;//出界检测
                else if((plane+i)->route==0){//第一段
                    if((plane+i)->PosX>=(plane+i)->turnPoint_0){//到达转折点,进入状态机
                        (plane+i)->route=1;
                        (plane+i)->routeTwoState=0;//状态机第0段
                    }
                    else {//没有到达转折点，继续移动
                        (plane+i)->PosX+=(plane+i)->routeOneDir_AddX;
                        (plane+i)->PosY+=(plane+i)->routeOneDir_AddY;
                    }
                    (plane+i)->actDraw=0;//向右
                }
                else if((plane+i)->route==1){//第二段:状态机
                    switch ((plane+i)->routeTwoState)
                    {
                        case 0:
                            (plane+i)->actDraw=0;//向右
                            (plane+i)->PosX += 3;
                            (plane+i)->PosY += rand()%3;
                            if((plane+i)->PosX>=(plane+i)->turnPoint_1)
                                (plane+i)->routeTwoState=1;
                            break;
                        case 1:
                            (plane+i)->actDraw=1;//向右下
                            (plane+i)->PosX += rand()%2+2;
                            (plane+i)->PosY += rand()%2+2;
                            if(((plane+i)->PosY)>=(plane+i)->turnPoint_2)
                                (plane+i)->routeTwoState=2;
                            break;
                        case 2:
                            (plane+i)->actDraw=2;//向下边
                            (plane+i)->PosX += 0;
                            (plane+i)->PosY += 3;
                            if((plane+i)->PosY>=(plane+i)->turnPoint_3){
                                (plane+i)->routeTwoState=3;
                                LED_toggle(0);
                            }
                            break;
                        case 3:
                            (plane+i)->actDraw=3;//向左下
                            (plane+i)->PosX -= rand()%2+2;
                            (plane+i)->PosY += rand()%2+2;
                            if((plane+i)->PosX<=(plane+i)->turnPoint_4)
                                (plane+i)->routeTwoState=4;
                            break;
                        case 4:
                            (plane+i)->actDraw=4;//向左
                            (plane+i)->PosX -= rand()%2+2;
                            if((plane+i)->PosX<=(plane+i)->turnPoint_5)
                                (plane+i)->routeTwoState=4;
                            break;
                    
                    default:
                        break;
                    }
                }
            }
            else
                (plane+i)->FpsCnt+=1;
        } 
    }
}
void s_green_drawPlane(S_GREEN_PLANEType* plane,uint8_t* spriteRamAddr){
    for(int i=0;i<S_GREEN_NUMMAX;i++){
        if( (plane+i)->liveFlag!=0){
            switch ( (plane+i)->actDraw)
            {
                uint8_t num=0;
                case 0://右
                    num=0x40;
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+0,(plane+i)->PosY+0,0x59,0x20|0x40);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+0,(plane+i)->PosY+7,0x5a,0x20|0x40);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX-8,(plane+i)->PosY+3,0x5b,0x20|0x40);
                    (*spriteRamAddr)+=3;
                    break;
                case 1://右下
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+1,(plane+i)->PosY+1,0x5E,0x20|0x80);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+8,(plane+i)->PosY+1,0x5F,0x20|0x80);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX+0,(plane+i)->PosY+8,0x5C,0x20|0x80);
                    writeOneSprite((*spriteRamAddr)+3,(plane+i)->PosX+8,(plane+i)->PosY+8,0x5D,0x20|0x80);
                    (*spriteRamAddr)+=4;
                    break;
                case 2://下
                    writeOneSprite((*spriteRamAddr)+0, (plane+i)->PosX+0, (plane+i)->PosY+0,0x40,0x20);
                    writeOneSprite((*spriteRamAddr)+1, (plane+i)->PosX+8, (plane+i)->PosY+0,0x41,0x20);
                    writeOneSprite((*spriteRamAddr)+2, (plane+i)->PosX+4, (plane+i)->PosY-8,0x42,0x20);
                    (*spriteRamAddr)+=3;
                    break;
                case 3://左下
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+0,(plane+i)->PosY+0,0x5F,0x20|0xC0);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+8,(plane+i)->PosY+0,0x5E,0x20|0xC0);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX+0,(plane+i)->PosY+8,0x5D,0x20|0xC0);
                    writeOneSprite((*spriteRamAddr)+3,(plane+i)->PosX+8,(plane+i)->PosY+8,0x5C,0x20|0xC0);
                    (*spriteRamAddr)+=4;
                    break;
                case 4://左
                    num=0x40;
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+0,(plane+i)->PosY+0,0x59,0x20|0x00);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+0,(plane+i)->PosY+7,0x5a,0x20|0x00);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX+8,(plane+i)->PosY+3,0x5b,0x20|0x00);
                    (*spriteRamAddr)+=3;
                    break;
            default:
                break;
            }
        }
    }
}