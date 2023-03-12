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

uint8_t GAME_LOGO_1942[5][18]={
   0xD1,0xD2,0xD3,0xFF,0xD1,0xDE,0xDF,0xE0,0xFF,0xFF,0xED,0xEE,0xD3,0xFF,0xF8,0xF9,0xF9,0xE0,
   0xD4,0xD5,0xD6,0xFF,0xE1,0xE2,0xE3,0xE4,0xFF,0xEF,0xF0,0xD5,0xD6,0xFF,0xFA,0xFB,0xFC,0xE4,
   0xD7,0xD5,0xD6,0xFF,0xE5,0xE6,0xE7,0xE4,0xFF,0xF1,0xF2,0xD9,0xF3,0xFF,0xFD,0xFE,0xC0,0xC1,
   0xD8,0xD9,0xDA,0xFF,0xE8,0xE9,0xEA,0xEB,0xFF,0xF4,0xF5,0xF6,0xF7,0xFF,0xC2,0xC3,0xC4,0xD0,
   0xDB,0xDC,0xDD,0xFF,0xDB,0xDC,0xDC,0xEC,0xFF,0xFF,0xDB,0xDC,0xDD,0xFF,0xDB,0xDC,0xDC,0xDD
};
uint8_t GAME_VERSION[12]={0x17,0xFF,0x02,0x00,0x02,0x03,0xFF,0x15,0xFF,0x16,0xFF,0x18};
uint8_t GAME_START_CHAR[8]={0x10,0xFF,0x12,0xFF,0x13,0xFF,0x14,0xFF};
uint8_t GAME_STOP_CHAR[8]={0x11,0xFF,0x12,0xFF,0x13,0xFF,0x14,0xFF};

uint8_t endInterFaceArray[endInterFaceCharNum][3]={ 
   32+00,64+00,0x12,//"��"
   32+16,64+00,0x13,//"Ϸ"
   32+32,64+00,0x1B,//"��"
   32+48,64+00,0x1C,//"��"

   32+00,64+16,0x12,//"��"
   32+16,64+16,0x13,//"Ϸ"
   32+32,64+16,0x1D,//"��"
   32+48,64+16,0x1E,//"��"
   32+64,64+16,0x1F,//"��"

   110+00,160+00,0x12,//"��"
   110+16,160+00,0x13,//"Ϸ"
   110+32,160+00,0x14,//"��"
   110+48,160+00,0x15,//"��"
};
   
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
//�ҷ��ӵ�
const uint8_t BULLET_NUMMAX=20;
BULLETType bullet[BULLET_NUMMAX];
hitMapType bulletsHitMap;
//�з��ӵ�
const uint8_t ENEMY_BULLETS_NUMMAX=5;
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];
hitMapType enmeyBulletsHitMap;
//�ҷ��ɻ�
MYPLANEType myplane;
hitMapType myPlaneHitMap;
uint8_t timer_cnt;
uint8_t start;
//�з��ɻ�
const uint8_t ENEMY_NUMMAX=5;
PLANEType enmeyPlane[ENEMY_NUMMAX];
hitMapType enemyPlaneHitMap;
//��ը��λ
const uint8_t BOOM_NUMMAX=BULLET_NUMMAX;
BOOMType boom[BOOM_NUMMAX];
//BUFF��λ�����ҽ���һ����
BUFFType buff;

//��Ϸָʾ���
GAMECURSORType gameCursor;

//���л�ͼʱ��
uint8_t spriteRamAddr=0;
//����
uint32_t GameScore=0;
//֡��FPS
uint32_t fps; 

//PS2 PS2_KEY
int PS2_KEY=0;

//state machine�������״̬����
//0����ʼ����״̬
//1:��Ϸ���н���״̬
//2������״̬
uint8_t game_state=0;
uint8_t gameEndFpsCnt;//���ҷ��ɻ�ײ����ĵ�30֡�ص��������
uint8_t gameEndInterFaceFpsCnt=0;//��������֡�ʼ�����
uint8_t gameEndInterFaceFpsSpeed=59;//�������ĵڼ�֡����ʾ��һ������
uint8_t gameEndInterFaceArrayCnt=0;//��������������ʾ���������
uint8_t  DrawFlag=0;
//��Ϸ����״̬
//0:�����ײ������������
//1:�ȴ�֡�����ж�
//2:��ɻ�ͼ
uint8_t gameRunState=0;

