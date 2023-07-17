#include "CortexM3.h"
#include "systick.h"

#include "led.h"
#include "gameStruct.h"
#include "makeEnemyPlaneArray.h"
#include "spriteRam.h"
#include "stdlib.h"
#include "cnn.h"
void NMIHandler(void) {
    ;
}

void HardFaultHandler(void) {
    ;
}

void MemManageHandler(void) {
    ;
}

void BusFaultHandler(void) {
    ;
}

void UsageFaultHandler(void) {
    ;
}

void SVCHandler(void) {
    ;
}

void DebugMonHandler(void) {
    ;
}

void PendSVHandler(void) {
    ;
}

void SysTickHandler(void) {
    Set_SysTick_CTRL(0);
    SCB->ICSR = SCB->ICSR | (1 << 25);
}


void UARTRXHandler(void) {
    ;
}

void UARTTXHandler(void) {
    ;
}

void UARTOVRHandler(void) {
    ;
}

bool EN_SHENGYIN;//是否打开背景声音，音效还在
void KEY0(void){
    printf("intr KEY0!!!\n");
    if(EN_SHENGYIN==true){
        NVIC_EnableIRQ(PULSE0_IRQn);
        EN_SHENGYIN=false;
        LED_on(0);
    }
    else{
        NVIC_DisableIRQ(PULSE0_IRQn);
        EN_SHENGYIN=true;
        LED_down(0);
    }
}

extern bool GAME_HIT_CHECK_FLAG;
void KEY1(void){
    printf("intr KEY1!!!\n");
    if(GAME_HIT_CHECK_FLAG==true){
        GAME_HIT_CHECK_FLAG=false;
        LED_down(1);
    }
    else{
        GAME_HIT_CHECK_FLAG=true;
        LED_on(1);
    }
}

extern uint32_t OV5640_RGB_THRESHOLD;
void KEY2(void){
    OV5640_RGB_THRESHOLD=OV5640_RGB_THRESHOLD-10;
    printf("OV5640_RGB_THRESHOLD - 10 =%u\n",OV5640_RGB_THRESHOLD);
    CNN->bus_bin_rgb_threshold=OV5640_RGB_THRESHOLD;
}
void KEY3(void){
    OV5640_RGB_THRESHOLD=OV5640_RGB_THRESHOLD+10;
    printf("OV5640_RGB_THRESHOLD + 10=%u\n",OV5640_RGB_THRESHOLD);
    CNN->bus_bin_rgb_threshold=OV5640_RGB_THRESHOLD;
}

void Timer_Handler(void){
    ;
}

extern uint8_t game_state;
extern uint8_t gameEndFpsCnt;
extern uint8_t gameRunState;
extern uint8_t gameEndInterFaceFpsCnt;
extern uint8_t DrawFlag;
extern MYPLANEType myplane;
void vga_Handler(void){
    if(game_state==1){
        if(gameRunState==1){
            if(NAMETABLE->mapBackgroundCnt==9&&NAMETABLE->scrollingFlag==0){
                gameRunState=3;
                NAMETABLE->scrollEn=0;
            }
            else
                gameRunState=2;
            if(myplane.liveFlag==0||NAMETABLE->scrollingFlag==0)
                gameEndFpsCnt+=1;
        }
    }
    else if(game_state==2){
        gameEndInterFaceFpsCnt++;
        if(gameEndInterFaceFpsCnt==10){
            gameEndInterFaceFpsCnt=0;
            DrawFlag=1;
        }
    }
}

/**************敌机生成的中断函数**************/
extern S_GREY_PLANEType s_grey_plane;
extern S_GREEN_PLANEType s_green_plane;
extern M_STRAIGHT_PLANEType m_straight_plane;
extern B_GREEN_PLANEType b_green_plane;

enum CREATE_PLANE{
    CREATE_NO=0,
    CREATE_S_GREY_1,
    CREATE_S_GREY_2_zhixia,
    CREATE_S_GREY_2_duicheng,
    CREATE_S_GREY_4_zhixia,
    CREATE_S_GREY_4_duicheng,
    CREATE_S_GREY_6,

    CREATE_S_GREEN_2_tongce,
    CREATE_S_GREEN_2_shuangce,
    CREATE_S_GREEN_4,

