#include "uart.h"
#include <stdio.h>
#include <string.h>

/*UART driver functions*/
/**
 *
 * @brief  Initialises the UART specifying the UART Baud rate divider value and whether the send and recieve functionality is enabled. It also specifies which of the various interrupts are enabled.
 *
 * @param *uart UART Pointer
 * @param divider The value to which the UART baud rate divider is to be set
 * @param tx_en Defines whether the UART transmit is to be enabled
 * @param rx_en Defines whether the UART receive is to be enabled
 * @param tx_irq_en Defines whether the UART transmit buffer full interrupt is to be enabled
 * @param rx_irq_en Defines whether the UART receive buffer full interrupt is to be enabled
 * @param tx_ovrirq_en Defines whether the UART transmit buffer overrun interrupt is to be enabled
 * @param rx_ovrirq_en Defines whether the UART receive buffer overrun interrupt is to be enabled
 * @return 1 if initialisation failed, 0 if successful.
 */

 uint32_t  uart_init( UART_TypeDef *uart, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en)
 {
    uint32_t new_ctrl=0;

    if (tx_en!=0)        new_ctrl |=  UART_CTRL_TXEN_Msk;
    if (rx_en!=0)        new_ctrl |=  UART_CTRL_RXEN_Msk;
    if (tx_irq_en!=0)    new_ctrl |=  UART_CTRL_TXIRQEN_Msk;
    if (rx_irq_en!=0)    new_ctrl |=  UART_CTRL_RXIRQEN_Msk;
    if (tx_ovrirq_en!=0) new_ctrl |=  UART_CTRL_TXORIRQEN_Msk;
    if (rx_ovrirq_en!=0) new_ctrl |=  UART_CTRL_RXORIRQEN_Msk;

    uart->CTRL = 0;         /* Disable UART when changing configuration */
    uart->BAUDDIV = divider;
    uart->CTRL = new_ctrl;  /* Update CTRL register to new value */

    if(( uart->STATE & ( UART_STATE_RXOR_Msk |  UART_STATE_TXOR_Msk))) return 1;
    else return 0;
 }

/**
 * @param *uart UART Pointer
 * @return RxBufferFull
 * @brief  Returns whether the RX buffer is full.
 */
 uint32_t  uart_GetRxBufferFull( UART_TypeDef * uart)
 {
        return (( uart->STATE &  UART_STATE_RXBF_Msk)>>  UART_STATE_RXBF_Pos);
 }

/**
 * @param *uart UART Pointer
 * @return TxBufferFull
 * @brief  Returns whether the TX buffer is full.
 */
 uint32_t  uart_GetTxBufferFull( UART_TypeDef * uart)
 {
        return (( uart->STATE &  UART_STATE_TXBF_Msk)>>  UART_STATE_TXBF_Pos);
 }

/**
 * @param *uart UART Pointer
 * @param txchar Character to be sent
 * @return none
 * @brief  Sends a character to the TX buffer for transmission.
 */
 void  uart_SendChar( UART_TypeDef * uart, char txchar)
 {
       while( 1 ){
              if(!(uart->STATE &  UART_STATE_TXBF_Msk)) break;
       };
        uart->DATA = (uint32_t)txchar;
 }

/**
 * @param *uart UART Pointer
 * @return rxchar
 * @brief  returns the character from the RX buffer which has been received.
 */
 char  uart_ReceiveChar( UART_TypeDef * uart)
 {
       while(!( uart->STATE &  UART_STATE_RXBF_Msk));
       return (char)( uart->DATA);
 }

/**
 * @param *uart UART Pointer
 * @return 0 - No overrun
 * @return 1 - TX overrun
 * @return 2 - RX overrun
 * @return 3 - TX & RX overrun
 * @brief  returns the current overrun status of both the RX & TX buffers.
 */
 uint32_t  uart_GetOverrunStatus( UART_TypeDef *uart)
 {
        return (( uart->STATE & ( UART_STATE_RXOR_Msk |  UART_STATE_TXOR_Msk))>> UART_STATE_TXOR_Pos);
 }

/**
 * @param *uart UART Pointer
 * @return 0 - No overrun
 * @return 1 - TX overrun
 * @return 2 - RX overrun
 * @return 3 - TX & RX overrun
 * @brief  Clears the overrun status of both the RX & TX buffers and then returns the current overrun status.
 */
 uint32_t  uart_ClearOverrunStatus( UART_TypeDef *uart)
 {
        uart->STATE = ( UART_STATE_RXOR_Msk |  UART_STATE_TXOR_Msk);
        return (( uart->STATE & ( UART_STATE_RXOR_Msk |  UART_STATE_TXOR_Msk))>> UART_STATE_TXOR_Pos);
 }

/**
 * @param *uart UART Pointer
 * @return BaudDiv
 * @brief  Returns the current UART Baud rate divider. Note that the Baud rate divider is the difference between the clock frequency and the Baud frequency.
 */
 uint32_t  uart_GetBaudDivider( UART_TypeDef *uart)
 {
       return  uart->BAUDDIV;
 }

 /**
 * @param *uart UART Pointer
 * @return TXStatus
 * @brief  Returns the TX interrupt status.
 */
 uint32_t  uart_GetTxIRQStatus( UART_TypeDef *uart)
 {
       return (( uart->INTSTATUS &  UART_CTRL_TXIRQ_Msk)>> UART_CTRL_TXIRQ_Pos);
 }

/**
 * @param *uart UART Pointer
 * @return RXStatus
 * @brief  Returns the RX interrupt status.
 */
 uint32_t  uart_GetRxIRQStatus( UART_TypeDef *uart)
 {
       return (( uart->INTSTATUS &  UART_CTRL_RXIRQ_Msk)>> UART_CTRL_RXIRQ_Pos);
 }

 /**
 * @param *uart UART Pointer
 * @return none
 * @brief  Clears the TX buffer full interrupt status.
 */
 void  uart_ClearTxIRQ( UART_TypeDef *uart)
 {
        uart->INTCLEAR =  UART_CTRL_TXIRQ_Msk;
 }

/**
 * @param *uart UART Pointer
 * @return none
 * @brief  Clears the RX interrupt status.
 */
 void  uart_ClearRxIRQ( UART_TypeDef *uart)
 {
        uart->INTCLEAR =  UART_CTRL_RXIRQ_Msk;
 }

 void  uart_SendString(char *string) {
        uint32_t length,i;
        length = strlen(string);
        for(i = 0;i < length;i++) {
               uart_SendChar(UART,string[i]);
        }
}

