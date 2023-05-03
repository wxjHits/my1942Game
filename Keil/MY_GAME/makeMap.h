#ifndef MAKEMAP_H
#define MAKEMAP_H

#include <stdint.h>

void makeMapFirst(uint32_t flashAddrBlock);
void makeMapSecond(uint32_t flashAddrBlock);

void loadMapJianchuan(void);
#endif
