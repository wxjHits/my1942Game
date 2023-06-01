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


void apu_Button(void){
    // set_pulse1_00(0x9F);
    // set_pulse1_01(0xFF);
    // set_pulse1_10(0x0F);
    // set_pulse1_11(0x9C);
    // set_pulse0_00(0x8F);          
    // set_pulse0_01(0x49);
    // set_pulse0_10(0x64);
    // set_pulse0_11(0x88);
    set_pulse0_00(0x8F);
    set_pulse0_01(0x49);
    set_pulse0_10(0xFF);
    set_pulse0_11(0x48);

}
void apu_Intr_Trigger(void){
    // set_pulse0_00(0x9F);
    // set_pulse0_01(0xFF);
    // set_pulse0_10(0x0F);
    // set_pulse0_11(0x8C);
    set_pulse0_00(0x80);
    set_pulse0_01(0x49);
    set_pulse0_10(0x00);
    set_pulse0_11(0x38);
}

void apu_Shoot(void){
    // set_pulse0_00(0x8F);          
    // set_pulse0_01(0x49);
    // set_pulse0_10(0x64);
    // set_pulse0_11(0x08);
    set_pulse0_00(0x8F);
    set_pulse0_01(0x49);
    set_pulse0_10(0x64);
    set_pulse0_11(0x48);

}