#ifndef KEY_H
#define KEY_H

#include <stdint.h>

//APB KEY INT ¾ØÕó¼üÅÌ
//BASE_ADDR 0x40002000
// 0x000 RW    Data read
// 0x004 RW    Interrupt Enable Set
// 0x008 R     Interrupt Status
#define KEY_BASE         (0x40002000)
typedef struct{
    volatile uint32_t DATA_READ;
    volatile uint32_t KEY_INT_EN;
    volatile uint32_t KEY_INT_STATE;
}KEYType;
#define KEY   ((KEYType*)KEY_BASE)

//KEY
void KEY_INIT(uint32_t Int_open);//ÊÇ·ñ¿ªÆôÖÐ¶Ï
uint32_t READ_KEY(void);

#endif
