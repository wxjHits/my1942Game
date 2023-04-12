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

// #include "myGame.h"
#include "enemyPlane.h"
#include "enemyBullet.h"
#include "myPlane.h"
#include "gameHitCheck.h"
#include "boom.h"
#include "gameInterFace.h"
#include "backgroundPicture.h"
#include "spriteRam.h"
// #include "ahb_plane.h"

#include "malloc.h"
#include "stdlib.h"


MYPLANEType myplane;//我方飞机
const uint8_t MYPLANE_BULLET_NUMMAX=12;//我方子弹
BULLETType myBullet[MYPLANE_BULLET_NUMMAX];

const uint8_t S_GREY_NUMMAX=3;//灰色小飞机
S_GREY_PLANEType s_grey_plane[S_GREY_NUMMAX];
const uint8_t S_GREEN_NUMMAX=1;//绿色小飞机
S_GREEN_PLANEType s_green_plane[S_GREEN_NUMMAX];
const uint8_t M_STRAIGHT_NUMMAX=1;//中型直飞飞机
M_STRAIGHT_PLANEType m_straight_plane[M_STRAIGHT_NUMMAX];
const uint8_t B_GREEN_NUMMAX=1;//绿色大飞机
B_GREEN_PLANEType b_green_plane;
const uint8_t ENEMY_BULLETS_NUMMAX=5;
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];

hitMapType myPlaneHitMap;
hitMapType myBulletsHitMap;
hitMapType enemyPlaneAndBullet_HitMap;

//爆炸
const uint8_t BOOM_NUMMAX=12;
BOOMType boom[BOOM_NUMMAX];

// //BUFF
// BUFFType buff;

