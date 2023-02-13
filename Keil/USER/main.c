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
#include "spriteRam.h"

#include "malloc.h"
#include "stdlib.h"

PLANEType myplane;
extern SPRITEType SPRITE[64];
int main(void)
{   
    myplane.PosX=120;
    myplane.PosY=180;
    writeOneSprite(1,0x44,0x50,0x02,0);
    writeOneSprite(5,100,200,18,0);
    writeOneSprite(0,20,20,1,0x10);

//    //先执行的是函数SystemInit();
//    uart_init (UART, (50000000 / 115200), 1,1,0,0,0,0);
//    SPI_Init(100);
//    LCD_Init();
//    KEY_INIT(0xf);
//    NVIC_EnableIRQ(KEY0_IRQn);
//    NVIC_EnableIRQ(KEY1_IRQn);
//    NVIC_EnableIRQ(KEY2_IRQn);
//    NVIC_EnableIRQ(KEY3_IRQn);
////    CAMERA_Initial();//占用较多的ROM资源,有许多初始化的const uint8_t 数据，共大约
//    TIMER_Init(500000,0,1);

//    uint8_t *mario_8192=0;
//    mario_8192=mymalloc(4096);
////    SPI_Flash_Erase_Block(0);
////    SPI_Flash_Erase_Sector(0);
////    SPI_Flash_Write_NoCheck(mario_Picture_all,0,8192);
//    SPI_Flash_Read(mario_8192,0,4096);
//    for(int i=0;i<128;i++){
//        uint8_t x=0;
//        uint8_t y=0;
//        x=i%32;y=i/32;
//        Paint8x8x2bin(x*8,y*8,mario_8192+i*16);
//    }
//    Paint8x8x2bin(0,200,mario_8192+112*16);
//    Paint8x8x2bin(8,200,mario_8192+113*16);
//    Paint8x8x2bin(0,208,mario_8192+114*16);
//    Paint8x8x2bin(8,208,mario_8192+115*16);
//    
//    myfree(mario_8192);
//    
//    mario_8192=mymalloc(4096);
//    SPI_Flash_Read(mario_8192,4096,4096);
//    for(int i=0;i<128;i++){
//        uint8_t x=0;
//        uint8_t y=0;
//        x=i%32;y=i/32;
//        Paint8x8x2bin(x*8,y*8+100,mario_8192+i*16);
//    }
//    myfree(mario_8192);
//    
//    delay_ms(1000);
//    
//    LCD_Clear(GRAYBLUE);
//    
//    uint16_t y_pos=0;
//    while(1)
//    {
//        Paint_PicBin(40,50,30,72,RED,gImage_backgroud_00);
//        Paint_PicBin(10,10,6,32,WHITE,gImage_hero_48x32);
//        Paint_PicBin(100,10,4,32,WHITE,gImage_enemy01_32x32);
//        Paint_PicBin(150,10,6,48,WHITE,gImage_enemy02_48x48);
//        delay_ms(500);
//    }
}
