#include "CortexM0.h"
#include "systick.h"
#include "uart.h"
#include "camera.h"
#include "lcd.h"
#include "led.h"

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
void Timer_Handler(void){
    //gameFPSDraw(fps);
    uint32_t key_value=READ_KEY();

      if(key_value==1){//按键0按下
         if(myplane.PosX>LEFT_LINE+5)
            myplane.PosX-=5;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
      }

      if(key_value==2){//按键1按下
         if(myplane.PosX<RIGHT_LINE-5)
            myplane.PosX+=5;
      }

      if(key_value==4){//按键2按下
         createOneBullet();
      }

      if(key_value==8){//按键3按下
         //createOneBullet();
      }

    // uint8_t x=12*(rand()%10)+30;
    // uint8_t y=12*(rand()%10)+10;
    // createOneEnmeyPlane(x,y);
    
    // myPlaneDraw(myplane.PosX,myplane.PosY);
    // bulletDraw();
    // enmeyPlaneDraw();

    // enemyMapCreate(&enmeyPlane,&enemyPlaneHitMap);
    // bulletsMapCreate(&bullet,&bulletsHitMap);

    // isMyPlaneHit(&myplane,&enemyPlaneHitMap);
    // isEnemyPlaneHit(&enmeyPlane,bulletsHitMap);
    // isBulletsHit(&bullet,enemyPlaneHitMap);
    // gameScoreDraw(3,10,GameScore);

    // moveEnmeyPlane(&enmeyPlane);
    // updateBulletData();
}







