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
            (plane+i)->isBack=rand()%2;
            (plane+i)->shootFlag=1;
            (plane+i)->PosX = planeParameter->PosX;
            (plane+i)->PosY = TOP_LINE+5+10*(rand()%2);

            (plane+i)->routeOneDir=planeParameter->routeOneDir;
            // if((plane+i)->PosX>LEFT_LINE&&(plane+i)->PosX< (LEFT_LINE + 80)){
            //     (plane+i)->routeOneDir=DOWN_RIGHT;
            // }
            // else if ((plane+i)->PosX>(RIGHT_LINE-80) && (plane+i)->PosX<RIGHT_LINE){
            //     (plane+i)->routeOneDir=DOWN_LEFT;
            // }
            // else
            //     (plane+i)->routeOneDir=DOWN;
            

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
                    if((plane+i)->PosY>=(myPlane->PosY-40-20*rand()%3)){//到达转折点
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
    for(int i=0;i<S_GREY_NUMMAX;i++){
        if( (plane+i)->liveFlag!=0){
            uint8_t pallet=0;//调色板
            uint8_t num=0;
            switch ( (plane+i)->actDraw)
            {
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
void s_green_createOnePlane(S_GREEN_PLANEType* plane,uint8_t RL_Flag,int16_t myPlanePosX,int16_t myPlanePosY){
    for (int i = 0; i < S_GREEN_NUMMAX; i++){
        if((plane+i)->liveFlag==0){
            (plane+i)->liveFlag=1;
            (plane+i)->FpsCnt=0;
            
            (plane+i)->PosY = myPlanePosY-60-20*(rand()%3);
            (plane+i)->route=0;
            (plane+i)->routeOneDir_AddY=rand()%2+0;

            (plane+i)->RL_Flag = RL_Flag;
            if((plane+i)->RL_Flag==0){//R:1 L:0
                (plane+i)->PosX = LEFT_LINE+10;
                (plane+i)->actDraw=0;
                (plane+i)->routeOneDir_AddX=rand()%2+2;
                (plane+i)->turnPoint_0 = myPlanePosX - 50+10*rand()%2;
                (plane+i)->turnPoint_1 = (plane+i)->turnPoint_0 + 30+20*rand()%2;
                (plane+i)->turnPoint_2 = myPlanePosY-20-20*rand()%2;
                (plane+i)->turnPoint_3 = (plane+i)->turnPoint_2+20+rand()%30;
                (plane+i)->turnPoint_4 = (plane+i)->turnPoint_1 - 30;
            }
            else{
                (plane+i)->PosX = RIGHT_LINE-10;
                (plane+i)->actDraw=4;
                (plane+i)->routeOneDir_AddX=-rand()%2-2;
                (plane+i)->turnPoint_0 = myPlanePosX + 50+rand()%20;
                (plane+i)->turnPoint_1 = (plane+i)->turnPoint_0 - 60;
                (plane+i)->turnPoint_2 = myPlanePosY-20;
                (plane+i)->turnPoint_3 = (plane+i)->turnPoint_2+20+rand()%30;
                (plane+i)->turnPoint_4 = (plane+i)->turnPoint_1 + 30;
            }
            break;
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
                    if ((plane+i)->RL_Flag==0 && (plane+i)->PosX>=(plane+i)->turnPoint_0){
                        (plane+i)->route=1;
                        (plane+i)->routeTwoState=0;//状态机第0段
                    }
                    else if((plane+i)->RL_Flag==1 && (plane+i)->PosX<=(plane+i)->turnPoint_0){//到达转折点,进入状态机
                        (plane+i)->route=1;
                        (plane+i)->routeTwoState=0;//状态机第0段
                    }
                    else {//没有到达转折点，继续移动
                        (plane+i)->PosX+=(plane+i)->routeOneDir_AddX;
                        (plane+i)->PosY+=(plane+i)->routeOneDir_AddY;
                    }
                }
                else if((plane+i)->route==1){//第二段:状态机
                    if((plane+i)->RL_Flag==0){
                        switch ((plane+i)->routeTwoState){
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
                    else{
                        switch ((plane+i)->routeTwoState){
                            case 0:
                                (plane+i)->actDraw=4;//向左边
                                (plane+i)->PosX -= 3;
                                (plane+i)->PosY += rand()%3;
                                if((plane+i)->PosX<=(plane+i)->turnPoint_1)
                                    (plane+i)->routeTwoState=1;
                                break;
                            case 1:
                                (plane+i)->actDraw=3;//向左下
                                (plane+i)->PosX -= rand()%2+2;
                                (plane+i)->PosY += rand()%2+2;
                                if(((plane+i)->PosY)<=(plane+i)->turnPoint_2)
                                    (plane+i)->routeTwoState=2;
                                break;
                            case 2:
                                (plane+i)->actDraw=2;//向下边
                                (plane+i)->PosX += 0;
                                (plane+i)->PosY += 3;
                                if((plane+i)->PosY>=(plane+i)->turnPoint_3)
                                    (plane+i)->routeTwoState=3;
                                break;
                            case 3:
                                (plane+i)->actDraw=1;//向右下
                                (plane+i)->PosX += rand()%2+2;
                                (plane+i)->PosY += rand()%2+2;
                                if((plane+i)->PosX>=(plane+i)->turnPoint_4)
                                    (plane+i)->routeTwoState=4;
                                break;
                            case 4:
                                (plane+i)->actDraw=0;//向右
                                (plane+i)->PosX += rand()%2+2;
                                if((plane+i)->PosX>=(plane+i)->turnPoint_5)
                                    (plane+i)->routeTwoState=4;
                                break;
                            default:
                                break;
                        }
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
                case 0://右
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





















/*****从下到上直飞的中型飞机*****/
extern const uint8_t M_STRAIGHT_NUMMAX;
void m_straight_planeInit(M_STRAIGHT_PLANEType* plane){
    for (int i = 0; i < M_STRAIGHT_NUMMAX; i++){
        (plane+i)->PosX=0;
        (plane+i)->PosY=0;
        (plane+i)->route_AddY=0;
        (plane+i)->liveFlag=0;
        (plane+i)->hp=5;
        (plane+i)->FpsCnt=0;
        (plane+i)->typeDraw=0;
        (plane+i)->Color=0;
    }
}
void m_straight_createOnePlane(M_STRAIGHT_PLANEType* plane,int16_t occurPosX){
    for (int i = 0; i < M_STRAIGHT_NUMMAX; i++){
        if((plane+i)->liveFlag==0){
            (plane+i)->liveFlag=1;
            (plane+i)->hp=20;
            (plane+i)->FpsCnt=0;
            (plane+i)->PosX = occurPosX ;
            (plane+i)->PosY = BOTTOM_LINE-5-20*rand()%2;
            (plane+i)->route_AddY=1;
            (plane+i)->typeDraw=rand()%2;
            (plane+i)->Color=rand()%2;

            break;
        }
    }
}
void m_straight_movePlane(M_STRAIGHT_PLANEType* plane){
    for(int i=0;i<M_STRAIGHT_NUMMAX;i++){
        if((plane+i)->liveFlag!=0){
            if((plane+i)->FpsCnt==M_STRAIGHT_FPSMAX){
                (plane+i)->FpsCnt=0;
                if  ((plane+i)->PosX<LEFT_LINE||(plane+i)->PosX>RIGHT_LINE||((plane+i)->PosY+8)<TOP_LINE||((plane+i)->PosY)>BOTTOM_LINE)
                    (plane+i)->liveFlag=0;//出界检测
                else
                    (plane+i)->PosY-=(plane+i)->route_AddY;
            }
            else
                (plane+i)->FpsCnt+=1;
        }
    }
}
void m_straight_drawPlane(M_STRAIGHT_PLANEType* plane,uint8_t* spriteRamAddr){
    for(int i=0;i<M_STRAIGHT_NUMMAX;i++){
        if( (plane+i)->liveFlag!=0){
            uint8_t color;
            if((plane+i)->Color==0)
                color=0x00;
            else
                color=0x20;
            switch ((plane+i)->typeDraw)
            {
                case 0://
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+ 0,(plane+i)->PosY+ 0,0x90,color|0x00);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+ 8,(plane+i)->PosY+ 0,0x91,color|0x00);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX+ 0,(plane+i)->PosY+ 7,0x92,color|0x00);
                    writeOneSprite((*spriteRamAddr)+3,(plane+i)->PosX+ 8,(plane+i)->PosY+ 7,0x93,color|0x00);
                    writeOneSprite((*spriteRamAddr)+4,(plane+i)->PosX+ 0,(plane+i)->PosY+14,0x94,color|0x00);
                    writeOneSprite((*spriteRamAddr)+5,(plane+i)->PosX+ 8,(plane+i)->PosY+14,0x95,color|0x00);
                    writeOneSprite((*spriteRamAddr)+6,(plane+i)->PosX- 8,(plane+i)->PosY+ 4,0x96,color|0x00);
                    writeOneSprite((*spriteRamAddr)+7,(plane+i)->PosX+16,(plane+i)->PosY+ 4,0x96,color|0x40);
                    (*spriteRamAddr)+=8;
                    break;
                case 1://
                    writeOneSprite((*spriteRamAddr)+0,(plane+i)->PosX+ 0,(plane+i)->PosY+ 0,0xb3,color|0x00);
                    writeOneSprite((*spriteRamAddr)+1,(plane+i)->PosX+ 0,(plane+i)->PosY- 7,0xb1,color|0x00);
                    writeOneSprite((*spriteRamAddr)+2,(plane+i)->PosX+ 0,(plane+i)->PosY+ 7,0xb5,color|0x00);
                    writeOneSprite((*spriteRamAddr)+3,(plane+i)->PosX- 8,(plane+i)->PosY+ 0,0xb2,color|0x00);
                    writeOneSprite((*spriteRamAddr)+4,(plane+i)->PosX+ 8,(plane+i)->PosY+ 0,0xb2,color|0x40);
                    (*spriteRamAddr)+=5;
                    break;
            default:
                break;
            }
        }
    }
}













//绿色大型机
extern const uint8_t B_GREEN_NUMMAX;
void b_green_planeInit(B_GREEN_PLANEType* plane){
    for (int i = 0; i < B_GREEN_NUMMAX; i++){
        (plane+i)->PosX=0;
        (plane+i)->PosY=0;
        (plane+i)->liveFlag=0;
        (plane+i)->hp=5;
        (plane+i)->FpsCnt=0;
        (plane+i)->route=0;
    }
}
void b_green_createOnePlane(B_GREEN_PLANEType* plane){
    for (int i = 0; i < B_GREEN_NUMMAX; i++){
        if((plane+i)->liveFlag==0){
            (plane+i)->liveFlag=1;
            (plane+i)->hp=30;
            (plane+i)->FpsCnt=0;
            (plane+i)->PosX=100*rand()%2+100;
            (plane+i)->PosY=180;
            (plane+i)->route=0;//第一段，直飞入场；第二段，画面上半部分徘徊（为平行四边形）；第三段退场
            (plane+i)->route1_state=0;//第二段徘徊状态的状态，0，1，2，3
            (plane+i)->route1_allStateCnt=0;//第二段徘徊状态圈数计数器，转3圈后退出（如果没有被击毁）
            (plane+i)->route0_AddY=-2;//第一段路径的增量,进入画面
            (plane+i)->route1_turnY_0=30;
            (plane+i)->route1_turnY_1=30+60;
            (plane+i)->route1_turnX_0=40;
            (plane+i)->route1_turnX_1=40+20;
            (plane+i)->route1_turnX_2=40+20+100;
            (plane+i)->route1_turnX_3=40+20+100+20;
            break;
        }
    }
}

extern MYPLANEType myplane;
extern BULLETType enmeyBullets[10];

void b_green_movePlane(B_GREEN_PLANEType* plane){
    for(int i=0;i<B_GREEN_NUMMAX;i++){
        if((plane+i)->liveFlag!=0){
            if((plane+i)->FpsCnt==B_GREEN_FPSMAX){
                (plane+i)->FpsCnt=0;
                // if  ((plane+i)->PosX<LEFT_LINE||(plane+i)->PosX>RIGHT_LINE||(plane+i)->PosY<TOP_LINE||(plane+i)->PosY>BOTTOM_LINE){
                //     (plane+i)->liveFlag=0;//出界检测
                //     (plane+i)->PosX=0;
                //     (plane+i)->PosY=0;
                // }
                if((plane+i)->route==0){//第一段
                    if((plane+i)->PosY<=(plane+i)->route1_turnY_1){//进入第二段徘徊
                        (plane+i)->route1_allStateCnt=0;
                        (plane+i)->route1_state=0;
                        (plane+i)->route=1;
                        s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                    }
                    else {//继续向上移动
                        (plane+i)->PosY+=(plane+i)->route0_AddY;
                    }
                    
                }
                else if((plane+i)->route==1){//第二段:徘徊阶段
                    if((plane+i)->route1_state==0){//徘徊状态机 0
                        (plane+i)->PosX += -2;
                        (plane+i)->PosY += rand()%3-1;
                        if((plane+i)->PosX<(plane+i)->route1_turnX_0){
                            (plane+i)->route1_state=1;
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                        }
                        if((plane+i)->PosX<100&&(plane+i)->PosX>97)
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                        else if((plane+i)->PosX<120&&(plane+i)->PosX>117)
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                    }
                    else if((plane+i)->route1_state==1){//徘徊状态机 1
                        (plane+i)->PosX += 2;
                        (plane+i)->PosY -= 2;
                        if((plane+i)->PosX>(plane+i)->route1_turnX_1){
                            (plane+i)->route1_state=2;
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                        }
                    }
                    else if((plane+i)->route1_state==2){//徘徊状态机 2
                        (plane+i)->PosX += 2;
                        (plane+i)->PosY += rand()%3-1;
                        if((plane+i)->PosX>(plane+i)->route1_turnX_3){
                            (plane+i)->route1_state=3;
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                        }
                        if((plane+i)->PosX<110&&(plane+i)->PosX>107)
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                        else if((plane+i)->PosX<128&&(plane+i)->PosX>125){
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                            (plane+i)->route1_allStateCnt++;
                            if((plane+i)->route1_allStateCnt==4)
                                (plane+i)->route=2;
                        }
                    }
                    else if((plane+i)->route1_state==3){//徘徊状态机 3
                        (plane+i)->PosX += -2;
                        (plane+i)->PosY += 2;
                        if((plane+i)->PosX<(plane+i)->route1_turnX_2){
                            s_grey_createOneEnmeyBullet(&enmeyBullets, plane,&myplane);
                            (plane+i)->route1_state=0;
                            // (plane+i)->route1_allStateCnt++;
                            // if((plane+i)->route1_allStateCnt==2)
                            //     (plane+i)->route=2;
                        }
                    }
                }
                else if((plane+i)->route==2){//第二段
                        (plane+i)->PosY +=-2;
                        if((plane+i)->PosY<TOP_LINE)
                            (plane+i)->liveFlag=0;
                    }
                }
            else
                (plane+i)->FpsCnt+=1;
        } 
    }
}
void b_green_drawPlane(B_GREEN_PLANEType* plane,uint8_t* spriteRamAddr){
    for(int i=0;i<B_GREEN_NUMMAX;i++){
        if( (plane+i)->liveFlag!=0){
            //大型飞机
            writeOneSprite((*spriteRamAddr)+ 0,(plane+i)->PosX+ 0,(plane+i)->PosY+ 0,0xc0,0x20);
            writeOneSprite((*spriteRamAddr)+ 1,(plane+i)->PosX+ 0,(plane+i)->PosY+ 7,0xc1,0x20);
            writeOneSprite((*spriteRamAddr)+ 2,(plane+i)->PosX+ 0,(plane+i)->PosY+14,0xc2,0x20);
            writeOneSprite((*spriteRamAddr)+ 3,(plane+i)->PosX+ 0,(plane+i)->PosY+21,0xc3,0x20);
            writeOneSprite((*spriteRamAddr)+ 4,(plane+i)->PosX- 4,(plane+i)->PosY+28,0xc4,0x20);
            writeOneSprite((*spriteRamAddr)+ 5,(plane+i)->PosX+ 4,(plane+i)->PosY+28,0xc5,0x20);
            writeOneSprite((*spriteRamAddr)+ 6,(plane+i)->PosX- 7,(plane+i)->PosY+05,0xc6,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+ 7,(plane+i)->PosX+ 7,(plane+i)->PosY+05,0xc6,0x20);
            writeOneSprite((*spriteRamAddr)+ 8,(plane+i)->PosX- 7,(plane+i)->PosY+12,0xc9,0x20);
            writeOneSprite((*spriteRamAddr)+ 9,(plane+i)->PosX+ 7,(plane+i)->PosY+12,0xca,0x20);
            writeOneSprite((*spriteRamAddr)+10,(plane+i)->PosX-14,(plane+i)->PosY+10,0xc8,0x20);
            writeOneSprite((*spriteRamAddr)+11,(plane+i)->PosX+14,(plane+i)->PosY+10,0xc8,0x20|0x40);
            writeOneSprite((*spriteRamAddr)+12,(plane+i)->PosX-21,(plane+i)->PosY+10,0xc7,0x20);
            writeOneSprite((*spriteRamAddr)+13,(plane+i)->PosX+21,(plane+i)->PosY+10,0xc7,0x20|0x40);
            (*spriteRamAddr)+=14;
        }
    }
}
