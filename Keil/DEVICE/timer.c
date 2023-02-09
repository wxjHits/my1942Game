#include "timer.h"

//TIMER
void TIMER_Init(uint32_t reload_value,uint32_t inverse_value,uint32_t Intr_en)
{
    uint32_t temp = 0x5;
    temp = temp | (Intr_en<<1);
    TIMER->TIMER_CTRL=temp;
    TIMER->CURRENT_VALUE = 0;
    TIMER->RELOAD_VALUE = reload_value;//在50MHz的时钟下的计数值，该值设置为50—000-000即为1s
    TIMER->INVERSE_VALUE = inverse_value;//产生中断的位置,为0即可与reload_value共同配合产生中断
}

