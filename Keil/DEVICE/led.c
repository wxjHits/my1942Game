#include "led.h"

//LED
void led_ctrl(uint8_t num,uint8_t on){
    uint32_t a=0;
    uint32_t b=0;
    b= *(uint32_t*)(LED_BASE);
    a=1<<num;
    if(on==1)
        *(uint32_t*)(LED_BASE)=b|a;
    else if(on==0)
        *(uint32_t*)(LED_BASE)=b&(~a);
    else
        *(uint32_t*)(LED_BASE)=b;
}

void LED_on(uint8_t num)
{
    uint32_t b=0;
    b= *(uint32_t*)(LED_BASE);
    *(uint32_t*)(LED_BASE)=b|(1<<num);
}
void LED_down(uint8_t num)
{
    uint32_t b=0;
    b= *(uint32_t*)(LED_BASE);
    *(uint32_t*)(LED_BASE)=b&(~(1<<num));
}
void LED_toggle(uint8_t num)
{
    uint32_t b=0;
    uint32_t temp=0;
    b= *(uint32_t*)(LED_BASE);
    temp = ((1<<num)&b);
    if(temp==0)
        *(uint32_t*)(LED_BASE)=b|(1<<num);
    else
        *(uint32_t*)(LED_BASE)=b&(~(1<<num));
}
