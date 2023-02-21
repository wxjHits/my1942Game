#ifndef PSTWO_H
#define PSTWO_H

#include <stdint.h>
// 用于控制PS2手柄的apb外设，只是采用软件进行模拟
// BASE_ADDR 0x40005000
// 0x000 RW    PS2_CS 
// 0x004 RW    PS2_CLK
// 0x008 RW    PS2_DO 
// 0x00C  R    PS2_DI 
//-------------------------------------
#define PS2_BASE         (0x40005000)
typedef struct{
    volatile uint32_t PS2_CS    ;
    volatile uint32_t PS2_CLK   ;
    volatile uint32_t PS2_DO    ;
    volatile uint32_t PS2_DI    ;
}PS2Type;
#define PS2   ((PS2Type*)PS2_BASE)

#define CS_H (PS2->PS2_CS=1)       //CS拉高
#define CS_L (PS2->PS2_CS=0)       //CS拉低
#define CLK_H (PS2->PS2_CLK=1)     //时钟拉高
#define CLK_L (PS2->PS2_CLK=0)     //时钟拉低
#define DO_H (PS2->PS2_DO=1)        //命令位高
#define DO_L (PS2->PS2_DO=0)        //命令位低

//These are our button constants
#define PSB_SELECT      1
#define PSB_L3          2
#define PSB_R3          3
#define PSB_START       4
#define PSB_PAD_UP      5
#define PSB_PAD_RIGHT   6
#define PSB_PAD_DOWN    7
#define PSB_PAD_LEFT    8
#define PSB_L2          9
#define PSB_R2          10
#define PSB_L1          11
#define PSB_R1          12
#define PSB_GREEN       13
#define PSB_RED         14
#define PSB_BLUE        15
#define PSB_PINK        16

#define PSB_TRIANGLE    13
#define PSB_CIRCLE      14
#define PSB_CROSS       15
#define PSB_SQUARE      16

//#define WHAMMY_BAR		8

//These are stick values
#define PSS_RX 5                //右摇杆X轴数据
#define PSS_RY 6
#define PSS_LX 7
#define PSS_LY 8

extern uint8_t Data[9];
extern uint16_t MASK[16];
extern uint16_t Handkey;

uint32_t readPs2DI(void);
void PS2_Init(void);
uint8_t PS2_RedLight(void);   //判断是否为红灯模式
void PS2_ReadData(void); //读手柄数据
void PS2_Cmd(uint8_t CMD);		  //向手柄发送命令
uint8_t PS2_DataKey(void);		  //按键值读取
uint8_t PS2_AnologData(uint8_t button); //得到一个摇杆的模拟量
void PS2_ClearData(void);	  //清除数据缓冲区
void PS2_Vibration(uint8_t motor1, uint8_t motor2);//振动设置motor1  0xFF开，其他关，motor2  0x40~0xFF

void PS2_EnterConfing(void);	 //进入配置
void PS2_TurnOnAnalogMode(void); //发送模拟量
void PS2_VibrationMode(void);    //振动设置
void PS2_ExitConfing(void);	     //完成配置
void PS2_SetInit(void);		     //配置初始化

#endif
