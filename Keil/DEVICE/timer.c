#include "timer.h"

//TIMER
void TIMER_Init(uint32_t reload_value,uint32_t inverse_value,uint32_t Intr_en)
{
    uint32_t temp = 0x5;
    temp = temp | (Intr_en<<1);
    TIMER->TIMER_CTRL=temp;
    TIMER->CURRENT_VALUE = 0;
    TIMER->RELOAD_VALUE = reload_value;//��50MHz��ʱ���µļ���ֵ����ֵ����Ϊ50��000-000��Ϊ1s
    TIMER->INVERSE_VALUE = inverse_value;//�����жϵ�λ��,Ϊ0������reload_value��ͬ��ϲ����ж�
}

