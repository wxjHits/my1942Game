#include "CortexM0.h"
#include "systick.h"
#include "uart.h"
#include "camera.h"
#include "lcd.h"
#include "led.h"
#include "spriteRam.h"

void NMIHandler(void) {
    ;
}

void HardFaultHandler(void) {
    ;
}

void MemManageHandler(void) {
    ;
}

void BusFaultHandler(void) {
    ;
}

void UsageFaultHandler(void) {
    ;
}

void SVCHandler(void) {
    ;
}

void DebugMonHandler(void) {
    ;
}

void PendSVHandler(void) {
    ;
}

void SysTickHandler(void) {
    Set_SysTick_CTRL(0);
    SCB->ICSR = SCB->ICSR | (1 << 25);
}


void UARTRXHandler(void) {
    uart_ClearRxIRQ(UART);
    LED_toggle(1);
    printf("uart_rx int occur!!!\n");
}

void UARTTXHandler(void) {
    uart_ClearTxIRQ(UART);
    LED_toggle(2);
    LCD_ShowString(0,0,240,320,"UARTTX_IRQn OCCURED!!!");
}

void UARTOVRHandler(void) {
    ;
}

//KEY INT
extern PLANEType myplane; 
void KEY0(void){
    LED_toggle(0);
    if(myplane.PosX<200)
        myplane.PosX+=5;
    //    photo();
//    uint16_t x, y;
//    for (x = 0; x < 240; x++){
//        for (y = 0; y < 320; y++) 
//            LCD_Fast_DrawPoint(y, x, CAMERA->CAMERA_VALUE[x][y]);
//    }
}

void KEY1(void){
    LED_toggle(1);
    if(myplane.PosX>30)
        myplane.PosX-=5;
}


void KEY2(void){
    LED_toggle(2);
    if(myplane.PosY<200)
        myplane.PosY+=5;
}

void KEY3(void){
    LED_toggle(3);
    if(myplane.PosY>30)
        myplane.PosY-=5;
}

//Timer
void Timer_Handler(void){
    myPlaneDraw(myplane.PosX,myplane.PosY);
    LED_toggle(7);
}






