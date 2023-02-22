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
//#include "pstwo.h"

#include "myGame.h"
#include "spriteRam.h"

#include "malloc.h"
#include "stdlib.h"

//
// const uint8_t routeCircle[18][2]={
//    10,20, 13,19, 16,17, 18,15, 19,11, 19, 8, 18, 5, 16, 2, 13, 0,
//    10, 1, 6, 0, 3, 2, 1, 4, 0, 8, 0,11, 1,14, 3,17, 6,19
// };

const uint8_t routeCircle[18][2]={
   //  10+60,20+60,
   //  13+60,19+60,
   //  16+60,17+60,
   //  18+60,15+60,
   //  19+60,11+60,
   //  19+60, 8+60,
   //  18+60, 5+60,
   //  16+60, 2+60,
   //  13+60, 0+60,
   //  10+60, 1+60,
   //   6+60, 0+60,
   //   3+60, 2+60,
   //   1+60, 4+60,
   //   0+60, 8+60,
   //   0+60,11+60,
   //   1+60,14+60,
   //   3+60,17+60,
   //   6+60,19+60

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

//�ҷ��ӵ�
const uint8_t BULLET_NUMMAX=20; 
BULLETType bullet[BULLET_NUMMAX];
hitMapType bulletsHitMap;
//�з��ӵ�
const uint8_t ENEMY_BULLETS_NUMMAX=5; 
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];
hitMapType enmeyBulletsHitMap;
//�ҷ��ɻ�.
MYPLANEType myplane;
hitMapType myPlaneHitMap;
//�з��ɻ�
const uint8_t ENEMY_NUMMAX=5; 
PLANEType enmeyPlane[ENEMY_NUMMAX];
hitMapType enemyPlaneHitMap;
//��ը��λ
const uint8_t BOOM_NUMMAX=BULLET_NUMMAX;
BOOMType boom[BOOM_NUMMAX];
//BUFF��λ�����ҽ���һ����
BUFFType buff;
//���л�ͼʱ��
uint8_t spriteRamAddr=0;
//����
uint32_t GameScore=0;
//֡��FPS
uint32_t fps; 

int main(void)
{ 
    for(int i=0;i<64;i++){
        writeOneSprite(i,240,240,31,0x00);
    }
    myPlaneInit();
    bulletInit();
    enmeyPlaneInit();
    buffInit(&buff);
   //��ִ�е��Ǻ���SystemInit();
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   SPI_Init(100);
   
   // PS2_Init();		//======ps2�����˿ڳ�ʼ��
   // PS2_SetInit();	//======ps2���ó�ʼ��,���á����̵�ģʽ������ѡ���Ƿ�����޸�

   //LCD_Init();
   //KEY_INIT(0xf);
   NVIC_EnableIRQ(KEY0_IRQn);
   NVIC_EnableIRQ(KEY1_IRQn);
   NVIC_EnableIRQ(KEY2_IRQn);
   NVIC_EnableIRQ(KEY3_IRQn);
//    CAMERA_Initial();//ռ�ý϶��ROM��Դ,������ʼ����const uint8_t ���ݣ�����Լ
   TIMER_Init(10000000,0,1);//1000ms

   uint8_t *mario_8192=0;
   mario_8192=mymalloc(4096);
   myfree(mario_8192);
   //LCD_Clear(GRAYBLUE);
   while(1)
   {
      // int PS2_LX,PS2_LY,PS2_RX,PS2_RY,PS2_KEY;
      // PS2_LX=PS2_AnologData(PSS_LX);
      // PS2_LY=PS2_AnologData(PSS_LY);
      // PS2_RX=PS2_AnologData(PSS_RX);
      // PS2_RY=PS2_AnologData(PSS_RY);
      // PS2_KEY=PS2_DataKey();
      // printf("%d     PS2_LX:",PS2_LX);
      // printf("%d     PS2_LY:",PS2_LY);
      // printf("%d     PS2_RX:",PS2_RX);
      // printf("%d     PS2_RY:",PS2_RY);
      // printf("%d \r\nPS2_KEY:",PS2_KEY);
       
      uint8_t x=20*(rand()%10)+30;
      uint8_t y=2*(rand()%10)+10;
      ROUTEType route;
      route.route0         = rand()%3+4;
      route.route1         = rand()%3+1;
      route.turnLine       = myplane.PosY+rand()%20-10;
      route.routeCnt       = 0;
      route.routeCircleCnt = 0;
       
      createOneEnmeyPlane(x,y,route);
      createOneBuff(50,100,BUFF_POWER,&buff);
      
      //��ͼ
      spriteRamAddr=0;
      gameScoreDraw(3,10,GameScore,&spriteRamAddr);
      myPlaneDraw(myplane.PosX,myplane.PosY,&spriteRamAddr);
      bulletDraw(&spriteRamAddr);
      enmeyPlaneDraw(&spriteRamAddr);
      boomDraw(&spriteRamAddr);
      buffDraw(&spriteRamAddr);
      for(uint8_t i=spriteRamAddr;i<SPRITE_RAM_ADDR_MAX;i++)
         writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);

      //ײ������
      enemyMapCreate(&enmeyPlane,&enemyPlaneHitMap);
      bulletsMapCreate(&bullet,&bulletsHitMap);
      myPlaneMapCreate(&myplane,&myPlaneHitMap);
      
      isMyPlaneHit(&myplane,&enemyPlaneHitMap,&buff,&myPlaneHitMap);
      isEnemyPlaneHit(&enmeyPlane,bulletsHitMap);
      isBulletsHit(&bullet,enemyPlaneHitMap);
      

      moveEnmeyPlane(&enmeyPlane);
      updateBulletData();
      updateBoomData(&boom);
      updateBuffData(&buff);
      //��ʾ����ҡ���������
      //writeOneSprite(12,0,220,10,0x10);
      //writeOneSprite(13,10,220,11,0x10);

      // uint32_t key_value=READ_KEY();

      // if(key_value==1){//����0����
      //    if(myplane.PosX>30)
      //       myplane.PosX-=5;
      // }

      // if(key_value==2){//����1����
      //    if(myplane.PosX<200)
      //       myplane.PosX+=5;
      // }

      // if(key_value==4){//����2����
      //    createOneBullet();
      // }

      // if(key_value==8){//����3����
      //    //createOneBullet();
      // } 
      delay_ms(20);
       
   }
}