    CREATE_M_1,
    CREATE_M_2_binglie,

    CREATE_B,
};
extern uint32_t create_enmeyPlane_num;
uint32_t create[240]={
    //第1关
    CREATE_S_GREY_1,CREATE_S_GREY_2_duicheng,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_2_zhixia,0,CREATE_M_1,0,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_2_zhixia,
    CREATE_B,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,CREATE_S_GREY_2_duicheng,0,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,0,
    0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_4_zhixia,0,0,0,
    CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREY_2_duicheng,0,0,0,
    0,0,CREATE_S_GREEN_2_shuangce,CREATE_B,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,
    CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_4_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_1,0,
    CREATE_M_2_binglie,0,CREATE_S_GREEN_2_shuangce,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,
    CREATE_S_GREY_6,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_6,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,0,

    //第2关
    0,0,CREATE_S_GREY_6,CREATE_S_GREEN_4,CREATE_S_GREEN_4,CREATE_S_GREEN_4,CREATE_S_GREEN_4,0,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_2_zhixia,
    CREATE_S_GREEN_4,CREATE_S_GREEN_4,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,CREATE_S_GREY_2_duicheng,0,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,0,
    0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_4_zhixia,0,0,0,
    CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREY_2_duicheng,0,0,0,
    CREATE_B,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,
    CREATE_S_GREEN_2_shuangce,CREATE_S_GREY_4_zhixia,CREATE_S_GREY_1,CREATE_S_GREY_2_duicheng,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_2_zhixia,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_1,0,
    CREATE_M_2_binglie,0,CREATE_S_GREEN_2_shuangce,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,
    CREATE_S_GREY_6,0,CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_6,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,0,
};

