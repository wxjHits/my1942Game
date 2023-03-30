`timescale 1ns/1ps

module tb_flashToNametable();

    reg         clk                     ;//系统时钟
    reg         rstn                    ;//系统复位型号
    reg  [23:0] flashAddrNametable      ;
    reg  [23:0] flashAddrAttribute      ;
    reg         flashReadNametableFlag  ;
    reg         flashReadAttributeFlag  ;
    reg  [08:0] nametableRamAddrStart   ;
    reg  [08:0] attributeRamAddrStart   ;
    wire        SPI_CLK                 ;
    wire        SPI_CS                  ;
    wire        SPI_MOSI                ;
    reg         SPI_MISO                ;

    flashToNametable tb_u_flashToNametable(
    //clk & rstn
        .clk (clk )            ,   //系统时钟
        .rstn(rstn)            ,   //系统复位型号
        //scrollCtrl
        .flashAddrNametable    (flashAddrNametable    )  ,
        .flashAddrAttribute    (flashAddrAttribute    )  ,
        .flashReadNametableFlag(flashReadNametableFlag)  ,
        .flashReadAttributeFlag(flashReadAttributeFlag)  ,
        .nametableRamAddrStart (nametableRamAddrStart )  ,
        .attributeRamAddrStart (attributeRamAddrStart )  ,
        //SPI
        .SPI_CLK (SPI_CLK )        ,
        .SPI_CS  (SPI_CS  )        ,
        .SPI_MOSI(SPI_MOSI)        ,
        .SPI_MISO(SPI_MISO)        
    );

    initial begin
        clk=0;
        rstn=0;
        flashAddrNametable=24'h550082;
        flashAddrAttribute=flashAddrNametable+240;//
        flashReadNametableFlag=0;
        flashReadAttributeFlag=0;

        nametableRamAddrStart=220;
        attributeRamAddrStart=245;
        SPI_MISO=0;
        #100
        rstn=1;
        #100
        flashReadNametableFlag=1;
        flashReadAttributeFlag=1;
        #10
        flashReadNametableFlag=0;
        flashReadAttributeFlag=0;
        #10000
        SPI_MISO=1;
    end
    always #1 clk=~clk;

endmodule