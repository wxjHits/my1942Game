#ifndef SPI_FLASH_H
#define SPI_FLASH_H

#include <stdint.h>

// SPI 
// BASE_ADDR:0x40004000
// 0x00 RW   [0]   SPI_CS
// 0x04 RW   [7:0] CLK_DIV
// 0x08 RW   [7:0] DATA_TX
// 0x0C RW   [0]   TX_REQ
// 0x10 R    [7:0] DATA_RX
// 0x14 R    [0]   SPI_READY
#define SPI_BASE         (0x40004000)
typedef struct{
    volatile uint32_t SPI_CS;
    volatile uint32_t SPI_CLK_DIV;
    volatile uint32_t SPI_DATA_TX;
    volatile uint32_t SPI_TX_REQ;
    volatile uint32_t SPI_DATA_RX;
    volatile uint32_t SPI_READY;
}SPIType;
#define SPI   ((SPIType*)SPI_BASE)

//SPI_FLASH
void SPI_Init(uint8_t SPI_DIV_CLK);      //SPI ʱ�ӷ�Ƶ
uint8_t Is_SPI_Ready(void);                 //����SPI READY�ź�
void SPI_SendData(uint8_t TxData);
uint8_t SPI_ReadWriteByte(uint8_t TxData);  //SPI��д�ź�

//FLASHָ���
#define W25X_WriteEnable		0x06
#define W25X_WriteDisable		0x04
#define W25X_ReadStatusReg		0x05
#define W25X_WriteStatusReg		0x01
#define W25X_ReadData			0x03
#define W25X_PageProgram		0x02
#define W25X_BlockErase			0xD8
#define W25X_SectorErase		0x20
#define W25X_ChipErase			0xC7
#define W25X_PowerDown			0xB9
#define W25X_ReleasePowerDown	0xAB
#define W25X_DeviceID			0xAB
#define W25X_ManufactDeviceID	0x90
#define W25X_JedecDeviceID		0x9F

uint16_t SPI_Flash_ReadID(void);
uint8_t  SPI_Flash_ReadSR(void);
void SPI_FLASH_Clear_SR(void);
void SPI_FLASH_Write_SR(uint8_t sr);
void SPI_FLASH_Write_Enable(void);
void SPI_FLASH_Write_Disable(void);
void SPI_Flash_Wait_Busy(void);
void SPI_Flash_Erase_Chip(void);
void SPI_Flash_Erase_Block(uint32_t Dst_BlockNum_Addr);
void SPI_Flash_Erase_Sector(uint32_t Dst_Addr);
void SPI_Flash_Write_Page(uint8_t* pBuffer,uint32_t WriteAddr,uint16_t NumByteToWrite);
void SPI_Flash_Read(uint8_t* pBuffer,uint32_t ReadAddr,uint16_t NumByteToRead);
void SPI_Flash_Write_NoCheck(uint8_t* pBuffer,uint32_t WriteAddr,uint16_t NumByteToWrite);
void SPI_Flash_Write_Max65536(uint8_t* pBuffer,uint32_t WriteAddr,uint16_t NumByteToWrite);
#endif
