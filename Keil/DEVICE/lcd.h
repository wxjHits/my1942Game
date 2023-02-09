#ifndef LCD_H
#define LCD_H

//#include "CortexM0.h"
#include <stdint.h>

//LCD
/**********************************************/
/*   LCD_CS           0X5000_0000             */
/*   LCD_RS           0X5000_0004             */
/*   LCD_WR           0X5000_0008             */
/*   LCD_RD           0X5000_000C             */
/*   LCD_RST          0X5000_0010             */
/*   LCD_BL_CTR       0X5000_0014             */
/*   LCD_DATA         0X5000_0018             */
/**********************************************/
#define LCD_BASE         (0x50000000UL)
typedef struct {
    volatile uint32_t LCD_CS; 
    volatile uint32_t LCD_RS; 
    volatile uint32_t LCD_WR; 
    volatile uint32_t LCD_RD; 
    volatile uint32_t LCD_RST;
    volatile uint32_t LCD_BL_CTR;
    volatile uint32_t LCD_DATA;
}LCDType;
#define LCD              ((LCDType        *) LCD_BASE    )

typedef struct  
{										    
	uint16_t width;			
	uint16_t height;			
	uint16_t id;				
	uint8_t  dir;			
	uint16_t wramcmd;		
	uint16_t setxcmd;		
	uint16_t setycmd;		
}_lcd_dev; 
extern _lcd_dev lcddev;

extern uint16_t  POINT_COLOR;  
extern uint16_t  BACK_COLOR; 
//      BASIC SIGNAL SET AND CLEAR
#define LCD_CS_SET         (LCD->LCD_CS        = 1) 	 
#define LCD_RS_SET         (LCD->LCD_RS        = 1) 
#define LCD_WR_SET         (LCD->LCD_WR        = 1) 
#define LCD_RD_SET         (LCD->LCD_RD        = 1) 
#define LCD_RST_SET        (LCD->LCD_RST       = 1)
#define LCD_BL_CTR_SET     (LCD->LCD_BL_CTR    = 1)
     
#define LCD_CS_CLR         (LCD->LCD_CS        = 0) 	 
#define LCD_RS_CLR         (LCD->LCD_RS        = 0) 
#define LCD_WR_CLR         (LCD->LCD_WR        = 0) 
#define LCD_RD_CLR         (LCD->LCD_RD        = 0) 
#define LCD_RST_CLR        (LCD->LCD_RST       = 0)
#define LCD_BL_CTR_CLR     (LCD->LCD_BL_CTR    = 0)

//      SCANNING DIRECTION
#define L2R_U2D  0 // LEFT TO RIGHT, UP TO DOWN
#define L2R_D2U  1 // LEFT TO RIGHT, DOWN TO UP
#define R2L_U2D  2 // RIGHT TO LEFT, UP TO DOWN
#define R2L_D2U  3 // RIGHT TO LEFT, DOWN TO UP

#define U2D_L2R  4 // UP TO DOWN, LEFT TO RIGHT
#define U2D_R2L  5 // UP TO DOWN, RIGHT TO LEFT
#define D2U_L2R  6 // DOWN TO UP, LEFT TO RIGHT
#define D2U_R2L  7 // DOWN TO UP, RIGHT TO LEFT

#define DFT_SCAN_DIR    L2R_U2D // DEFAULT

//  PEN COLOR
#define WHITE         	 0xFFFF
#define BLACK         	 0x0000	  
#define BLUE         	 0x001F  
#define BRED             0XF81F
#define GRED 			 0XFFE0
#define GBLUE			 0X07FF
#define RED           	 0xF800
#define MAGENTA       	 0xF81F
#define GREEN         	 0x07E0
#define CYAN          	 0x7FFF
#define YELLOW        	 0xFFE0
#define BROWN 			 0XBC40 
#define BRRED 			 0XFC07 
#define GRAY  			 0X8430 

//  GUI COLOR ( COLOR OF PANEL )
#define DARKBLUE      	 0X01CF	
#define LIGHTBLUE      	 0X7D7C	 
#define GRAYBLUE       	 0X5458 


