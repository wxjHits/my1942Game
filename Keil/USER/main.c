#include "CortexM0.h"
#include "camera.h"
#include "uart.h"
#include "led.h"
#include "pic_resource.h"
#include "lcd.h"
#include "key.h"
#include "timer.h"
#include "spi_flash.h"
#include "systick.h"

#include "myGame.h"
#include "spriteRam.h"

#include "malloc.h"
#include "stdlib.h"

const uint8_t BULLET_NUMMAX=3; 
BULLETType bullet[BULLET_NUMMAX];
hitMapType bulletsHitMap;

PLANEType myplane;
hitMapType myPlaneHitMap;

const uint8_t ENEMY_NUMMAX=5; 
PLANEType enmeyPlane[ENEMY_NUMMAX];
hitMapType enemyPlaneHitMap;

uint32_t GameScore=0;

int main(void)
{ 
    for(int i=0;i<64;i++){
        writeOneSprite(i,240,240,31,0x00);
    }
    myPlaneInit();
    bulletInit();
    enmeyPlaneInit();

    
   //先执行的是函数SystemInit();
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   SPI_Init(100);
   LCD_Init();
   KEY_INIT(0xf);
   NVIC_EnableIRQ(KEY0_IRQn);
   NVIC_EnableIRQ(KEY1_IRQn);
   NVIC_EnableIRQ(KEY2_IRQn);
   NVIC_EnableIRQ(KEY3_IRQn);
//    CAMERA_Initial();//占用较多的ROM资源,有许多初始化的const uint8_t 数据，共大约
   TIMER_Init(500000,0,1);

   uint8_t *mario_8192=0;
   mario_8192=mymalloc(4096);
   myfree(mario_8192);
   LCD_Clear(GRAYBLUE);
   
   uint16_t y_pos=0;
            
   while(1)
   {
        //updateBulletData();
        ;
//    if(isMyPlaneHit(&myplane,&enemyPlaneHitMap)){
//        LED_toggle(7);
//        boomDraw(myplane.PosX,myplane.PosY);
//    }
   }
}
