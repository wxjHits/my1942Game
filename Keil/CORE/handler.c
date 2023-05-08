#include "CortexM0.h"
#include "systick.h"
#include "uart.h"
#include "camera.h"
#include "lcd.h"
#include "led.h"
#include "key.h"

#include "gameStruct.h"
#include "makeEnemyPlaneArray.h"
#include "spriteRam.h"

#include "stdlib.h"

void NMIHandler(void) {
    ;
}

void HardFaultHandler(void) {
    ;
}

void MemManageHandler(void) {
    ;
}

void BusFaultHandler(void) {
    ;
}

void UsageFaultHandler(void) {
    ;
}

void SVCHandler(void) {
    ;
}

void DebugMonHandler(void) {
    ;
}

void PendSVHandler(void) {
    ;
}

void SysTickHandler(void) {
    Set_SysTick_CTRL(0);
    SCB->ICSR = SCB->ICSR | (1 << 25);
}


void UARTRXHandler(void) {
    uart_ClearRxIRQ(UART);
    LED_toggle(1);
    printf("uart_rx int occur!!!\n");
}

void UARTTXHandler(void) {
    uart_ClearTxIRQ(UART);
    LED_toggle(2);
    LCD_ShowString(0,0,240,320,"UARTTX_IRQn OCCURED!!!");
}

void UARTOVRHandler(void) {
    ;
}

// //KEY INT
// extern const uint8_t BULLET_NUMMAX; 
// extern BULLETType bullet;
// extern hitMapType bulletsHitMap;

// extern MYPLANEType myplane;
// extern hitMapType myPlaneHitMap;

// extern const uint8_t ENEMY_NUMMAX; 
// extern PLANEType enmeyPlane;
// extern hitMapType enemyPlaneHitMap;

// extern uint32_t GameScore;

void KEY0(void){
    LED_toggle(0);
}

void KEY1(void){
    LED_toggle(1);
}


void KEY2(void){
    LED_toggle(2);
}

void KEY3(void){
    LED_toggle(3);
}

// //Timer
// extern uint32_t fps;

// extern int PS2_KEY;
// typedef enum{
//     PSB_SELECT=1,//1
//     PSB_L3,
//     PSB_R3 ,
//     PSB_START,//4
//     PSB_PAD_UP,//5
//     PSB_PAD_RIGHT,//6
//     PSB_PAD_DOWN,//7
//     PSB_PAD_LEFT,//8
//     PSB_L2,
//     PSB_R2,
//     PSB_L1,
//     PSB_R1 ,
//     PSB_GREEN,//13
//     PSB_RED,//14
//     PSB_BLUE,//15
//     PSB_PINK//16
// 	};

void Timer_Handler(void){
        ;
}

extern uint8_t game_state;
extern uint8_t gameEndFpsCnt;
extern uint8_t gameRunState;
extern uint8_t gameEndInterFaceFpsCnt;
extern uint8_t DrawFlag;
extern MYPLANEType myplane;
void vga_Handler(void){
    if(game_state==1){
        if(gameRunState==1){
            if(NAMETABLE->mapBackgroundCnt==9&&NAMETABLE->scrollingFlag==0){
                gameRunState=3;
                NAMETABLE->scrollEn=0;
            }
            else
                gameRunState=2;
            if(myplane.liveFlag==0||NAMETABLE->scrollingFlag==0)
                gameEndFpsCnt+=1;
        }
    }
    else if(game_state==2){
        gameEndInterFaceFpsCnt++;
        if(gameEndInterFaceFpsCnt==10){
            gameEndInterFaceFpsCnt=0;
            DrawFlag=1;
        }
    }
}

/**************敌机生成的中断函数**************/
extern S_GREY_PLANEType s_grey_plane;
extern S_GREEN_PLANEType s_green_plane;
extern M_STRAIGHT_PLANEType m_straight_plane;
extern B_GREEN_PLANEType b_green_plane;

enum CREATE_PLANE{
    CREATE_NO=0,
    CREATE_S_GREY_1,
    CREATE_S_GREY_2_zhixia,
    CREATE_S_GREY_2_duicheng,
    CREATE_S_GREY_4_zhixia,
    CREATE_S_GREY_4_duicheng,
    CREATE_S_GREY_6,

    CREATE_S_GREEN_2_tongce,
    CREATE_S_GREEN_2_shuangce,
    CREATE_S_GREEN_4,

    CREATE_M_1,
    CREATE_M_2_binglie,

    CREATE_B,
};
uint32_t num=0;
uint32_t create[120]={
                CREATE_S_GREY_1,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_2_duicheng,0,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_2_zhixia,
                CREATE_S_GREY_2_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,CREATE_S_GREY_2_duicheng,0,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,0,
                0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_4_zhixia,0,0,0,
                CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREY_2_duicheng,0,0,0,
                CREATE_B,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,
                CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_4_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_1,0,
                CREATE_M_2_binglie,0,CREATE_S_GREEN_2_shuangce,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,
                CREATE_S_GREY_6,0,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,0,0,0,0,
                };
//一幅地图240/16=15，产生15次create_plane_Handler中断
//如果每一关为8幅地图，则有120次create_plane_Handler中断
void create_plane_Handler(void){
    switch (create[num]){
    case CREATE_S_GREY_1:
        s_grey_createPlane_111(&s_grey_plane);
        break;
    case CREATE_S_GREY_2_zhixia:
        s_grey_createPlane_122(&s_grey_plane);
        break;
    case CREATE_S_GREY_2_duicheng:
        s_grey_createPlane_123(&s_grey_plane);
        break;
    case CREATE_S_GREY_4_zhixia:
        s_grey_createPlane_144(&s_grey_plane);
        break;
    case CREATE_S_GREY_4_duicheng:
        s_grey_createPlane_145(&s_grey_plane);
        break;
    case CREATE_S_GREY_6:
        s_grey_createPlane_166(&s_grey_plane);
        break;
    case CREATE_S_GREEN_2_tongce:
        s_green_createPlane_221(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_S_GREEN_2_shuangce:
        s_green_createPlane_222(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_S_GREEN_4:
        s_green_createPlane_243(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_M_1:
        s_green_createPlane_411(&m_straight_plane);
        break;
    case CREATE_M_2_binglie:
        s_green_createPlane_422(&m_straight_plane);
        break;
    case CREATE_B:
        b_green_createPlane_511(&b_green_plane);
        break;
    default:
        break;
    }
    num++;
}
