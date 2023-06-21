#include "stdlib.h"
#include "CortexM3.h"
#include "uart.h"
#include "led.h"
#include "lcd.h"
#include "spi_flash.h"
#include "systick.h"
#include "pstwo.h"
#include "jy61p.h"

#include "enemyPlane.h"
#include "makeEnemyPlaneArray.h"

#include "enemyBullet.h"
#include "myPlane.h"
#include "gameHitCheck.h"
#include "boom.h"
#include "gameInterFace.h"
#include "spriteRam.h"
#include "makeMap.h"
#include "apu.h"
#include "malloc.h"


MYPLANEType myplane;//????
const uint8_t MYPLANE_BULLET_NUMMAX=12;//????
BULLETType myBullet[MYPLANE_BULLET_NUMMAX];

const uint8_t S_GREY_NUMMAX=12;//?????
S_GREY_PLANEType s_grey_plane[S_GREY_NUMMAX];
const uint8_t S_GREEN_NUMMAX=8;//?????
S_GREEN_PLANEType s_green_plane[S_GREEN_NUMMAX];
const uint8_t M_STRAIGHT_NUMMAX=3;//??????
M_STRAIGHT_PLANEType m_straight_plane[M_STRAIGHT_NUMMAX];
const uint8_t B_GREEN_NUMMAX=1;//?????
B_GREEN_PLANEType b_green_plane[B_GREEN_NUMMAX];
const uint8_t ENEMY_BULLETS_NUMMAX=10;
BULLETType enmeyBullets[ENEMY_BULLETS_NUMMAX];

hitMapType myPlaneHitMap;
hitMapType myBulletsHitMap;
hitMapType enemyPlaneAndBullet_HitMap;

//??
const uint8_t BOOM_NUMMAX=5;
BOOMType boom[BOOM_NUMMAX];

// //BUFF
// BUFFType buff;

uint8_t timer_cnt;
uint8_t start;
bool gameingPause;//????????
// //????
// const uint8_t M_ENEMY_NUMMAX=0;
// M_PLANEType M_enmeyPlane[M_ENEMY_NUMMAX];

uint8_t spriteRamAddr=0;//draw???

GAMECURSORType gameCursor;//?????ì??î
uint32_t GameScore=0;//????

uint32_t GameShootBulletsCnt;//???????
uint32_t GameShootDownCnt;//?????
float GameHitRate;//?????

uint32_t fps; 
uint8_t game_state=0;
uint8_t gameEndFpsCnt;
uint8_t gameEndInterFaceFpsCnt=0;
uint8_t gameEndInterFaceFpsSpeed=59;
uint8_t gameEndInterFaceArrayCnt=0;
uint8_t  DrawFlag=0;
bool timer_init_flag=1;
uint8_t gameRunState=0;

extern uint8_t vga_intr_cnt;

extern uint8_t Data[9];//???????

uint32_t flashAddrBlock_Map0=0x000000;
uint32_t flashAddrBlock_Map1=0x004000;
uint8_t guanQia=0;
uint8_t pifuNum=0;//?????????
uint8_t pifuNumTemp=0;//?????????

uint8_t APU_Array_Ptr=0;//APU?????????

extern uint32_t create_enmeyPlane_num;//???????????

int PS2_KEY_START=0;
int PS2_KEY_GAMING=0;
int PS2_KEY_END_OUT=0;
int PS2_KEY_PIFU=0;//???????

