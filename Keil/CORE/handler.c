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

//KEY INT
extern const uint8_t BULLET_NUMMAX; 
extern BULLETType bullet;
extern hitMapType bulletsHitMap;

extern MYPLANEType myplane;
extern hitMapType myPlaneHitMap;

extern const uint8_t ENEMY_NUMMAX; 
extern PLANEType enmeyPlane;
extern hitMapType enemyPlaneHitMap;

extern uint32_t GameScore;

void KEY0(void){
    LED_toggle(0);
    
   if(myplane.PosX>LEFT_LINE+5)
        myplane.PosX-=5;
    //    photo();
//    uint16_t x, y;
//    for (x = 0; x < 240; x++){
//        for (y = 0; y < 320; y++) 
//            LCD_Fast_DrawPoint(y, x, CAMERA->CAMERA_VALUE[x][y]);
//    }
}

void KEY1(void){
    LED_toggle(1);
    if(myplane.PosX<RIGHT_LINE-5)
        myplane.PosX+=5;
}


void KEY2(void){
    LED_toggle(2);
    createOneBullet();
    // if(myplane.PosY<200)
    //     myplane.PosY+=5;
}

void KEY3(void){
    LED_toggle(3);
    // createOneEnmeyPlane();
    if(myplane.PosY>TOP_LINE)
        myplane.PosY-=5;
}

//Timer
extern uint32_t fps;
uint8_t timer_cnt;
uint8_t start;

extern int PS2_KEY;
typedef enum{
    PSB_SELECT=1,//1
    PSB_L3,
    PSB_R3 ,
    PSB_START,//4
    PSB_PAD_UP,//5
    PSB_PAD_RIGHT,//6
    PSB_PAD_DOWN,//7
    PSB_PAD_LEFT,//8
    PSB_L2,
    PSB_R2,
    PSB_L1,
    PSB_R1 ,
    PSB_GREEN,//13
    PSB_RED,//14
    PSB_BLUE,//15
    PSB_PINK//16
	};
void Timer_Handler(void){
    // uint32_t key_value=READ_KEY();
    // if(timer_cnt>=4){
    //     timer_cnt=0;
    //     if(key_value==8){//按键2按下
    //         if(myplane.actFlag==1);
    //         else
    //             createOneBullet();
    //     }
    //     if(key_value==4){//按键3按下
    //         start=1;
    //     }                 
    // }
    // else{
    //     timer_cnt+=1;
    //     if(key_value==1){//按键0按下
    //         if(myplane.PosX>LEFT_LINE+5)
    //             myplane.PosX-=5;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
    //     }
    //     if(key_value==2){//按键1按下
    //         if(myplane.PosX<RIGHT_LINE-5)
    //             myplane.PosX+=5;
    //     }
    // }

    //PS2手柄操作
    //PS2_KEY=PS2_DataKey();
    if(timer_cnt>=4){
        timer_cnt=0;
        if(PS2_KEY==PSB_GREEN){//按键2按下
            if(myplane.actFlag==1)
                ;
            else
                createOneBullet();
        }
        if(PS2_KEY==PSB_RED){//翻滚躲避子弹。敌机
            start=1;
        }                 
    }
    else{
        timer_cnt+=1;
        if(PS2_KEY==PSB_PAD_LEFT){//按键0按下
            if(myplane.PosX>LEFT_LINE+5)
                myplane.PosX-=5;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
        }
        else if(PS2_KEY==PSB_PAD_RIGHT){//按键1按下
            if(myplane.PosX<RIGHT_LINE-5)
                myplane.PosX+=5;
        }
        else if(PS2_KEY==PSB_PAD_UP){//按键1按下
            if(myplane.PosY>TOP_LINE+5)
                myplane.PosY-=5;
        }
        else if(PS2_KEY==PSB_PAD_DOWN){//按键1按下
            if(myplane.PosY<BOTTOM_LINE-5)
                myplane.PosY+=5;
        }
    }
    myPlaneAct(&start);
}

void Timer_1_Handler(void){
    uint32_t key_value=READ_KEY();
    if(key_value==4){//按键2按下
         createOneBullet();
      }
}





