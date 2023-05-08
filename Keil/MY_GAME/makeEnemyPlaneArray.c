#include "stdlib.h"
#include "makeEnemyPlaneArray.h"

/******************小灰******************/
void s_grey_createPlane_111(S_GREY_PLANEType* plane){
    S_GREY_PLANEType* planeParameter;
    planeParameter->PosX=rand()%170+LEFT_LINE;
    if(planeParameter->PosX>LEFT_LINE&&planeParameter->PosX< (LEFT_LINE + 80))
        planeParameter->routeOneDir=DOWN_RIGHT;
    else if (planeParameter->PosX>(RIGHT_LINE-80) && planeParameter->PosX<RIGHT_LINE)
        planeParameter->routeOneDir=DOWN_LEFT;
    else
        planeParameter->routeOneDir=DOWN;

    s_grey_createOnePlane(plane,planeParameter,0,0);
}
void s_grey_createPlane_122(S_GREY_PLANEType* plane){
    S_GREY_PLANEType* planeParameter0;
    // S_GREY_PLANEType* planeParameter1;
    int16_t temp = rand()%170+20+LEFT_LINE;
    planeParameter0->PosX=temp;
    planeParameter0->routeOneDir=DOWN;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    // planeParameter1->PosX=temp+20;
    // planeParameter1->routeOneDir=DOWN;
    planeParameter0->PosX=temp+20;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    // s_grey_createOnePlane(plane,planeParameter1,0,0);
}
void s_grey_createPlane_123(S_GREY_PLANEType* plane){
    S_GREY_PLANEType* planeParameter0;
    planeParameter0->PosX=rand()%170+LEFT_LINE;
    if(planeParameter0->PosX>LEFT_LINE&&planeParameter0->PosX< (LEFT_LINE + 80))
        planeParameter0->routeOneDir=DOWN_RIGHT;
    else if (planeParameter0->PosX>(RIGHT_LINE-80) && planeParameter0->PosX<RIGHT_LINE)
        planeParameter0->routeOneDir=DOWN_LEFT;
    else
        planeParameter0->routeOneDir=DOWN;
    s_grey_createOnePlane(plane,planeParameter0,0,0);

    planeParameter0->PosX=256-planeParameter0->PosX;
    if (planeParameter0->routeOneDir==DOWN_RIGHT)
        planeParameter0->routeOneDir=DOWN_LEFT;
    else if(planeParameter0->routeOneDir==DOWN_LEFT)
        planeParameter0->routeOneDir=DOWN_RIGHT;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
}

void s_grey_createPlane_144(S_GREY_PLANEType* plane){
    S_GREY_PLANEType* planeParameter0;
    int16_t temp = rand()%170+20+LEFT_LINE;
    planeParameter0->PosX=temp;
    planeParameter0->routeOneDir=DOWN;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    planeParameter0->PosX=temp+20;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    planeParameter0->PosX=temp+40;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    planeParameter0->PosX=temp+60;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
}

void s_grey_createPlane_145(S_GREY_PLANEType* plane){
    S_GREY_PLANEType* planeParameter0;
    planeParameter0->PosX=rand()%170+LEFT_LINE;
    if(planeParameter0->PosX>LEFT_LINE&&planeParameter0->PosX< (LEFT_LINE + 80))
        planeParameter0->routeOneDir=DOWN_RIGHT;
    else if (planeParameter0->PosX>(RIGHT_LINE-80) && planeParameter0->PosX<RIGHT_LINE)
        planeParameter0->routeOneDir=DOWN_LEFT;
    else
        planeParameter0->routeOneDir=DOWN;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    planeParameter0->PosX+=20;
    s_grey_createOnePlane(plane,planeParameter0,0,0);

    planeParameter0->PosX=256-planeParameter0->PosX;
    if (planeParameter0->routeOneDir==DOWN_RIGHT)
        planeParameter0->routeOneDir=DOWN_LEFT;
    else if(planeParameter0->routeOneDir==DOWN_LEFT)
        planeParameter0->routeOneDir=DOWN_RIGHT;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
    planeParameter0->PosX+=20;
    s_grey_createOnePlane(plane,planeParameter0,0,0);
}

void s_grey_createPlane_166(S_GREY_PLANEType* plane){
    s_grey_createPlane_144(plane);
    s_grey_createPlane_122(plane);
}





/******************小绿******************/
void s_green_createPlane_221(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY){
    uint8_t RL_Flag = rand()%2;
    s_green_createOnePlane(plane, RL_Flag, myPlanePosX, myPlanePosY);
    s_green_createOnePlane(plane, RL_Flag, myPlanePosX, myPlanePosY+20);
}
void s_green_createPlane_222(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY){
    uint8_t RL_Flag = rand()%2;
    uint8_t RL_Flag_0 = (RL_Flag==1)?0:1;
    s_green_createOnePlane(plane, RL_Flag, myPlanePosX, myPlanePosY);
    s_green_createOnePlane(plane, RL_Flag_0, myPlanePosX, myPlanePosY);
}

void s_green_createPlane_243(S_GREEN_PLANEType* plane,int16_t myPlanePosX,int16_t myPlanePosY){
    s_green_createPlane_222(plane,myPlanePosX,myPlanePosY);
    uint8_t RL_Flag = rand()%2;
    uint8_t RL_Flag_0 = rand()%2;
    s_green_createOnePlane(plane, RL_Flag, myPlanePosX, myPlanePosY);
    s_green_createOnePlane(plane, RL_Flag_0, myPlanePosX, myPlanePosY);
}


/******************中飞******************/
void s_green_createPlane_411(M_STRAIGHT_PLANEType* plane){
    uint8_t RL_Flag = rand()%2;
    int16_t occurPosX=0;
    if (RL_Flag==0)
        occurPosX=128-80;
    else
        occurPosX=128+80;
    m_straight_createOnePlane(plane,occurPosX);
}

void s_green_createPlane_422(M_STRAIGHT_PLANEType* plane){
    uint8_t RL_Flag = rand()%2;
    int16_t occurPosX=0;
    if (RL_Flag==0)
        occurPosX=128-80;
    else
        occurPosX=128+80;
    m_straight_createOnePlane(plane,occurPosX);
    if (RL_Flag==1)
        occurPosX=128-80;
    else
        occurPosX=128+80;
    m_straight_createOnePlane(plane,occurPosX);
}

/******************大飞******************/
void b_green_createPlane_511(B_GREEN_PLANEType* plane){
    b_green_createOnePlane(plane);
}