bool game_caozuo_mode = false;//???????bool??
int main(void)
{        
   uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);

   // JY61P??
   while (1){
      printf("ROLL=%f ; ",(float)((int16_t)(JY61P->JY61P_ROLL ))*180/32768);
      printf("PITCH=%f; ",(float)((int16_t)(JY61P->JY61P_PITCH))*180/32768);
      printf("YAW=%f\n"  ,(float)((int16_t)(JY61P->JY61P_YAW  ))*180/32768);
      delay_ms(500);
   }

   PS2_Init();
   SPI_Init(100);
    
   set_frame(0x00);
   set_state(0x0F);
      
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
      /****???????????*****/
      if(timer_init_flag==1){
         timer_init_flag=0;
         APU_Array_Ptr=0;
         if(game_state==0){//????
            NAMETABLE->ahb_Palette_H_L=1;
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            // gameCursor.state=0;
            gameStartInterfaceShow(7,8);
            gameCursorDraw(&gameCursor);
            guanQia=0;
            
            GameScore=0;
            GameShootBulletsCnt=0;
            GameShootDownCnt=0;

            create_enmeyPlane_num=0;
         }
         else if(game_state==1){//??????
            timer_cnt=0;
            start=0;
            gameingPause=0;
            gameRunState=0;
//            GameScore=0;
//            GameShootBulletsCnt=0;
//            GameShootDownCnt=0;
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
            NAMETABLE->scrollCntMax=3;//???????ì4î????
            NAMETABLE->flashAddrStart=guanQia*(0x0004000);
            NAMETABLE->mapBackgroundMax=8;
            // NAMETABLE->flashAddrStart=0x0001000;
            // NAMETABLE->mapBackgroundMax=3;
            NAMETABLE->scrollEn=1;
            NAMETABLE->createPlaneIntrEn=1;
            NAMETABLE->ahb_Palette_H_L=0;
         }
         else if(game_state==2){//??????
            NAMETABLE->scrollEn=0;
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            NAMETABLE->ahb_Palette_H_L=1;
            DrawFlag=0;
            spriteRamAddr=0;
            gameEndInterFaceFpsCnt=0;
            gameEndInterFaceArrayCnt=0;
         }
         else if(game_state==3){//??????
            NAMETABLE->scrollEn=0;
            for(uint8_t i=0;i<64;i++){
               writeOneSprite(i,RIGHT_LINE,BOTTOM_LINE,0xff,0x00);
            }
            clearNameTableAll();
            pifuNumTemp=pifuNum;
            uint8_t posx=120 , posy=32; uint8_t posy_add=62;//????3????????????tile?????tile???????????
            writeOneSprite(0,posx+0 ,posy+0,MYPLANE_ACT_0_0,0x00|0x00|0x08);
            writeOneSprite(1,posx+8 ,posy+0,MYPLANE_ACT_0_1,0x00|0x00|0x08);
            writeOneSprite(2,posx+16,posy+0,MYPLANE_ACT_0_2,0x40|0x00|0x08);
            writeOneSprite(3,posx+4 ,posy+7,MYPLANE_ACT_0_3,0x00|0x00|0x08);
            writeOneSprite(4,posx+12,posy+7,MYPLANE_ACT_0_4,0x00|0x00|0x08);

            writeOneSprite(5+0,posx+0 ,posy+posy_add+0,MYPLANE_ACT_0_0,0x00|0x20|0x08);
            writeOneSprite(5+1,posx+8 ,posy+posy_add+0,MYPLANE_ACT_0_1,0x00|0x20|0x08);
            writeOneSprite(5+2,posx+16,posy+posy_add+0,MYPLANE_ACT_0_2,0x40|0x20|0x08);
            writeOneSprite(5+3,posx+4 ,posy+posy_add+7,MYPLANE_ACT_0_3,0x00|0x20|0x08);
            writeOneSprite(5+4,posx+12,posy+posy_add+7,MYPLANE_ACT_0_4,0x00|0x20|0x08);

            writeOneSprite(50+0,posx+0 ,posy+2*posy_add+0,MYPLANE_ACT_0_0,0x00|0x30|0x00);
            writeOneSprite(50+1,posx+8 ,posy+2*posy_add+0,MYPLANE_ACT_0_1,0x00|0x30|0x00);
            writeOneSprite(50+2,posx+16,posy+2*posy_add+0,MYPLANE_ACT_0_2,0x40|0x30|0x00);
            writeOneSprite(50+3,posx+4 ,posy+2*posy_add+7,MYPLANE_ACT_0_3,0x00|0x30|0x00);
            writeOneSprite(50+4,posx+12,posy+2*posy_add+7,MYPLANE_ACT_0_4,0x00|0x30|0x00);
         }
      }

