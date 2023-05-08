#include "CortexM0.h"
#include "camera.h"
#include "uart.h"
#include "led.h"
#include "lcd.h"
#include "key.h"
#include "timer.h"
#include "spi_flash.h"
#include "systick.h"
#include "pstwo.h"

#include "enemyPlane.h"
#include "makeEnemyPlaneArray.h"

#include "enemyBullet.h"
#include "myPlane.h"
#include "gameHitCheck.h"
#include "boom.h"
#include "gameInterFace.h"
#include "spriteRam.h"
#include "makeMap.h"

#include "malloc.h"
#include "stdlib.h"

MYPLANEType myplane;//我方飞机
const uint8_t MYPLANE_BULLET_NUMMAX=12;//我方子弹
BULLETType myBullet[MYPLANE_BULLET_NUMMAX];

const uint8_t S_GREY_NUMMAX=6;//灰色小飞机
S_GREY_PLANEType s_grey_plane[S_GREY_NUMMAX];
const uint8_t S_GREEN_NUMMAX=6;//绿色小飞机
S_GREEN_PLANEType s_green_plane[S_GREEN_NUMMAX];
const uint8_t M_STRAIGHT_NUMMAX=3;//中型直飞飞机
M_STRAIGHT_PLANEType m_straight_plane[M_STRAIGHT_NUMMAX];
const uint8_t B_GREEN_NUMMAX=1;//绿色大飞机
B_GREEN_PLANEType b_green_plane[B_GREEN_NUMMAX];
const uint8_t ENEMY_BULLETS_NUMMAX=10;
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];

hitMapType myPlaneHitMap;
hitMapType myBulletsHitMap;
hitMapType enemyPlaneAndBullet_HitMap;

//爆炸
const uint8_t BOOM_NUMMAX=5;
BOOMType boom[BOOM_NUMMAX];

// //BUFF
// BUFFType buff;

uint8_t timer_cnt;
uint8_t start;
bool gameingPause;//游戏暂停的标志位
// //中型飞机
// const uint8_t M_ENEMY_NUMMAX=0;
// M_PLANEType M_enmeyPlane[M_ENEMY_NUMMAX];

uint8_t spriteRamAddr=0;//draw绘图时

GAMECURSORType gameCursor;//游戏界面的“箭头”
uint32_t GameScore=0;//游戏分数

uint32_t GameShootBulletsCnt;//发射子弹的数量
uint32_t GameShootDownCnt;//游戏击落数
float GameHitRate;//游戏命中率

uint32_t fps; 

int PS2_KEY=0;

uint8_t game_state=0;
uint8_t gameEndFpsCnt;
uint8_t gameEndInterFaceFpsCnt=0;
uint8_t gameEndInterFaceFpsSpeed=59;
uint8_t gameEndInterFaceArrayCnt=0;
uint8_t  DrawFlag=0;
bool timer_init_flag=1;
uint8_t gameRunState=0;

extern uint8_t vga_intr_cnt;

extern uint8_t Data[9];//手柄获取的数据