#define LIGHTGREEN     	 0X841F 
#define LGRAY 			 0XC618 // BACKGROUND COLOR OF WINDOW

#define LGRAYBLUE        0XA651 // MIDDLE LAYER COLOR
#define LBBLUE           0X2B12 // COLOR OF SWITCHED

//  LCD RESOLUTION
#define SSD_HOR_RESOLUTION		800		// LCD HORIZON RESOLUTION
#define SSD_VER_RESOLUTION		480		// LCD VERTICAL RESOLUTION

//  LCD DRIVING PARAMETER
#define SSD_HOR_PULSE_WIDTH		1		
#define SSD_HOR_BACK_PORCH		46		
#define SSD_HOR_FRONT_PORCH		210		

#define SSD_VER_PULSE_WIDTH		1		
#define SSD_VER_BACK_PORCH		23		
#define SSD_VER_FRONT_PORCH		22		

//  AUTO CALCULATE
#define SSD_HT	(SSD_HOR_RESOLUTION+SSD_HOR_BACK_PORCH+SSD_HOR_FRONT_PORCH)
#define SSD_HPS	(SSD_HOR_BACK_PORCH)
#define SSD_VT 	(SSD_VER_RESOLUTION+SSD_VER_BACK_PORCH+SSD_VER_FRONT_PORCH)
#define SSD_VPS (SSD_VER_BACK_PORCH)

void LCD_Init(void);									
void LCD_DisplayOn(void);													
void LCD_DisplayOff(void);													
void LCD_Clear(uint16_t Color);	 											
void LCD_SetCursor(uint16_t Xpos, uint16_t Ypos);							
void LCD_DrawPoint(uint16_t x,uint16_t y);									
void LCD_Fast_DrawPoint(uint16_t x,uint16_t y,uint16_t color);							
uint16_t  LCD_ReadPoint(uint16_t x,uint16_t y); 										
void LCD_Draw_Circle(uint16_t x0,uint16_t y0,uint8_t r);						 		
void LCD_DrawLine(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2);					
void LCD_DrawRectangle(uint16_t x1, uint16_t y1, uint16_t x2, uint16_t y2);		   		
void LCD_Fill(uint16_t sx,uint16_t sy,uint16_t ex,uint16_t ey,uint16_t color);		   	
void LCD_Color_Fill(uint16_t sx,uint16_t sy,uint16_t ex,uint16_t ey,uint16_t *color);	
void LCD_ShowChar(uint16_t x,uint16_t y,uint8_t num,uint8_t mode);			
void LCD_ShowNum(uint16_t x,uint16_t y,uint32_t num,uint8_t len);  					
void LCD_ShowxNum(uint16_t x,uint16_t y,uint32_t num,uint8_t len,uint8_t mode);				
void LCD_ShowString(uint16_t x,uint16_t y,uint16_t width,uint16_t height,uint8_t *p);		
void LCD_WriteReg(uint16_t LCD_Reg, uint16_t LCD_RegValue);
uint16_t LCD_ReadReg(uint16_t LCD_Reg);
void Show_Str(uint16_t x, uint16_t y, uint16_t fc, uint16_t bc, uint8_t *str,uint8_t size,uint8_t mode);
void LCD_WriteRAM_Prepare(void);
void LCD_WriteRAM(uint16_t RGB_Code);
void LCD_SSD_BackLightSet(uint8_t pwm);							
void LCD_Scan_Dir(uint8_t dir);									
void LCD_Display_Dir(uint8_t dir);
void LCD_Set_Window(uint16_t sx,uint16_t sy,uint16_t width,uint16_t height);
void Gui_Drawbmp16(uint16_t x,uint16_t y,const unsigned char *p); //??40*40 QQ??
void LCD_WR_DATA( uint16_t data );

//2023.01.10 ADD 
void Paint_PicBin(uint16_t x0,uint16_t y0,uint16_t width_byte,uint16_t height_byte,uint16_t color,uint8_t *p);
void Paint8x8x2bin(uint16_t x0,uint16_t y0,uint8_t *p);

#endif

