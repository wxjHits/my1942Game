#include "apu.h"

void set_pulse0_00(uint8_t data)
{
    *((uint8_t*)(PULSE0_00)) = data;
}

//void set_pulse0_00(uint32_t data)
//{
//    *((uint32_t*)(PULSE0_00)) = data;
//}

void set_pulse0_01(uint8_t data)
{
    *((uint8_t*)(PULSE0_01)) = data;
}

void set_pulse0_10(uint8_t data)
{
    *((uint8_t*)(PULSE0_10)) = data;
}

void set_pulse0_11(uint8_t data)
{
    *((uint8_t*)(PULSE0_11)) = data;
}

void set_pulse1_00(uint8_t data)
{
    *((uint8_t*)(PULSE1_00)) = data;
}

void set_pulse1_01(uint8_t data)
{
    *((uint8_t*)(PULSE1_01)) = data;
}

void set_pulse1_10(uint8_t data)
{
    *((uint8_t*)(PULSE1_10)) = data;
}

void set_pulse1_11(uint8_t data)
{
    *((uint8_t*)(PULSE1_11)) = data;
}

void set_triangle_00(uint8_t data)
{
    *((uint8_t*)(TRIANGLE_00)) = data;
}

void set_triangle_01(uint8_t data)
{
    *((uint8_t*)(TRIANGLE_01)) = data;
}

void set_triangle_10(uint8_t data)
{
    *((uint8_t*)(TRIANGLE_10)) = data;
}

void set_triangle_11(uint8_t data)
{
    *((uint8_t*)(TRIANGLE_11)) = data;
}

void set_noise_00(uint8_t data)
{
    *((uint8_t*)(NOISE_00)) = data;
}

void set_noise_01(uint8_t data)
{
    *((uint8_t*)(NOISE_01)) = data;
}

void set_noise_10(uint8_t data)
{
    *((uint8_t*)(NOISE_10)) = data;
}

void set_noise_11(uint8_t data)
{
    *((uint8_t*)(NOISE_11)) = data;
}

void set_state(uint8_t data)
{
    *((uint8_t*)(STATE)) = data;
}

void set_frame(uint8_t data)
{
    *((uint8_t*)(FRAME)) = data;
}
