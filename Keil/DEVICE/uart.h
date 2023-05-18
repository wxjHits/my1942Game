#ifndef UART_H
#define UART_H

//#include "CortexM0.h"
#include <stdint.h>

typedef struct
{
  volatile   uint32_t  DATA;          /*!< Offset: 0x000 Data Register    (R/W) */
  volatile   uint32_t  STATE;         /*!< Offset: 0x004 Status Register  (R/W) */
  volatile   uint32_t  CTRL;          /*!< Offset: 0x008 Control Register (R/W) */
  union {
    volatile const    uint32_t  INTSTATUS;   /*!< Offset: 0x00C Interrupt Status Register (R/ ) */
    volatile    uint32_t  INTCLEAR;    /*!< Offset: 0x00C Interrupt Clear Register ( /W) */
    };
  volatile   uint32_t  BAUDDIV;       /*!< Offset: 0x010 Baudrate Divider Register (R/W) */

}  UART_TypeDef;

#define UART_BASE        (0x40000000)
#define UART             ((UART_TypeDef*) UART_BASE)   

//陀螺仪
#define GYRO_UART_BASE        (0x40006000)
#define GYRO_UART             ((UART_TypeDef*) GYRO_UART_BASE)   

/*  UART DATA Register Definitions */
#define  UART_DATA_Pos               0                                            /*!<  UART_DATA_Pos: DATA Position */
#define  UART_DATA_Msk              (0xFFul <<  UART_DATA_Pos)               /*!<  UART DATA: DATA Mask */

#define  UART_STATE_RXOR_Pos         3                                            /*!<  UART STATE: RXOR Position */
#define  UART_STATE_RXOR_Msk         (0x1ul <<  UART_STATE_RXOR_Pos)         /*!<  UART STATE: RXOR Mask */

#define  UART_STATE_TXOR_Pos         2                                            /*!<  UART STATE: TXOR Position */
#define  UART_STATE_TXOR_Msk         (0x1ul <<  UART_STATE_TXOR_Pos)         /*!<  UART STATE: TXOR Mask */

#define  UART_STATE_RXBF_Pos         1                                            /*!<  UART STATE: RXBF Position */
#define  UART_STATE_RXBF_Msk         (0x1ul <<  UART_STATE_RXBF_Pos)         /*!<  UART STATE: RXBF Mask */

#define  UART_STATE_TXBF_Pos         0                                            /*!<  UART STATE: TXBF Position */
#define  UART_STATE_TXBF_Msk         (0x1ul <<  UART_STATE_TXBF_Pos )        /*!<  UART STATE: TXBF Mask */

#define  UART_CTRL_HSTM_Pos          6                                            /*!<  UART CTRL: HSTM Position */
#define  UART_CTRL_HSTM_Msk          (0x01ul <<  UART_CTRL_HSTM_Pos)         /*!<  UART CTRL: HSTM Mask */

#define  UART_CTRL_RXORIRQEN_Pos     5                                            /*!<  UART CTRL: RXORIRQEN Position */
#define  UART_CTRL_RXORIRQEN_Msk     (0x01ul <<  UART_CTRL_RXORIRQEN_Pos)    /*!<  UART CTRL: RXORIRQEN Mask */

#define  UART_CTRL_TXORIRQEN_Pos     4                                            /*!<  UART CTRL: TXORIRQEN Position */
#define  UART_CTRL_TXORIRQEN_Msk     (0x01ul <<  UART_CTRL_TXORIRQEN_Pos)    /*!<  UART CTRL: TXORIRQEN Mask */

#define  UART_CTRL_RXIRQEN_Pos       3                                            /*!<  UART CTRL: RXIRQEN Position */
#define  UART_CTRL_RXIRQEN_Msk       (0x01ul <<  UART_CTRL_RXIRQEN_Pos)      /*!<  UART CTRL: RXIRQEN Mask */

#define  UART_CTRL_TXIRQEN_Pos       2                                            /*!<  UART CTRL: TXIRQEN Position */
#define  UART_CTRL_TXIRQEN_Msk       (0x01ul <<  UART_CTRL_TXIRQEN_Pos)      /*!<  UART CTRL: TXIRQEN Mask */

