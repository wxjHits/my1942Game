#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>
//TIMER
// BASE_ADDR:0x40003000
// 0x00 RW    CTRL[1:0]
//              [2] PWM_out Enable
//              [1] Timer Interrupt Enable
//              [0] Enable
// 0x04 RW    Current Value[31:0]
// 0x08 RW    Reload Value[31:0]
// 0x0C R/Wc  Timer Interrupt
//            [0] Interrupt, right 1 to clear
// 0x10 RW    INVERSE Value[31:0]
//-------------------------------------
#define TIMER_BASE         (0x40003000)
#define TIMER_1_BASE         (0x40006000) 
typedef struct{
    volatile uint32_t TIMER_CTRL;
    volatile uint32_t CURRENT_VALUE;
    volatile uint32_t RELOAD_VALUE;
    volatile uint32_t CLR_INT;
    volatile uint32_t INVERSE_VALUE;
}TIMERType;
#define TIMER   ((TIMERType*)TIMER_BASE)
#define TIMER_1   ((TIMERType*)TIMER_1_BASE)

//TIMER
void TIMER_Init(uint32_t reload_value,uint32_t inverse_value,uint32_t Intr_en);
void TIMER_1_Init(uint32_t reload_value,uint32_t inverse_value,uint32_t Intr_en);

#endif
