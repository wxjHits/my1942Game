#ifndef JY61P_H
#define JY61P_H

#include <stdint.h>

// JY61P串口接收陀螺仪      
// BASE_ADDR 0x40002000     
// 0x000 R    JY61P_ROLL    
// 0x004 R    JY61P_PITCH   
// 0x008 R    JY61P_YAW     

#define JY61P_BASE         (0x40002000)
typedef struct{
    volatile uint32_t JY61P_ROLL ;
    volatile uint32_t JY61P_PITCH;
    volatile uint32_t JY61P_YAW  ;
}JY61P_Type;
#define JY61P   ((JY61P_Type*)JY61P_BASE)

//相关的操作函数

#endif