extern uint8_t vga_intr_cnt;
int main(void)
{
   // ��ִ�е��Ǻ���SystemInit();
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   // SPI_Init(100);
   PS2_Init();		//======ps2�����˿ڳ�ʼ��
   // PS2_SetInit();	//======ps2���ó�ʼ��,���á����̵�ģʽ������ѡ���Ƿ�����޸�
   // LCD_Init();
   // KEY_INIT(0xf);
   // NVIC_EnableIRQ(KEY0_IRQn);
   // NVIC_EnableIRQ(KEY1_IRQn);
   // NVIC_EnableIRQ(KEY2_IRQn);
   // NVIC_EnableIRQ(KEY3_IRQn);
   // CAMERA_Initial();//ռ�ý϶��ROM��Դ,������ʼ����const uint8_t ���ݣ�����Լ
   // TIMER_Init(3000000,0,1);//1000ms
   // uint8_t *mario_8192=0;
   // mario_8192=mymalloc(4096);                                                                                                                                                                       
   // myfree(mario_8192);
   // LCD_Clear(RED);

   game_state=0;
   bool timer_init_flag=1;

   while(1)
   {
      if(timer_init_flag==1){
         timer_init_flag=0;
         if(game_state==0){
            for(uint8_t i=0;i<SPRITE_RAM_ADDR_MAX;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            gameCursor.state=GAME_START;
            gameStartInterfaceShow(7,8);
            gameCursorDraw(&gameCursor);
            // TIMER_Init(5000000,0,1);//100ms
         }
         else if(game_state==1){
            timer_cnt=0;
            start=0;
            gameRunState=0;
            GameScore=0;
            myPlaneInit();
            bulletInit();
            enmeyPlaneInit();
            enmeyBulletInit();
            buffInit(&buff);
            for(uint8_t i=0;i<SPRITE_RAM_ADDR_MAX;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            for(uint8_t i=0;i<30;i++){
                for(uint8_t j=0;j<32;j++)
                    writeOneNametable(j,i,0xCF);
            }
            // TIMER_Init(3000000,0,1);//160ms
         }
         else if(game_state==2){
            for(uint8_t i=0;i<SPRITE_RAM_ADDR_MAX;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            DrawFlag=0;
            spriteRamAddr=0;
            gameEndInterFaceFpsCnt=0;
            gameEndInterFaceArrayCnt=0;
         }
      }

      if(game_state==0&&timer_init_flag==0){
         PS2_KEY=PS2_DataKey();
            if(PS2_KEY==PSB_PAD_UP){//����1����
               if(gameCursor.state>GAME_START){
                  gameCursor.state-=1;
                  gameCursorDraw(&gameCursor);
               }
            }
            else if(PS2_KEY==PSB_PAD_DOWN){//����1����
               if(gameCursor.state<GAME_OTHER){
                  gameCursor.state+=1;
                  gameCursorDraw(&gameCursor);
               }
            }
            else if(PS2_KEY==PSB_GREEN && gameCursor.state==GAME_START){
               timer_init_flag=1;
               game_state=1;
               for(uint8_t i=0;i<SPRITE_RAM_ADDR_MAX;i++){
                  writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
               }
               clearNameTableAll();
            }
         delay_ms(200);
      }
      else if(game_state==1&&timer_init_flag==0){//��Ϸ�����е�״̬
         if(gameRunState==0){

         uint8_t x=20*(rand()%10)+30;
         uint8_t y=2*(rand()%10)+10;
         ROUTEType route;                         
         route.route0         = rand()%3+4;
         route.route1         = rand()%3+1;
         route.turnLine       = myplane.PosY-20-rand()%20;
         route.routeCnt       = 0;
         route.routeCircleCnt = 0;
         createOneEnmeyPlane(x,y,route);
         //ײ������
         enemyMapCreate(&enmeyPlane,&enemyPlaneHitMap);
         enemyBulletsMapCreate(&enmeyBullets,&enmeyBulletsHitMap);
         bulletsMapCreate(&bullet,&bulletsHitMap);
         myPlaneMapCreate(&myplane,&myPlaneHitMap);
         isMyPlaneHit(&myplane,&enemyPlaneHitMap,&enmeyBulletsHitMap,&buff,&myPlaneHitMap);
         isEnemyPlaneHit(&enmeyPlane,bulletsHitMap);
         isBulletsHit(&bullet,&enemyPlaneHitMap,&enmeyBulletsHitMap);

         //�л����л��ӵ����ҷ��ӵ�����ըЧ���ȵ�λ�����ݸ���
         PS2_KEY=PS2_DataKey();
            timer_cnt+=1;
            if(timer_cnt>=16){
               timer_cnt=0;
               if(PS2_KEY==PSB_GREEN){//����2����
                  if(myplane.actFlag==0)
                     createOneBullet();
               }
               else if(PS2_KEY==PSB_RED){//��������ӵ����л�
                   start=1;
               }
            }
            if(timer_cnt%3==1){
               if(PS2_KEY==PSB_PAD_LEFT){//����0����
                   if(myplane.PosX>LEFT_LINE+20)
                       myplane.PosX-=5;
               }
               else if(PS2_KEY==PSB_PAD_RIGHT){//����1����
                   if(myplane.PosX<RIGHT_LINE-20)
                       myplane.PosX+=5;
               }
               else if(PS2_KEY==PSB_PAD_UP){//����1����
                   if(myplane.PosY>TOP_LINE+20)
                       myplane.PosY-=5;
               }
               else if(PS2_KEY==PSB_PAD_DOWN){//����1����
                   if(myplane.PosY<BOTTOM_LINE-20)
                       myplane.PosY+=5;
               }  
            }
            myPlaneAct(&start);

            moveEnmeyPlane(&enmeyPlane);
            updateEnemyBulletData();
            updateBulletData();
            updateBoomData(&boom);
            updateBuffData(&buff);

            //�������
            if(myplane.liveFlag==0){
               if(gameEndFpsCnt>=240){
                  timer_init_flag=1;
                  game_state=2;
                  gameEndFpsCnt=0;
                  for(uint8_t i=0;i<SPRITE_RAM_ADDR_MAX;i++)
                     writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
               }
               else 
                  ;
            }
            gameRunState=1;
         }
         //��ͼ
         else if(gameRunState==2){
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
            gameRunState=0;
         }
      }
      else if(game_state==2&&timer_init_flag==0)
      {
         LED_toggle(1);
         endInterFaceDraw(&DrawFlag,&gameEndInterFaceArrayCnt);
         if(gameEndInterFaceArrayCnt>=endInterFaceCharNum){
            LED_toggle(5);
            PS2_KEY=PS2_DataKey();
            if(PS2_KEY==PSB_PINK){//����2����
               game_state=0;
               timer_init_flag=1;
               gameEndInterFaceArrayCnt=0;
            }
            delay_ms(100);
         }
      }
       
   }
}