#define  UART_CTRL_RXEN_Pos          1                                            /*!<  UART CTRL: RXEN Position */
#define  UART_CTRL_RXEN_Msk          (0x01ul <<  UART_CTRL_RXEN_Pos)         /*!<  UART CTRL: RXEN Mask */

#define  UART_CTRL_TXEN_Pos          0                                            /*!<  UART CTRL: TXEN Position */
#define  UART_CTRL_TXEN_Msk          (0x01ul <<  UART_CTRL_TXEN_Pos)         /*!<  UART CTRL: TXEN Mask */

#define  UART_INTSTATUS_RXORIRQ_Pos  3                                            /*!<  UART CTRL: RXORIRQ Position */
#define  UART_CTRL_RXORIRQ_Msk       (0x01ul <<  UART_INTSTATUS_RXORIRQ_Pos) /*!<  UART CTRL: RXORIRQ Mask */

#define  UART_CTRL_TXORIRQ_Pos       2                                            /*!<  UART CTRL: TXORIRQ Position */
#define  UART_CTRL_TXORIRQ_Msk       (0x01ul <<  UART_CTRL_TXORIRQ_Pos)      /*!<  UART CTRL: TXORIRQ Mask */

#define  UART_CTRL_RXIRQ_Pos         1                                            /*!<  UART CTRL: RXIRQ Position */
#define  UART_CTRL_RXIRQ_Msk         (0x01ul <<  UART_CTRL_RXIRQ_Pos)        /*!<  UART CTRL: RXIRQ Mask */

#define  UART_CTRL_TXIRQ_Pos         0                                            /*!<  UART CTRL: TXIRQ Position */
#define  UART_CTRL_TXIRQ_Msk         (0x01ul <<  UART_CTRL_TXIRQ_Pos)        /*!<  UART CTRL: TXIRQ Mask */

#define  UART_BAUDDIV_Pos            0                                            /*!<  UART BAUDDIV: BAUDDIV Position */
#define  UART_BAUDDIV_Msk            (0xFFFFFul <<  UART_BAUDDIV_Pos)        /*!<  UART BAUDDIV: BAUDDIV Mask */

/****************************UART*******************************/

 uint32_t  uart_init( UART_TypeDef * uart, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en);

  /**
   * @brief Returns whether the UART RX Buffer is Full.
   */

 uint32_t  uart_GetRxBufferFull( UART_TypeDef * uart);

  /**
   * @brief Returns whether the UART TX Buffer is Full.
   */

 uint32_t  uart_GetTxBufferFull( UART_TypeDef * uart);

  /**
   * @brief Sends a character to the UART TX Buffer.
   */


void  uart_SendChar( UART_TypeDef * uart, char txchar);

  /**
   * @brief Receives a character from the UART RX Buffer.
   */

extern char  uart_ReceiveChar(UART_TypeDef* uart);

  /**
   * @brief Returns UART Overrun status.
   */

extern uint32_t  uart_GetOverrunStatus( UART_TypeDef * uart);

  /**
   * @brief Clears UART Overrun status Returns new UART Overrun status.
   */

 extern uint32_t  uart_ClearOverrunStatus( UART_TypeDef * uart);

  /**
   * @brief Returns UART Baud rate Divider value.
   */

 extern uint32_t  uart_GetBaudDivider( UART_TypeDef * uart);

  /**
   * @brief Return UART TX Interrupt Status.
   */

 extern uint32_t  uart_GetTxIRQStatus( UART_TypeDef * uart);

  /**
   * @brief Return UART RX Interrupt Status.
   */

 extern uint32_t  uart_GetRxIRQStatus( UART_TypeDef * uart);

  /**
   * @brief Clear UART TX Interrupt request.
   */

 extern void  uart_ClearTxIRQ( UART_TypeDef * uart);

  /**
   * @brief Clear UART RX Interrupt request.
   */

 extern void  uart_ClearRxIRQ( UART_TypeDef* uart);

  /**
   * @brief Set CM3DS_MPS2 Timer for multi-shoot mode with internal clock
   */

#endif
