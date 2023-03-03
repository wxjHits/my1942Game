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
#include "pstwo.h"

#include "myGame.h"
#include "spriteRam.h"

#include "malloc.h"
#include "stdlib.h"

const uint8_t routeCircle[18][2]={
   40+50,80+50,
   53+50,77+50,
   65+50,70+50,
   74+50,60+50,
   79+50,46+50,
   79+50,33+50,
   74+50,20+50,
   65+50, 9+50,
   53+50, 2+50,
   40+50, 5+50,
   26+50, 2+50,
   14+50, 9+50,
    5+50,19+50,
    0+50,33+50,
    0+50,46+50,
    5+50,59+50,
   14+50,70+50,
   26+50,77+50
};

const uint8_t ANGLE_NUMMAX=10;
const int16_t sin_array[ANGLE_NUMMAX]={1,2,2,2,3,4,4,4,5,5};
const int16_t cos_array[ANGLE_NUMMAX]={4,4,4,4,4,3,2,2,1,0};
const float tan_array[ANGLE_NUMMAX]={0.00,0.18,0.36,0.58,0.84,1.19,1.73,2.75,5.67,200};

// angleValueType angle[ANGLE_NUMMAX];
//我方子弹
const uint8_t BULLET_NUMMAX=20;
BULLETType bullet[BULLET_NUMMAX];
hitMapType bulletsHitMap;
//敌方子弹
const uint8_t ENEMY_BULLETS_NUMMAX=5;
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];
hitMapType enmeyBulletsHitMap;
//我方飞机.
MYPLANEType myplane;
hitMapType myPlaneHitMap;
//敌方飞机
const uint8_t ENEMY_NUMMAX=5; 
PLANEType enmeyPlane[ENEMY_NUMMAX];
hitMapType enemyPlaneHitMap;
//爆炸单位
const uint8_t BOOM_NUMMAX=BULLET_NUMMAX;
BOOMType boom[BOOM_NUMMAX];
//BUFF单位（有且仅有一个）
BUFFType buff;
//进行画图时，
uint8_t spriteRamAddr=0;
//分数
uint32_t GameScore=0;
//帧率FPS
uint32_t fps; 

//PS2 PS2_KEY
int PS2_KEY=0;
int main(void)
{ 
    myPlaneInit();
    bulletInit();
    enmeyPlaneInit();
    enmeyBulletInit();
    buffInit(&buff);
   //先执行的是函数SystemInit();
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   //SPI_Init(100);
   
   PS2_Init();		//======ps2驱动端口初始化
   PS2_SetInit();	//======ps2配置初始化,配置“红绿灯模式”，并选择是否可以修改

   // LCD_Init();
   //KEY_INIT(0xf);
   NVIC_EnableIRQ(KEY0_IRQn);
   NVIC_EnableIRQ(KEY1_IRQn);
   NVIC_EnableIRQ(KEY2_IRQn);
   NVIC_EnableIRQ(KEY3_IRQn);
//    CAMERA_Initial();//占用较多的ROM资源,有许多初始化的const uint8_t 数据，共大约
   TIMER_Init(3000000,0,1);//1000ms
   //TIMER_1_Init(10000000,0,1);//1000ms

   //uint8_t *mario_8192=0;
   //mario_8192=mymalloc(4096);                                                                                                                                                                       
   //myfree(mario_8192);
   //LCD_Clear(RED);
   while(1)
   {
      int PS2_LX,PS2_LY,PS2_RX,PS2_RY;
      //PS2_LX=PS2_AnologData(PSS_LX);
      //PS2_LY=PS2_AnologData(PSS_LY);
      // PS2_RX=PS2_AnologData(PSS_RX);
      // PS2_RY=PS2_AnologData(PSS_RY);
      //PS2_KEY=PS2_DataKey();
      //printf("%d     PS2_LX:",PS2_LX);
      //printf("%d     PS2_LY:",PS2_LY);
      // printf("%d     PS2_RX:",PS2_RX);
      // printf("%d     PS2_RY:",PS2_RY);
      //printf("%d \r\nPS2_KEY:",PS2_KEY);
       
      uint8_t x=20*(rand()%10)+30;
      uint8_t y=2*(rand()%10)+10;
      ROUTEType route;                         
      route.route0         = rand()%3+4;
      route.route1         = rand()%3+1;
      route.turnLine       = myplane.PosY-20-rand()%20;
      route.routeCnt       = 0;
      route.routeCircleCnt = 0;
       
      createOneEnmeyPlane(x,y,route);
      //if(GameScore==50)
      //   createOneBuff(20,120,BUFF_POWER,&buff);
      
      //绘图
      spriteRamAddr=0;
      gameScoreDraw(3,10,GameScore,&spriteRamAddr);
      myPlaneDraw(myplane.PosX,myplane.PosY,&spriteRamAddr);
      bulletDraw(&spriteRamAddr);
      enmeyPlaneDraw(&spriteRamAddr);
      enmeyBulletDraw(&spriteRamAddr);
      boomDraw(&spriteRamAddr);
      buffDraw(&spriteRamAddr);

      for(uint8_t i=spriteRamAddr;i<SPRITE_RAM_ADDR_MAX;i++){
            
         writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
         spriteRamAddr++;
      }

      //撞击试验
      enemyMapCreate(&enmeyPlane,&enemyPlaneHitMap);
      enemyBulletsMapCreate(&enmeyBullets,&enmeyBulletsHitMap);
      bulletsMapCreate(&bullet,&bulletsHitMap);
      myPlaneMapCreate(&myplane,&myPlaneHitMap);
      
      isMyPlaneHit(&myplane,&enemyPlaneHitMap,&enmeyBulletsHitMap,&buff,&myPlaneHitMap);
      isEnemyPlaneHit(&enmeyPlane,bulletsHitMap);
      isBulletsHit(&bullet,&enemyPlaneHitMap,&enmeyBulletsHitMap);
      
      //敌机、敌机子弹、我方子弹、爆炸效果等单位的数据更新
      PS2_KEY=PS2_DataKey();
      moveEnmeyPlane(&enmeyPlane);
      updateEnemyBulletData();
      updateBulletData();
      updateBoomData(&boom);
      updateBuffData(&buff);

      delay_ms(20);
       
   }
}