uint8_t timer_cnt;
uint8_t start;
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
int main(void)
{
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
   PS2_Init();
   SPI_Init(100);NAMETABLE->scrollEn=0;
   SPI_Flash_Erase_Block(0x000000);
   SPI_Flash_Erase_Block(0x001000);
   SPI_Flash_Erase_Block(0x002000);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x000000,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x000100,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x000200,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x000300,256);
   uint8_t *mario_1024=0;
   mario_1024=mymalloc(1024);
   SPI_Flash_Read(mario_1024,0x000000,1024);
   for(uint32_t i=0;i<1024;i++){
      printf("addr=%lu data=%x\n",i,mario_1024[i]);
   }
   myfree(mario_1024);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x000400,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x000500,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x000600,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x000700,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x000800,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x000900,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x000a00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x000b00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x000c00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x000d00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x000e00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x000f00,256);
   SPI_Flash_Write_Page(map_daoyu+256*0,0x001000,256);
   SPI_Flash_Write_Page(map_daoyu+256*1,0x001100,256);
   SPI_Flash_Write_Page(map_daoyu+256*2,0x001200,256);
   SPI_Flash_Write_Page(map_daoyu+256*3,0x001300,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x001400,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x001500,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x001600,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x001700,256);
   SPI_Flash_Write_Page(map_daoyu+256*0,0x001800,256);
   SPI_Flash_Write_Page(map_daoyu+256*1,0x001900,256);
   SPI_Flash_Write_Page(map_daoyu+256*2,0x001a00,256);
   SPI_Flash_Write_Page(map_daoyu+256*3,0x001b00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*0,0x001c00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*1,0x001d00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*2,0x001e00,256);
   SPI_Flash_Write_Page(map_konghaiyu+256*3,0x001f00,256);
   SPI_Flash_Write_Page(map_jianchuan+256*0,0x002000,256);
   SPI_Flash_Write_Page(map_jianchuan+256*1,0x002100,256);
   SPI_Flash_Write_Page(map_jianchuan+256*2,0x002200,256);
   SPI_Flash_Write_Page(map_jianchuan+256*3,0x002300,256);

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
         }
         else if(game_state==1){
            timer_cnt=0;
            start=0;
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
            for(int i=0;i<32;i++){
               for(int j=0;j<32;j++)
                  writeOneNametable(j,i,map_jianchuan[i*32+j]);
            }
            NAMETABLE->scrollCntMax=1;
            NAMETABLE->flashAddrStart=0x00000000;
            NAMETABLE->mapBackgroundMax=8;
            NAMETABLE->scrollEn=1;
         }
         else if(game_state==2){
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            NAMETABLE->scrollEn=0;
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
            //生成一个
            S_GREY_PLANEType planeParameter;
            planeParameter.PosX = rand()%200+15;
             if(planeParameter.PosX>myplane.PosX)
                    planeParameter.routeOneDir=DOWN_LEFT;
               else
                    planeParameter.routeOneDir=DOWN_RIGHT;
             planeParameter.isBack=rand()%2;
            s_grey_createOnePlane(&s_grey_plane,&planeParameter,myplane.PosX,myplane.PosY);
            if(NAMETABLE->mapScrollPtr==120){
               s_green_createOnePlane(&s_green_plane,myplane.PosX,myplane.PosY);
               m_straight_createOnePlane(&m_straight_plane,50+rand()%50);
               b_green_createOnePlane(&b_green_plane);
               // b_green_drawPlane(&b_green_plane,&spriteRamAddr);
            }
            //按键检测
            PS2_KEY=PS2_DataKey();
            timer_cnt+=1;
            if(timer_cnt>=16){
               timer_cnt=0;
               if((Data[4]&0x10)==0){//PS2_KEY==PSB_GREEN||保证移动的同时能够发射子弹
                  if(myplane.actFlag==0)
                     myPlane_createOneBullet(&myplane,&myBullet);
               }
               else if(PS2_KEY==PSB_RED){//施放技能
                   start=1;
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
            myPlane_Act(&myplane,&start);
            myPlane_updateBulletData(&myBullet);

            s_grey_movePlane(&s_grey_plane,&myplane,&enmeyBullets);
            s_green_movePlane(&s_green_plane,&myplane,&enmeyBullets);
            m_straight_movePlane(&m_straight_plane);
            b_green_movePlane(&b_green_plane);
            updateEnemyBulletData(&enmeyBullets);
            new_updateBoomData(&boom);
            // updateBuffData(&buff);

            //碰撞检测
            myBulletsMapCreate(&myBullet,&myBulletsHitMap);
            enemyAndBulletMapCreate(&s_grey_plane,&s_green_plane,&enmeyBullets,&enemyPlaneAndBullet_HitMap);

            // isMyPlaneHit(&myplane,&enemyPlaneAndBullet_HitMap,&boom);
            isHit_s_grey_EnemyPlane(&s_grey_plane,&s_green_plane,&myBulletsHitMap,&boom);

            //我方飞机死亡后隔一段实践再退出
            if(myplane.liveFlag==0||NAMETABLE->scrollingFlag==0){
               if(gameEndFpsCnt>=240){
                  timer_init_flag=1;
                  game_state=2;
                  // gameEndFpsCnt=0;
                  for(uint8_t i=0;i<64;i++)
                     writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
               }
            }
            gameRunState=1;
         }
         //绘图
         else if(gameRunState==2){
            spriteRamAddr=0;
            gameScoreDraw(3,10,GameScore,&spriteRamAddr);
            myPlane_Draw(&myplane,&spriteRamAddr);
            myPlane_bulletDraw(&myBullet,&spriteRamAddr);
            s_grey_drawPlane(&s_grey_plane,&spriteRamAddr);
            s_green_drawPlane(&s_green_plane,&spriteRamAddr);
            m_straight_drawPlane(&m_straight_plane,&spriteRamAddr);
            b_green_drawPlane(&b_green_plane,&spriteRamAddr);
            enmeyBulletDraw(&enmeyBullets,&spriteRamAddr);
            new_boomDraw(&boom,&spriteRamAddr);
            // buffDraw(&spriteRamAddr);
            for(uint8_t i=spriteRamAddr;i<64;i++){
               writeOneSprite(spriteRamAddr,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
               spriteRamAddr++;
            }
            gameRunState=0;
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

   // SPI_Flash_Erase_Sector(0x000000);
   // SPI_Flash_Erase_Sector(0x001000);
   //  SPI_Flash_Erase_Block(0x000000);
   // SPI_Flash_Write_Page(write_map+256*0,0x000400,256);
   // SPI_Flash_Write_Page(write_map+256*1,0x000500,256);
   // SPI_Flash_Write_Page(write_map+256*2,0x000600,256);
   // SPI_Flash_Write_Page(write_map+256*3,0x000700,256);
   // uint8_t *mario_1024=0;
   // mario_1024=mymalloc(1024);
   // SPI_Flash_Read(mario_1024,0x000000,1024);
   // for(uint32_t i=0;i<1024;i++){
   //    printf("addr=%lu data=%x\n",i,mario_1024[i]);
   // }
   // myfree(mario_1024);

   // //大型飞机
   // writeOneSprite( 0,x+ 0,y+ 0,0xc0,0x10);
   // writeOneSprite( 1,x+ 0,y+ 7,0xc1,0x10);
   // writeOneSprite( 2,x+ 0,y+14,0xc2,0x10);
   // writeOneSprite( 3,x+ 0,y+21,0xc3,0x10);
   // writeOneSprite( 4,x- 4,y+28,0xc4,0x10);
   // writeOneSprite( 5,x+ 4,y+28,0xc5,0x10);
   
   // writeOneSprite( 6,x- 7,y+05,0xc6,0x10|0x40);
   // writeOneSprite( 7,x+ 7,y+05,0xc6,0x10);

   // writeOneSprite( 8,x- 7,y+12,0xc9,0x10);
   // writeOneSprite( 9,x+ 7,y+12,0xca,0x10);

   // writeOneSprite(10,x-14,y+10,0xc8,0x10);
   // writeOneSprite(11,x+14,y+10,0xc8,0x10|0x40);
   
   // writeOneSprite(12,x-21,y+10,0xc7,0x10);
   // writeOneSprite(13,x+21,y+10,0xc7,0x10|0x40);

   // //小飞机横向右
   // writeOneSprite(0,x+ 0,y+ 0,0x59,0x10|0x40);
   // writeOneSprite(1,x+ 0,y+ 7,0x5a,0x10|0x40);
   // writeOneSprite(2,x- 8,y+ 3,0x5b,0x10|0x40);

   // //小飞机斜飞
   // writeOneSprite(0,x+ 1,y+ 1,0x5E,0x10|0x80);
   // writeOneSprite(1,x+ 8,y+ 1,0x5F,0x10|0x80);
   // writeOneSprite(2,x+ 0,y+ 8,0x5C,0x10|0x80);
   // writeOneSprite(3,x+ 8,y+ 8,0x5D,0x10|0x80);

   // //灰色小飞机转折后斜向下飞
   // writeOneSprite(0,x+ 0,y+ 0,0x50,0x00|0x40);
   // writeOneSprite(1,x+ 8,y+ 0,0x4f,0x00|0x40);
   // writeOneSprite(2,x+ 4,y- 7,0x51,0x00|0x40);
   
   