uint32_t gesture_create[240]={
    //以下关卡为手势识别的关卡，比较简单
    //手势第1关
    CREATE_S_GREY_1,0,CREATE_S_GREEN_2_tongce,0,0,0,0,0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_2_zhixia,
    0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,0,CREATE_S_GREY_1,0,0,0,0,
    0,0,CREATE_S_GREY_2_duicheng,0,0,0,0,0,0,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_4_zhixia,0,0,0,
    CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_duicheng,0,0,0,CREATE_S_GREEN_2_shuangce,0,0,0,0,0,0,0,
    0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,
    0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREEN_2_shuangce,0,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_1,0,CREATE_S_GREY_1,0,
    CREATE_M_2_binglie,0,0,0,0,0,0,0,0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,
    CREATE_S_GREY_6,0,CREATE_S_GREEN_2_shuangce,0,0,0,0,0,0,0,0,0,0,0,0,
    //手势第2关
    CREATE_S_GREY_1,0,CREATE_S_GREEN_2_tongce,0,0,0,0,0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_2_zhixia,
    0,0,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,0,CREATE_S_GREY_1,0,0,0,0,
    0,0,CREATE_S_GREY_2_duicheng,0,0,0,0,0,0,CREATE_S_GREEN_2_tongce,0,CREATE_S_GREY_4_zhixia,0,0,0,
    CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_2_duicheng,0,0,0,CREATE_S_GREEN_2_shuangce,0,0,0,0,0,0,0,
    0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,0,CREATE_S_GREY_2_duicheng,0,0,0,
    CREATE_S_GREEN_2_shuangce,0,CREATE_S_GREY_1,0,0,CREATE_S_GREEN_2_shuangce,0,0,CREATE_S_GREY_2_zhixia,0,CREATE_S_GREY_1,CREATE_S_GREY_1,0,CREATE_S_GREY_1,0,
    CREATE_M_2_binglie,0,0,0,0,CREATE_S_GREY_6,0,0,0,0,0,0,CREATE_S_GREY_2_zhixia,0,0,
    CREATE_S_GREY_6,0,CREATE_S_GREEN_2_shuangce,0,0,0,0,0,0,0,0,0,0,0,0,
};
//一幅地图240/16=15，产生15次create_plane_Handler中断
//如果每一关为8幅地图，则有120次create_plane_Handler中断
extern bool GAME_PLAY_MODE;
uint32_t CREATE_ARRAY ;
void create_plane_Handler(void){
    printf("create_enmeyPlane_num=%d",create_enmeyPlane_num);
    if(game_state==1){
    if(GAME_PLAY_MODE==true)//手势操作模式
        CREATE_ARRAY = gesture_create[create_enmeyPlane_num];
    else
        CREATE_ARRAY = create[create_enmeyPlane_num];

    switch (CREATE_ARRAY){
    case CREATE_S_GREY_1:
        s_grey_createPlane_111(&s_grey_plane);
        break;
    case CREATE_S_GREY_2_zhixia:
        s_grey_createPlane_122(&s_grey_plane);
        break;
    case CREATE_S_GREY_2_duicheng:
        s_grey_createPlane_123(&s_grey_plane);
        break;
    case CREATE_S_GREY_4_zhixia:
        s_grey_createPlane_144(&s_grey_plane);
        break;
    case CREATE_S_GREY_4_duicheng:
        s_grey_createPlane_145(&s_grey_plane);
        break;
    case CREATE_S_GREY_6:
        s_grey_createPlane_166(&s_grey_plane);
        break;
    case CREATE_S_GREEN_2_tongce:
        s_green_createPlane_221(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_S_GREEN_2_shuangce:
        s_green_createPlane_222(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_S_GREEN_4:
        s_green_createPlane_243(&s_green_plane,myplane.PosX,myplane.PosY);
        break;
    case CREATE_M_1:
        s_green_createPlane_411(&m_straight_plane);
        break;
    case CREATE_M_2_binglie:
        s_green_createPlane_422(&m_straight_plane);
        break;
    case CREATE_B:
        b_green_createPlane_511(&b_green_plane);
        break;
    default:
        break;
    }
    create_enmeyPlane_num++;
    }
    else
        create_enmeyPlane_num=0;
}






//APU Intr
extern bool gameingPause;
extern uint8_t APU_Array_Ptr;

const uint8_t GAME_START_ARRAY_MAX=45;//开始界面
const uint8_t MY_PLANE_DEAD_ARRAY_MAX=14;//飞机死亡音效发送的最大组数
const uint8_t GAMING_ARRAY_MAX=63;//游戏进行中背景音效发送的最大组数
const uint8_t GAME_END_ARRAY_MAX=19;//游戏结算界面发送的最大组数

uint8_t APU_GAME_START_Array[GAME_START_ARRAY_MAX][4]={
    0x1F,0x84,0x00,0x03,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0x1F,0x84,0x00,0x2F,
    0xBE,0x97,0x27,0x07,
    0xBE,0x97,0x27,0x07,
    0xBE,0x97,0x27,0x07,
};

uint8_t APU_MY_PLANE_DEAD_Array[MY_PLANE_DEAD_ARRAY_MAX][8]={
    0xDF,0x7F,0xA9,0x58,0xDF,0x7F,0xC9,0x58,
    0xDF,0x7F,0xA9,0x58,0xDF,0x7F,0xBE,0x58,
    0xDF,0x7F,0xA9,0x58,0xDF,0x7F,0xC9,0x58,
    0xDF,0x7F,0xA9,0x58,0xDF,0x7F,0xC9,0x58,
    0xDF,0x7F,0x7F,0x58,0xDF,0x7F,0x97,0x58,
    0xDF,0x7F,0x7F,0x58,0xDF,0x7F,0x97,0x58,
    0xDF,0x7F,0x7F,0x58,0xDF,0x7F,0x97,0x58,
    0xDF,0x7F,0x7F,0x58,0xDF,0x7F,0x97,0x58,
    0xDF,0x7F,0x71,0x58,0xDF,0x7F,0x86,0x58,
    0xDF,0x7F,0x64,0x58,0xDF,0x7F,0x7F,0x58,
    0xDF,0x7F,0x5F,0x58,0xDF,0x7F,0x81,0x58,
    0xDF,0x7F,0x64,0x58,0xDF,0x7F,0x76,0x58,
    0xDF,0x7F,0x54,0x58,0xDF,0x7F,0x71,0x58,
    0xDF,0x7F,0x54,0x58,0xDF,0x7F,0x64,0x58,
};

uint8_t APU_GAME_END_Array[GAME_END_ARRAY_MAX][4]={
    0x9F,0x7F,0x7F,0xF8,
    0x9F,0x7F,0x64,0xF8,
    0x9F,0x7F,0x6A,0xF8,
    0x9F,0x7F,0x71,0xF8,
    0x9F,0x7F,0x78,0xF8,
    0x9F,0x7F,0x7F,0xF8,
    0x9F,0x7F,0x7F,0xF8,
    0x9F,0x7F,0x64,0xF8,
    0x9F,0x7F,0x6A,0xF8,
    0x9F,0x7F,0x71,0xF8,
    0x9F,0x7F,0x78,0xF8,
    0x9F,0x7F,0x64,0xF8,
    0x9F,0x7F,0x5F,0xF8,
    0x9F,0x7F,0x50,0xF8,
    0x9F,0x7F,0x4B,0xF8,
    0x9F,0x7F,0x3F,0xF8,
    0x9F,0x7F,0x5F,0xF8,
    0x9F,0x7F,0x5F,0xF8,
    0x9F,0x7F,0x54,0xF8,
};

uint8_t APU_GAME_ING_Array[GAMING_ARRAY_MAX][4]={
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0xA0,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xF8,
    0x8F,0x9F,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,

    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,

    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0xA0,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0xFF,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0xFF,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0xFF,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,

    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x9F,0xFF,0xB0,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x97,0xFF,0xF8,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
    0x8F,0x49,0x64,0x68,
};

void pulse0_Handler(void){
    // printf("pulse0_Handler\n");
    if(game_state==0){//游戏开始界面
        APU_Array_Ptr++;
        set_pulse0_00(APU_GAME_START_Array[APU_Array_Ptr][0]);
        set_pulse0_01(APU_GAME_START_Array[APU_Array_Ptr][1]);
        set_pulse0_10(APU_GAME_START_Array[APU_Array_Ptr][2]);
        set_pulse0_11(APU_GAME_START_Array[APU_Array_Ptr][3]);
        if(APU_Array_Ptr>GAME_START_ARRAY_MAX-1)
                APU_Array_Ptr=0;
    }
    else if(game_state==1){//游戏进行界面
        if(myplane.liveFlag==0){//飞机死亡音效播放
            APU_Array_Ptr++;
            //send MY_PLANE_DEAD array
            set_pulse0_00(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][0]);
            set_pulse0_01(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][1]);
            set_pulse0_10(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][2]);
            set_pulse0_11(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][3]);
            set_pulse1_00(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][4]);
            set_pulse1_01(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][5]);
            set_pulse1_10(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][6]);
            set_pulse1_11(APU_MY_PLANE_DEAD_Array[APU_Array_Ptr][7]);
            if(APU_Array_Ptr>MY_PLANE_DEAD_ARRAY_MAX-1)
                APU_Array_Ptr=0;
        }
        else if(gameingPause==false){//游戏进行中背景音效播放,非暂停
            APU_Array_Ptr++;
            //send GAMING array
            set_pulse0_00(APU_GAME_ING_Array[APU_Array_Ptr][0]);
            set_pulse0_01(APU_GAME_ING_Array[APU_Array_Ptr][1]);
            set_pulse0_10(APU_GAME_ING_Array[APU_Array_Ptr][2]);
            set_pulse0_11(APU_GAME_ING_Array[APU_Array_Ptr][3]);
            if(APU_Array_Ptr>=GAMING_ARRAY_MAX-1)
                APU_Array_Ptr=0;
        }
    }
    else if(game_state==2){//游戏结算界面
        //send GAME_END_ARRAY_MAX array
            set_pulse0_00(APU_GAME_END_Array[APU_Array_Ptr][0]);
            set_pulse0_01(APU_GAME_END_Array[APU_Array_Ptr][1]);
            set_pulse0_10(APU_GAME_END_Array[APU_Array_Ptr][2]);
            set_pulse0_11(APU_GAME_END_Array[APU_Array_Ptr][3]);
            APU_Array_Ptr++;
        if(APU_Array_Ptr>=GAME_END_ARRAY_MAX-1)
            APU_Array_Ptr=0;
    }
}

void pulse1_Handler(void){
    ;
}

void triangle_Handler(void){
    ;
}

void noise_Handler(void){
    ;
}

