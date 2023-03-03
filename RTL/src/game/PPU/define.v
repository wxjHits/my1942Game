/****************************/
//作者:Wei Xuejing
//邮箱:2682152871@qq.com
//描述:宏定义
//时间:2023.02.06
/****************************/
`define SPRITE_NUM_MAX 64
`define SPRITE_TILEROM_DEEPTH 256
`define SPRITE_TILEROM_ADDRBIT 8 //2^SPRITE_ROM_ADDRBIT=SPRITE_ROM_DEEPTH
`define SPRITE_TILEDATA_BIT 128 //一个tile为128bit的数据
`define TILE_W 8 //一个tile的像素宽度
`define TILE_H 8 //一个tile的像素高度

`define RGB_BIT 12 //RGB为12bit

`define GAME_START_POSX 0 //游戏画面开始的x坐标 0~640
`define GAME_START_POSY 0 //游戏画面开始的y坐标 0~480
`define GAME_WINDOW_WIDTH 256 //游戏画面宽度
`define GAME_WINDOW_HEIGHT 240 //游戏画面高度
`define GAME_GRID_WIDTH     32//(`GAME_WINDOW_WIDTH>>8)
`define GAME_GRID_HEIGHT    30//(`GAME_WINDOW_HEIGHT>>8)

`define VGA_POSXY_BIT 12 //VGA坐标的位宽

`define BYTE 8

//名称表相关宏定义
`define NAMETABLE_WIDTH 32
`define NAMETABLE_HEIGHT 30
`define NAMETABLE_AHBBUS_ADDRWIDTH 8 //（32*30/4）
