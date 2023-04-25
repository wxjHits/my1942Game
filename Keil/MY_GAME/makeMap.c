#include "makeMap.h"
#include "backgroundPicture.h"
#include "spi_flash.h"
#include "spriteRam.h"

void makeMapFirst(uint32_t flashAddrBlock){//四张地图1block 65536Byte,一关卡最多16map 4blocks
    // SPI_Flash_Erase_Block(flashAddrBlock+0x000000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x001000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x002000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x003000);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000000,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000100,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000200,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000300,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000400,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000500,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000600,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000700,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000800,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000900,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000a00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000b00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000c00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000d00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000e00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000f00,256);
    SPI_Flash_Write_Page(map_daoyu+256*0,flashAddrBlock+0x001000,256);
    SPI_Flash_Write_Page(map_daoyu+256*1,flashAddrBlock+0x001100,256);
    SPI_Flash_Write_Page(map_daoyu+256*2,flashAddrBlock+0x001200,256);
    SPI_Flash_Write_Page(map_daoyu+256*3,flashAddrBlock+0x001300,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x001400,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x001500,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x001600,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x001700,256);
    SPI_Flash_Write_Page(map_daoyu+256*0,flashAddrBlock+0x001800,256);
    SPI_Flash_Write_Page(map_daoyu+256*1,flashAddrBlock+0x001900,256);
    SPI_Flash_Write_Page(map_daoyu+256*2,flashAddrBlock+0x001a00,256);
    SPI_Flash_Write_Page(map_daoyu+256*3,flashAddrBlock+0x001b00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x001c00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x001d00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x001e00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x001f00,256);
    SPI_Flash_Write_Page(map_jianchuan+256*0,flashAddrBlock+0x002000,256);
    SPI_Flash_Write_Page(map_jianchuan+256*1,flashAddrBlock+0x002100,256);
    SPI_Flash_Write_Page(map_jianchuan+256*2,flashAddrBlock+0x002200,256);
    SPI_Flash_Write_Page(map_jianchuan+256*3,flashAddrBlock+0x002300,256);
}

void makeMapSecond(uint32_t flashAddrBlock){
    // SPI_Flash_Erase_Block(flashAddrBlock+0x000000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x001000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x002000);
    // SPI_Flash_Erase_Block(flashAddrBlock+0x003000);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000000,256);//0
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000100,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000200,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000300,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x000400,256);//1
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x000500,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x000600,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x000700,256);
    SPI_Flash_Write_Page(map_land_0+256*0,flashAddrBlock+0x000800,256);//2
    SPI_Flash_Write_Page(map_land_0+256*1,flashAddrBlock+0x000900,256);
    SPI_Flash_Write_Page(map_land_0+256*2,flashAddrBlock+0x000a00,256);
    SPI_Flash_Write_Page(map_land_0+256*3,flashAddrBlock+0x000b00,256);
    SPI_Flash_Write_Page(map_land_1+256*0,flashAddrBlock+0x000c00,256);//3
    SPI_Flash_Write_Page(map_land_1+256*1,flashAddrBlock+0x000d00,256);
    SPI_Flash_Write_Page(map_land_1+256*2,flashAddrBlock+0x000e00,256);
    SPI_Flash_Write_Page(map_land_1+256*3,flashAddrBlock+0x000f00,256);
    SPI_Flash_Write_Page(map_land_2_3+256*0,flashAddrBlock+0x001000,256);//4
    SPI_Flash_Write_Page(map_land_2_3+256*1,flashAddrBlock+0x001100,256);
    SPI_Flash_Write_Page(map_land_2_3+256*2,flashAddrBlock+0x001200,256);
    SPI_Flash_Write_Page(map_land_2_3+256*3,flashAddrBlock+0x001300,256);
    SPI_Flash_Write_Page(map_land_2_3+256*0,flashAddrBlock+0x001400,256);//5
    SPI_Flash_Write_Page(map_land_2_3+256*1,flashAddrBlock+0x001500,256);
    SPI_Flash_Write_Page(map_land_2_3+256*2,flashAddrBlock+0x001600,256);
    SPI_Flash_Write_Page(map_land_2_3+256*3,flashAddrBlock+0x001700,256);
    SPI_Flash_Write_Page(map_land_4+256*0,flashAddrBlock+0x001800,256);//6
    SPI_Flash_Write_Page(map_land_4+256*1,flashAddrBlock+0x001900,256);
    SPI_Flash_Write_Page(map_land_4+256*2,flashAddrBlock+0x001a00,256);
    SPI_Flash_Write_Page(map_land_4+256*3,flashAddrBlock+0x001b00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*0,flashAddrBlock+0x001c00,256);//7
    SPI_Flash_Write_Page(map_konghaiyu+256*1,flashAddrBlock+0x001d00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*2,flashAddrBlock+0x001e00,256);
    SPI_Flash_Write_Page(map_konghaiyu+256*3,flashAddrBlock+0x001f00,256);
    SPI_Flash_Write_Page(map_jianchuan+256*0,flashAddrBlock+0x002000,256);//8
    SPI_Flash_Write_Page(map_jianchuan+256*1,flashAddrBlock+0x002100,256);
    SPI_Flash_Write_Page(map_jianchuan+256*2,flashAddrBlock+0x002200,256);
    SPI_Flash_Write_Page(map_jianchuan+256*3,flashAddrBlock+0x002300,256);
}

void loadMapJianchuan(void){
    for(int i=0;i<32;i++){
       for(int j=0;j<32;j++)
          writeOneNametable(j,i,map_jianchuan[i*32+j]);
    }
}