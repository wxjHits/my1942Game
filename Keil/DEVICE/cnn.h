#ifndef _CNN_H
#define _CNN_H

#define CNN_FIST 1 
#define CNN_FIVE 2 
#define CNN_ONE  4 
#define CNN_SIX  8 

#include <stdint.h>

#define CNN_BASE         (0x60000000)

typedef struct{
    volatile uint32_t CNN_Result ;
}CNN_Type;
#define CNN   ((CNN_Type*)CNN_BASE)

//相关的操作函数
uint32_t read_cnn_result(void);

#endif