/****???????*****/
      //????????
      if(game_state==0&&timer_init_flag==0){
         PS2_KEY_START=PS2_DataKey();
            //?????????
            if(PS2_KEY_START==PSB_PAD_UP){
               apu_Button();
               if(gameCursor.state>0){
                  gameCursor.state-=1;
                  gameCursorDraw(&gameCursor);
               }
            }
            else if(PS2_KEY_START==PSB_PAD_DOWN){
               apu_Button();
               if(gameCursor.state<2){
                  gameCursor.state+=1;
                  gameCursorDraw(&gameCursor);
               }
            }

            //?????????
            else if(PS2_KEY_START==PSB_GREEN){
               apu_Button();
               if(gameCursor.state==GAME_SELECT_START){//?????ì????î
                  timer_init_flag=1;
                  game_state=1;
                  apu_Intr_Trigger();
               }
               else if(gameCursor.state==GAME_SELECT_PIFU){//?????ì????î
                  apu_Button();
                  timer_init_flag=1;
                  game_state=3;
               }
               else if (gameCursor.state==GAME_SELECT_CAOZUO){
                  apu_Button();
                  game_caozuo_mode=!game_caozuo_mode;
                  if(game_caozuo_mode==false)
                     writeOneNametable(18,20,0x11);//??ì??î?ì?î
                  else
                     writeOneNametable(18,20,0x12);//??ì??î?ì?î
               }
            }
         delay_ms(200);
      }
      //??????
      else if(game_state==1&&timer_init_flag==0){
         if(gameRunState==0){
            if(!(NAMETABLE->mapBackgroundCnt>=NAMETABLE->mapBackgroundMax&&NAMETABLE->mapScrollPtr<120)){
               ;
            }
            //????
            PS2_KEY_GAMING=PS2_DataKey();
            timer_cnt++;
            if(timer_cnt>=24){
               timer_cnt=0;
               if((Data[4]&0x10)==0){//PS2_KEY_GAMING==PSB_GREEN||?????????????
                  if(myplane.actFlag==0){
                     // apu_Shoot();
                     myPlane_createOneBullet(&myplane,&myBullet);
                  }
               }
               else if(PS2_KEY_GAMING==PSB_RED){//????
                  start=1;
               }
               else if (PS2_KEY_GAMING==PSB_PINK){
                  if(gameingPause==0){
                     NAMETABLE->scrollPause=1;
                     gameingPause=1;
                  }
                  else{
                     NAMETABLE->scrollPause=0;
                     gameingPause=0;
                     apu_Intr_Trigger();
                  }
               }
               
            }
            if(timer_cnt%3==1){
               if(PS2_KEY_GAMING==PSB_PAD_LEFT){
                   if(myplane.PosX>LEFT_LINE+20)
                       myplane.PosX-=5;
               }
               else if(PS2_KEY_GAMING==PSB_PAD_RIGHT){
                   if(myplane.PosX<RIGHT_LINE-20)
                       myplane.PosX+=5;
               }
               else if(PS2_KEY_GAMING==PSB_PAD_UP){
                   if(myplane.PosY>TOP_LINE+20)
                       myplane.PosY-=5;
               }
               else if(PS2_KEY_GAMING==PSB_PAD_DOWN){
                   if(myplane.PosY<BOTTOM_LINE-20)
                       myplane.PosY+=5;
               }
            }

            //????
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

            //????
            // printf("NAMETABLE->mapBackgroundCnt=%u,NAMETABLE->mapScrollPtr=%u\n",NAMETABLE->mapBackgroundCnt,NAMETABLE->mapScrollPtr);
            if(NAMETABLE->mapBackgroundCnt==8&&NAMETABLE->mapScrollPtr<=120){
               for(int i=0;i<30;i++)
                  myBulletsHitMap.map[i]=0xffffffff;
            }
            else
               myBulletsMapCreate(&myBullet,&myBulletsHitMap);

            enemyAndBulletMapCreate(&s_grey_plane,&s_green_plane,&b_green_plane,&enmeyBullets,&enemyPlaneAndBullet_HitMap);
            
            isMyPlaneHit(&myplane,&enemyPlaneAndBullet_HitMap,&boom);
            isHit_s_EnemyPlane(&s_grey_plane,&s_green_plane,&myBulletsHitMap,&boom);
            isHit_m_straight_EnemyPlane(&m_straight_plane,&myBulletsHitMap,&boom);
            isHit_b_EnemyPlane(&b_green_plane,&myBulletsHitMap,&boom);
            isHit_myBullets(&myBullet,&enemyPlaneAndBullet_HitMap);
            
            //???????????????
            if(myplane.liveFlag==0){
               if(gameEndFpsCnt>=240){
                  timer_init_flag=1;
                  game_state=2;
                  APU_Array_Ptr=0;
                  apu_Intr_Trigger();
                  // gameEndFpsCnt=0;
               }
            }
            gameRunState=1;
         }
         //??????
         else if(gameRunState==2){//????
            spriteRamAddr=0;
            if(gameingPause==1){
               writeOneSprite(spriteRamAddr,110+0 ,110,0x20,0x20);spriteRamAddr++;
               writeOneSprite(spriteRamAddr,110+16,110,0x21,0x20);spriteRamAddr++;
            }

            gameScoreDraw(3,10,GameScore,&spriteRamAddr);
            myPlane_Draw(&myplane,&spriteRamAddr);
            myPlane_bulletDraw(&myBullet,&spriteRamAddr);
            new_boomDraw(&boom,&spriteRamAddr);//????????????????
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
         else if(gameRunState==3){//????
            guanQia++;
            if(guanQia==2){//?????????
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
            else{//???????????
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
      //????
      else if(game_state==2&&timer_init_flag==0){
         GameHitRate = ((float)(GameShootDownCnt))/GameShootBulletsCnt;
         endInterFaceDraw(&DrawFlag,&gameEndInterFaceArrayCnt,GameScore,GameShootDownCnt,GameHitRate);
         if(gameEndInterFaceArrayCnt>=endInterFaceCharNum){
            PS2_KEY_END_OUT=PS2_DataKey();
            if(PS2_KEY_END_OUT==PSB_PINK){//??
               apu_Button();
               game_state=0;
               apu_Intr_Trigger();
               timer_init_flag=1;
               gameEndInterFaceArrayCnt=0;
            }
            delay_ms(100);
         }
      }
      //????????
      else if(game_state==3&&timer_init_flag==0){
            //????3????????????tile?????tile???????????            
            uint8_t posx=120 , posy=32; uint8_t posy_add=62;
            writeOneSprite(10+5,posx-8,posy+pifuNumTemp*posy_add,0x25,0x0);

            PS2_KEY_PIFU=PS2_DataKey();
            //?????????
            if(PS2_KEY_PIFU==PSB_PAD_UP){
               apu_Button();
               if(pifuNumTemp>0)
                  pifuNumTemp--;
            }
            else if(PS2_KEY_PIFU==PSB_PAD_DOWN){
               apu_Button();
               if(pifuNumTemp<2)
                  pifuNumTemp++;
            }
            else if(PS2_KEY_PIFU==PSB_PINK){//?????????????
                  apu_Button();
                  pifuNum=pifuNumTemp;
                  timer_init_flag=1;
                  game_state=0;
                  apu_Intr_Trigger();
            }
            delay_ms(300);
      }
   }
}
/***************?????????????******************/
// #include <stdint.h>
// #include "lcd.h"
// #include "systick.h"
// #include "uart.h"
// #include "led.h"
// #include "spi_flash.h"
// #include "malloc.h"
// #include "pstwo.h"
// #include "backgroundPicture.h"
// #include "spriteRam.h"
// #include "apu.h"

// int PS2_KEY_END_OUT=0;

// int main(void)
// {
//     PS2->PS2_CLK=1;PS2->PS2_CLK=0;
//     PS2->PS2_CS=1;PS2->PS2_CS=0;
//     PS2->PS2_DO=1;PS2->PS2_DO=0;
    
//     SPRITERAM->SPRITE[1].SPRITE_POSX=0x55;
//     SPRITERAM->SPRITE[1].SPRITE_POSY=0x66;
//     SPRITERAM->SPRITE[1].SPRITE_TILEINDEX=0x77;
//     SPRITERAM->SPRITE[1].BYTE0=0x88;
//     SPRITERAM->SPRITE[2].SPRITE_POSX=0x75;
//     SPRITERAM->SPRITE[2].SPRITE_POSY=0x66;
//     SPRITERAM->SPRITE[2].SPRITE_TILEINDEX=0x20;
//     SPRITERAM->SPRITE[2].BYTE0=0x88;
    
//     NAMETABLE->scrollEn=0;
//     NAMETABLE->flashAddrStart=0x555666;
    
//     NAMETABLE->NAMETABLE_VALUE[0][0]=0xaa;
//     NAMETABLE->NAMETABLE_VALUE[0][1]=0x00;
//     NAMETABLE->NAMETABLE_VALUE[0][2]=0x01;
//     NAMETABLE->NAMETABLE_VALUE[1][0]=0x02;
//     NAMETABLE->NAMETABLE_VALUE[1][1]=0x02;
//     NAMETABLE->NAMETABLE_VALUE[1][2]=0x02;
    
//     set_frame(0x00);
//     set_state(0x0F);
//     //±¨’®“Ù–ß
//     set_noise_00(0x8F);
//     set_noise_01(0x00);
//     set_noise_10(0x95);
//     set_noise_11(0x98);
//     uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);

//     SPI_Init(100);
//     SPI_Flash_Erase_Block(0x000000);
//     SPI_Flash_Write_Page(map_jianchuan+256*0,0x000000,256);
//     uint8_t* mario_1024;
//     mario_1024=mymalloc(1024);
//     SPI_Flash_Read(mario_1024,0x000000,1024);
//     for(uint32_t i=0;i<1024;i++){
//        printf("addr=%lu data=%x\n",i,mario_1024[i]);
//     }
//     myfree(mario_1024);

//     PS2_Init();
    
//     while(1) 
//     {
//         printf("hello\n");
//         PS2_KEY_END_OUT=PS2_DataKey();
//         printf("PS2_KEY_END_OUT=%d\n",PS2_KEY_END_OUT);
//         LED_toggle(0);
//         delay_ms(500);
//         LED_toggle(1);
//         delay_ms(500);
//     }
// }

