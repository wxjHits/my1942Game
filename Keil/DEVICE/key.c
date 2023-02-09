#include "key.h"

//KEY

void KEY_INIT(uint32_t Int_open){
    KEY->KEY_INT_EN=Int_open;
//    NVIC_EnableIRQ(KEY0_IRQn);
//    NVIC_EnableIRQ(KEY1_IRQn);
//    NVIC_EnableIRQ(KEY2_IRQn);
//    NVIC_EnableIRQ(KEY3_IRQn);
}

uint32_t READ_KEY(void)
{
    return KEY->DATA_READ;
}

