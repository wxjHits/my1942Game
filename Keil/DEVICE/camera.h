#ifndef CAMERA_H
#define CAMERA_H

//#include "CortexM0.h"
#include <stdint.h>

// CAMERA
//CAMERA CONFIG DEF
#define CAMERA_CONFIG_BASE 0x40050000UL
typedef struct{
    volatile uint32_t CAMERA_CONFIG_RST;
    volatile uint32_t CAMERA_CONFIG_PWDN;
    volatile uint32_t CAMERA_CONFIG_SCL;
    volatile uint32_t CAMERA_CONFIG_SDAO;
    volatile uint32_t CAMERA_CONFIG_SDAI;
    volatile uint32_t CAMERA_CONFIG_SDAOEN;
    volatile uint32_t CAMERA_DATA_STATE;
}CAMERA_CONFIGType;

//CAMERA DEF
#define CAMERA_BASE 0x40010000UL
typedef struct{
    volatile uint16_t CAMERA_VALUE[240][320];
}CAMERAType;

#define CAMERA_CONFIG ((CAMERA_CONFIGType *)CAMERA_CONFIG_BASE)
#define CAMERA ((CAMERAType *)CAMERA_BASE)

/*************************************CAMERA*******************************************/
void Set_CAMERA_SDA_W(void);
void Set_CAMERA_SDA_R(void);
void Set_CAMERA_SCL(void);
void Clr_CAMERA_SCL(void);
void Set_CAMERA_RST(void);
void Clr_CAMERA_RST(void);
void Set_CAMERA_PWDN(void);
void Clr_CAMERA_PWDN(void);
void Set_CAMERA_SDA(void);
uint32_t Read_CAMERA_SDA(void);
void Clr_CAMERA_SDA(void);
void CAMERA_Start(void);
void CAMERA_Stop(void);
void CAMERA_Waite(void);
void CAMERA_Write_Byte(uint8_t data);
void CAMERA_Command(uint8_t addr_h,uint8_t addr_l,uint8_t data);
void CAMERA_Data(uint8_t data);
void CAMERA_Initial(void);
uint32_t Read_CAMERA_DATA_STATE(void);
void Set_CAMERA_DATA_STATE(uint32_t state);
uint32_t Read_CAMERA_DATA_LEN(void);
uint8_t CAMERA_Read_Byte(void);
uint8_t CAMERA_Read_Reg(uint16_t reg);
uint8_t CAMERA_Focus_Init(void);
void CAMERA_Light_Mode(void);	
void CAMERA_Color_Saturation(void);
void CAMERA_Brightness(void);	
void CAMERA_Contrast(void);	
void CAMERA_Sharpness(void);	
uint8_t CAMERA_Focus_Constant(void);
void CAMERA_NA(void);
void photo(void);
#endif

