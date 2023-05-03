#include "CortexM0.h"
#include "systick.h"
#include "uart.h"
#include "camera.h"
#include "lcd.h"
#include "led.h"
#include "key.h"

#include "myGame.h"
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





