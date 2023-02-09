#ifndef LED_H
#define LED_H

//#include "CortexM0.h"
#include <stdint.h>

//LED
#define LED_BASE         (0x40001000)
//LED
void led_ctrl(uint8_t num,uint8_t on);
void LED_on(uint8_t num);
void LED_down(uint8_t num);
void LED_toggle(uint8_t num);

#endif

