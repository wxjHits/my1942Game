#include "jy61p.h"

uint8_t read_JY61P_flag(void){
    // float UP   = -35;float DOWN  = 35;
    // float LEFT = -35;float RIGHT = 35;
    // float jy61p_roll=0;
    // float jy61p_pitch=0;
    // jy61p_roll  = (float)((int16_t)(JY61P->JY61P_ROLL ))*180/32768;
    // jy61p_pitch = (float)((int16_t)(JY61P->JY61P_PITCH))*180/32768;

    int16_t UP   = -4000;int16_t DOWN  = 4000;
    int16_t LEFT = -4000;int16_t RIGHT = 4000;
    int16_t jy61p_roll=0;
    int16_t jy61p_pitch=0;
    jy61p_roll  = (int16_t)(JY61P->JY61P_ROLL );
    jy61p_pitch = (int16_t)(JY61P->JY61P_PITCH);

    uint8_t return_value =0;

    if (jy61p_roll<UP)
        return_value = 0x01;
    else if(jy61p_roll>DOWN)
        return_value = 0x02;
    
    if (jy61p_pitch<LEFT)
        return_value = return_value|0x30;
    else if(jy61p_pitch>RIGHT)
        return_value = return_value|0x40;

    return return_value;
}