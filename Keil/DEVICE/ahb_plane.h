#ifndef AHB_PLANE_H
#define AHB_PLANE_H

#include <stdint.h>

/********************************************/
/*   AHB_PLANE                              */
/*   update_clk     0X5003_0000             */
/*   create         0X5003_0004             */
/*   Hit            0X5003_0008             */
/*   Init_POS_X     0X5003_000C             */
/*   Init_POS_Y     0X5003_0010             */
/*   Init_HP        0X5003_0014             */
/*   Init_Y_TURN0   0X5003_0018             */
/*   Init_Y_TURN1   0X5003_001C             */
/*   Init_Y_TURN2   0X5003_0020             */
/*   Init_Y_TURN3   0X5003_0024             */
/*   Init_X_TURN0   0X5003_0028             */
/*   Init_X_TURN1   0X5003_002C             */
/*   PosX_out       0X5003_0030             */
/*   PosY_out       0X5003_0034             */
/*   Attitude       0X5003_0038             */
/*   isLive         0X5003_003C             */
/********************************************/
#define AHBPLANE_BASE         (0x50030000UL)
typedef struct {
    volatile uint32_t update_clk; 
    volatile uint32_t create; 
    volatile uint32_t Hit; 
    volatile uint32_t Init_POS_X; 
    volatile uint32_t Init_POS_Y;
    volatile uint32_t Init_HP;
    volatile uint32_t Init_Y_TURN0;
    volatile uint32_t Init_Y_TURN1;
    volatile uint32_t Init_Y_TURN2;
    volatile uint32_t Init_Y_TURN3;
    volatile uint32_t Init_X_TURN0;
    volatile uint32_t Init_X_TURN1;
    volatile uint32_t PosX_out;
    volatile uint32_t PosY_out;
    volatile uint32_t Attitude;
    volatile uint32_t isLive;
}AHBPLANEType;
#define AHBPLANE              ((AHBPLANEType        *) AHBPLANE_BASE    )

void ahb_plane_Init(uint8_t Init_X,uint8_t Init_Y);
void ahb_plane_create(void);
void ahb_plane_Update(void);
void ahb_plane_showAttitude(void);

#endif