uint32_t flashAddrBlock_Map0=0x000000;
uint32_t flashAddrBlock_Map1=0x004000;
uint8_t guanQia=0;
int main(void)
{
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   PS2_Init();
   SPI_Init(100);
//   printf("hello\n");
//   while (1){
//      PS2_KEY=PS2_DataKey();
//      printf("PS2_KEY=%d\n",PS2_KEY);
//      delay_ms(300);
//   }

   SPI_Flash_Erase_Block( 0x000000);
   SPI_Flash_Erase_Block( 0x001000);
   SPI_Flash_Erase_Block( 0x002000);
   SPI_Flash_Erase_Block( 0x003000);
   SPI_Flash_Erase_Block( 0x004000);
   SPI_Flash_Erase_Block( 0x005000);
   SPI_Flash_Erase_Block( 0x006000);
   SPI_Flash_Erase_Block( 0x007000);

   makeMapFirst(flashAddrBlock_Map1);
   makeMapSecond(flashAddrBlock_Map0);
   while(1)
   {
      /****每次到新的界面的初始化*****/
      if(timer_init_flag==1){
         timer_init_flag=0;
         if(game_state==0){
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            gameCursor.state=0;
            gameStartInterfaceShow(7,8);
            gameCursorDraw(&gameCursor);
            guanQia=0;
         }
         else if(game_state==1){
            timer_cnt=0;
            start=0;
            gameingPause=0;
            gameRunState=0;
            GameScore=0;
            GameShootBulletsCnt=0;
            GameShootDownCnt=0;
            gameEndFpsCnt=0;
            GameHitRate=0;

            myPlane_Init(&myplane);
            myPlane_bulletInit(&myBullet);
            s_grey_planeInit(&s_grey_plane);
            s_green_planeInit(&s_green_plane);
            m_straight_planeInit(&m_straight_plane);
            b_green_planeInit(&b_green_plane);
            enmey_BulletInit(&enmeyBullets);
            new_boomInit(&boom);
            // buffInit(&buff);
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            loadMapJianchuan();
            NAMETABLE->scrollCntMax=4;
            NAMETABLE->flashAddrStart=guanQia*(0x0004000);
            NAMETABLE->mapBackgroundMax=8;
            NAMETABLE->scrollEn=1;
            NAMETABLE->createPlaneIntrEn=1;
         }
         else if(game_state==2){
            NAMETABLE->scrollEn=0;
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            DrawFlag=0;
            spriteRamAddr=0;
            gameEndInterFaceFpsCnt=0;
            gameEndInterFaceArrayCnt=0;
         }
      }
/****不同界面的运行*****/
      //游戏开始选择界面
      if(game_state==0&&timer_init_flag==0){
         PS2_KEY=PS2_DataKey();
            if(PS2_KEY==PSB_PAD_UP){
               if(gameCursor.state>0){
                  gameCursor.state-=1;
                  gameCursorDraw(&gameCursor);
               }
            }
            else if(PS2_KEY==PSB_PAD_DOWN){
               if(gameCursor.state<1){
                  gameCursor.state+=1;
                  gameCursorDraw(&gameCursor);
               }
            }
            else if(PS2_KEY==PSB_GREEN && gameCursor.state==0){
               timer_init_flag=1;
               game_state=1;
            }
         delay_ms(150);
      }
      //游戏运行界面
      else if(game_state==1&&timer_init_flag==0){
         if(gameRunState==0){
            if(!(NAMETABLE->mapBackgroundCnt>=NAMETABLE->mapBackgroundMax&&NAMETABLE->mapScrollPtr<120)){
               ;
            }
            //按键检测
            PS2_KEY=PS2_DataKey();
            timer_cnt++;
            if(timer_cnt>=16){
               timer_cnt=0;
               if((Data[4]&0x10)==0){//PS2_KEY==PSB_GREEN||保证移动的同时能够发射子弹
                  if(myplane.actFlag==0)
                     myPlane_createOneBullet(&myplane,&myBullet);
               }
               else if(PS2_KEY==PSB_RED){//施放技能
                   start=1;
               }
               else if (PS2_KEY==PSB_PINK){
                  if(gameingPause==0){
                     NAMETABLE->scrollPause=1;
                     gameingPause=1;
                  }
                  else{
                     NAMETABLE->scrollPause=0;
                     gameingPause=0;
                  }
               }
               
            }
            if(timer_cnt%3==1){
               if(PS2_KEY==PSB_PAD_LEFT){
                   if(myplane.PosX>LEFT_LINE+20)
                       myplane.PosX-=5;
               }
               else if(PS2_KEY==PSB_PAD_RIGHT){
                   if(myplane.PosX<RIGHT_LINE-20)
                       myplane.PosX+=5;
               }
               else if(PS2_KEY==PSB_PAD_UP){
                   if(myplane.PosY>TOP_LINE+20)
                       myplane.PosY-=5;
               }
               else if(PS2_KEY==PSB_PAD_DOWN){
                   if(myplane.PosY<BOTTOM_LINE-20)
                       myplane.PosY+=5;
               }  
            }

            //数据更新
            if(gameingPause==1){
               ;
            }
            else{
               myPlane_Act(&myplane,&start);
               myPlane_updateBulletData(&myBullet);
               s_grey_movePlane(&s_grey_plane,&myplane,&enmeyBullets);
               s_green_movePlane(&s_green_plane,&myplane,&enmeyBullets);
               m_straight_movePlane(&m_straight_plane);
               b_green_movePlane(&b_green_plane);
               updateEnemyBulletData(&enmeyBullets);
               new_updateBoomData(&boom);
               // updateBuffData(&buff);
            }

            //碰撞检测
            // printf("NAMETABLE->mapBackgroundCnt=%u,NAMETABLE->mapScrollPtr=%u\n",NAMETABLE->mapBackgroundCnt,NAMETABLE->mapScrollPtr);
            if(NAMETABLE->mapBackgroundCnt==8&&NAMETABLE->mapScrollPtr<=120){
               for(int i=0;i<30;i++)
                  myBulletsHitMap.map[i]=0xffffffff;
            }
            else
               myBulletsMapCreate(&myBullet,&myBulletsHitMap);

            enemyAndBulletMapCreate(&s_grey_plane,&s_green_plane,&b_green_plane,&enmeyBullets,&enemyPlaneAndBullet_HitMap);

            // isMyPlaneHit(&myplane,&enemyPlaneAndBullet_HitMap,&boom);
            isHit_s_EnemyPlane(&s_grey_plane,&s_green_plane,&myBulletsHitMap,&boom);
            isHit_m_straight_EnemyPlane(&m_straight_plane,&myBulletsHitMap,&boom);
            isHit_b_EnemyPlane(&b_green_plane,&myBulletsHitMap,&boom);
            isHit_myBullets(&myBullet,&enemyPlaneAndBullet_HitMap);
            
            //我方飞机死亡后隔一段实践再退出
            if(myplane.liveFlag==0){
               if(gameEndFpsCnt>=240){
                  timer_init_flag=1;
                  game_state=2;
                  // gameEndFpsCnt=0;
               }
            }
            gameRunState=1;
         }
         //各种单位绘图
         else if(gameRunState==2){
            spriteRamAddr=0;
            if(gameingPause==1){
               writeOneSprite(spriteRamAddr,110+0 ,110,0x20,0x20);spriteRamAddr++;
               writeOneSprite(spriteRamAddr,110+16,110,0x21,0x20);spriteRamAddr++;
            }

            gameScoreDraw(3,10,GameScore,&spriteRamAddr);
            myPlane_Draw(&myplane,&spriteRamAddr);
            myPlane_bulletDraw(&myBullet,&spriteRamAddr);
            new_boomDraw(&boom,&spriteRamAddr);//爆炸显示应该在血量多的敌机的前面
            // buffDraw(&spriteRamAddr);
            s_grey_drawPlane(&s_grey_plane,&spriteRamAddr);
            s_green_drawPlane(&s_green_plane,&spriteRamAddr);
            m_straight_drawPlane(&m_straight_plane,&spriteRamAddr);
            b_green_drawPlane(&b_green_plane,&spriteRamAddr);
            enmeyBulletDraw(&enmeyBullets,&spriteRamAddr);
            for(uint8_t i=spriteRamAddr;i<64;i++){
               writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
               spriteRamAddr++;
            }
            gameRunState=0;
         }
         else if(gameRunState==3){
            guanQia++;
            if(guanQia==2){//通过最后一关的结算
               for (int i = 0; i < 6; i++){
                  spriteRamAddr=0;
                  gameScoreDraw(3,10,GameScore,&spriteRamAddr);
                  newGuanqiaInterFaceDraw(guanQia,&spriteRamAddr);
                  myPlane_Draw(&myplane,&spriteRamAddr);
                  for(uint8_t i=spriteRamAddr;i<64;i++){
                     writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
                     spriteRamAddr++;
                  }
                  delay_ms(300);
                  spriteRamAddr=0;
                  gameScoreDraw(3,10,GameScore,&spriteRamAddr);
                  myPlane_Draw(&myplane,&spriteRamAddr);
                  for(uint8_t i=spriteRamAddr;i<64;i++){
                     writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
                     spriteRamAddr++;
                  }
                  delay_ms(300);
               }
               NAMETABLE->scrollEn=0;
               gameRunState=0;
               timer_init_flag=1;
               game_state=2;
               myplane.liveFlag=0;
            }
            else{//通一小关的阶段结算画面
               for (int i = 0; i < 6; i++){
                  spriteRamAddr=0;
                  gameScoreDraw(3,10,GameScore,&spriteRamAddr);
                  newGuanqiaInterFaceDraw(guanQia,&spriteRamAddr);
                  myPlane_Draw(&myplane,&spriteRamAddr);
                  for(uint8_t i=spriteRamAddr;i<64;i++){
                     writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
                     spriteRamAddr++;
                  }
                  delay_ms(500);
                  spriteRamAddr=0;
                  gameScoreDraw(3,10,GameScore,&spriteRamAddr);
                  myPlane_Draw(&myplane,&spriteRamAddr);
                  for(uint8_t i=spriteRamAddr;i<64;i++){
                     writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
                     spriteRamAddr++;
                  }
                  delay_ms(300);
               }
               gameRunState=0;
               timer_init_flag=1;
               game_state=1;
            }
         }

      }
      //游戏结算界面
      else if(game_state==2&&timer_init_flag==0)
      {
         GameHitRate = ((float)(GameShootDownCnt))/GameShootBulletsCnt;
         endInterFaceDraw(&DrawFlag,&gameEndInterFaceArrayCnt,GameShootDownCnt,GameHitRate);
         if(gameEndInterFaceArrayCnt>=endInterFaceCharNum){
            PS2_KEY=PS2_DataKey();
            if(PS2_KEY==PSB_PINK){//退出
               game_state=0;
               timer_init_flag=1;
               gameEndInterFaceArrayCnt=0;
            }
            delay_ms(100);
         }
      }
   }
}
   // uint8_t *mario_1024=0;
   // mario_1024=mymalloc(1024);
   // SPI_Flash_Read(mario_1024,0x000000,1024);
   // for(uint32_t i=0;i<1024;i++){
   //    printf("addr=%lu data=%x\n",i,mario_1024[i]);
   // }
   // myfree(mario_1024);
