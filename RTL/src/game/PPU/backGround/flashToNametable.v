module flashToNametable(
    //clk & rstn
    input               clk                     ,   //时钟
    input               rstn                    ,   //复位信号
    //scrollCtrl
    input   wire [23:0] flashAddrNametable      ,
    input   wire [23:0] flashAddrAttribute      ,
    input   wire        flashReadNametableFlag  ,
    input   wire        flashReadAttributeFlag  ,
    input   wire [08:0] nametableRamAddrStart   ,
    input   wire [08:0] attributeRamAddrStart   ,
    //nameTableRam.v
    output  wire [03:0] writeNameEn             ,
    output  wire [08:0] writeNameAddr           ,
    output  wire [31:0] writeNameData           ,
    output  wire [03:0] writeAttrEn             ,
    output  wire [08:0] writeAttrAddr           ,
    output  wire [31:0] writeAttrData           ,
    //SPI
    output  wire        SPI_CLK                 ,
    output  wire        SPI_CS                  ,
    output  wire        SPI_MOSI                ,
    input   wire        SPI_MISO                
);

    //用户信号
    reg            scroll_spi_cs      ;   //片选信号
    reg            scroll_spi_tx_req  ;   //发送请求信号
    reg    [7: 0]  scroll_spi_data_tx ;   //待发送的数据
    wire   [7: 0]  scroll_spi_data_rx ;   //接受到的数据
    wire           scroll_spi_ready   ;   //SPI一次发送完成信号

/*****scroll_spi_ready的上升沿检测*****/
    reg            scroll_spi_ready_r0;
    reg            scroll_spi_ready_r1;
    wire           scroll_spi_ready_pluse;
    assign         scroll_spi_ready_pluse = scroll_spi_ready_r0 & (~scroll_spi_ready_r1);
    always@(posedge clk)begin
        if(~rstn)begin
            scroll_spi_ready_r0<=0;
            scroll_spi_ready_r1<=0;
        end
        else begin
            scroll_spi_ready_r0<=scroll_spi_ready;
            scroll_spi_ready_r1<=scroll_spi_ready_r0;
        end
    end

    reg [03:0]  writeNametableEn   ;
    reg [08:0]  writeNametableAddr ; 
    reg [31:0]  writeNametableData ;
    reg [03:0]  writeAttributeEn   ;
    reg [08:0]  writeAttributeAddr ; 
    reg [31:0]  writeAttributeData ;

/*****状态机*****/
    localparam IDLE                 =4'h0 ;//
    localparam NAME_SEND_READ_CMD   =4'h1 ;//发送读命令W25X_ReadData 0x03
    localparam NAME_SEND_ADDR_H     =4'h2 ;//ADDR[23:16]
    localparam NAME_SEND_ADDR_M     =4'h3 ;//ADDR[15:08]
    localparam NAME_SEND_ADDR_L     =4'h4 ;//ADDR[07:00]
    localparam NAME_READ_DATA       =4'h5 ;//
    localparam SET_CS_H             =4'h6 ;//完成NAMETABLE的读取
    localparam ATTR_SEND_READ_CMD   =4'h7 ;//发送读命令W25X_ReadData 0x03
    localparam ATTR_SEND_ADDR_H     =4'h8 ;//ADDR[23:16]
    localparam ATTR_SEND_ADDR_M     =4'h9 ;//ADDR[15:08]
    localparam ATTR_SEND_ADDR_L     =4'hA ;//ADDR[07:00]
    localparam ATTR_READ_DATA       =4'hB;//
    reg [3:0]   nowState;
    reg         attributeFlag;
    reg [7:0]  readDataCnt ;//读取数据计数
    //检测上升沿
    reg flashReadNametableFlag_trig ;
    reg flashReadAttributeFlag_trig ;
    reg flashReadNametableFlag_r0   ;
    reg flashReadAttributeFlag_r0   ;
    reg flashReadNametableFlag_r1   ;
    reg flashReadAttributeFlag_r1   ;
    always@(posedge clk)begin
        if(~rstn)begin
            flashReadNametableFlag_r0   <=0;
            flashReadNametableFlag_r1   <=0;
            flashReadNametableFlag_trig <=0;
            flashReadAttributeFlag_r0   <=0;
            flashReadAttributeFlag_r1   <=0;
            flashReadAttributeFlag_trig <=0;
        end
        else begin
            flashReadNametableFlag_r0   <=flashReadNametableFlag;
            flashReadNametableFlag_r1   <=flashReadNametableFlag_r0;
            flashReadNametableFlag_trig <=flashReadNametableFlag_r0&(~flashReadNametableFlag_r1);
            flashReadAttributeFlag_r0   <=flashReadAttributeFlag;
            flashReadAttributeFlag_r1   <=flashReadAttributeFlag_r0;
            flashReadAttributeFlag_trig <=flashReadAttributeFlag_r0&(~flashReadAttributeFlag_r1);
        end
    end

    always@(posedge clk)begin
        if(~rstn)begin
            nowState<=IDLE;
            scroll_spi_cs     <=1'b1;
            scroll_spi_tx_req <=1'b0;
            scroll_spi_data_tx<=8'b0;
            readDataCnt<=0;
        end
        else begin
            case(nowState)
                IDLE:begin
                    if(flashReadNametableFlag_trig==1'b1)begin
                        nowState<=NAME_SEND_READ_CMD;
                        scroll_spi_cs<=1'b0;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=8'h03;
                        if(flashReadAttributeFlag_trig==1'b1)
                            attributeFlag<=1'b1;
                        else
                            attributeFlag<=1'b0;
                    end
                end
                NAME_SEND_READ_CMD:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=NAME_SEND_ADDR_H;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrNametable[23:16];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                NAME_SEND_ADDR_H:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=NAME_SEND_ADDR_M;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrNametable[15:08];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                NAME_SEND_ADDR_M:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=NAME_SEND_ADDR_L;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrNametable[07:00];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                NAME_SEND_ADDR_L:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=NAME_READ_DATA;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=8'hff;
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                NAME_READ_DATA:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        if(readDataCnt>=31)begin
                            nowState<=SET_CS_H;
                            scroll_spi_cs<=1;
                            readDataCnt<=0;
                        end
                        else begin
                            nowState<=NAME_READ_DATA;
                            scroll_spi_tx_req<=1'b1;
                            scroll_spi_data_tx<=8'hff;
                            readDataCnt<=readDataCnt+1'b1;
                        end
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                SET_CS_H:begin
                    if(attributeFlag==1'b0)
                        nowState<=IDLE;
                    else begin
                        nowState<=ATTR_SEND_READ_CMD;
                        scroll_spi_cs<=0;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=8'h03;
                    end
                end
                ATTR_SEND_READ_CMD:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=ATTR_SEND_ADDR_H;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrAttribute[23:16];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                ATTR_SEND_ADDR_H:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=ATTR_SEND_ADDR_M;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrAttribute[15:08];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                ATTR_SEND_ADDR_M:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=ATTR_SEND_ADDR_L;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=flashAddrAttribute[07:00];
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                ATTR_SEND_ADDR_L:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        nowState<=ATTR_READ_DATA;
                        scroll_spi_tx_req<=1'b1;
                        scroll_spi_data_tx<=8'hff;
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                ATTR_READ_DATA:begin
                    if(scroll_spi_ready_pluse==1'b1)begin
                        if(readDataCnt>=7)begin
                            nowState<=IDLE;
                            scroll_spi_cs<=1;
                            readDataCnt<=0;
                        end
                        else begin
                            nowState<=ATTR_READ_DATA;
                            scroll_spi_tx_req<=1'b1;
                            scroll_spi_data_tx<=8'hff;
                            readDataCnt<=readDataCnt+1'b1;
                        end
                    end
                    else
                        scroll_spi_tx_req<=1'b0;
                end
                default:;
            endcase
        end
    end
//spi的例化
spi scroll_spi(
    .clk        (clk        ),  //系统时钟
    .rstn       (rstn       ),  //系统复位型号
    .clk_div    (8'd20     ),//时钟分频 4~255
    .cs         (scroll_spi_cs     ),
    .tx_req     (scroll_spi_tx_req ),
    .data_tx    (scroll_spi_data_tx),
    .data_rx    (scroll_spi_data_rx),
    .spi_ready  (scroll_spi_ready  ),
    //SPI
    .SPI_CLK    (SPI_CLK    ),
    .SPI_CS     (SPI_CS     ),
    .SPI_MOSI   (SPI_MOSI   ),
    .SPI_MISO   (SPI_MISO   )
);

//读出数据到nameTable & attribute
always@(*)begin
    if(nowState==NAME_READ_DATA)begin
        // writeNametableEn = scroll_spi_ready_pluse & (readDataCnt[1:0]==2'b11);
        if(scroll_spi_ready_pluse)begin
            case(readDataCnt[1:0])
                2'b00:begin writeNametableData[31:24]=scroll_spi_data_rx;writeNametableEn[0]=1'b1; end
                2'b01:begin writeNametableData[23:16]=scroll_spi_data_rx;writeNametableEn[1]=1'b1; end
                2'b10:begin writeNametableData[15:08]=scroll_spi_data_rx;writeNametableEn[2]=1'b1; end
                2'b11:begin writeNametableData[07:00]=scroll_spi_data_rx;writeNametableEn[3]=1'b1; end
            endcase
        end
        else begin
            writeNametableEn=0;
            writeNametableData=writeNametableData;
        end
    end
    else begin
        writeNametableEn=0;
        writeNametableData=0;
    end
end

always@(*)begin
    if(nowState==ATTR_READ_DATA)begin
        // writeAttributeEn = scroll_spi_ready_pluse & (readDataCnt[1:0]==2'b11);
        if(scroll_spi_ready_pluse)begin
            case(readDataCnt[1:0])
                2'b00:begin writeAttributeData[31:24]=scroll_spi_data_rx;writeAttributeEn[0]=1'b1; end
                2'b01:begin writeAttributeData[23:16]=scroll_spi_data_rx;writeAttributeEn[1]=1'b1; end
                2'b10:begin writeAttributeData[15:08]=scroll_spi_data_rx;writeAttributeEn[2]=1'b1; end
                2'b11:begin writeAttributeData[07:00]=scroll_spi_data_rx;writeAttributeEn[3]=1'b1; end
            endcase
        end
        else begin
            writeAttributeEn=0;
            writeAttributeData=writeAttributeData;
        end
    end
    else begin
        writeAttributeEn=0;
        writeAttributeData=0;
    end
end
always@(posedge clk)begin
    if(~rstn)begin
        writeAttributeAddr<=0;
        writeNametableAddr<=0;
    end
    else begin
        if(nowState==IDLE)begin
            if(flashReadNametableFlag_trig==1'b1)
                writeNametableAddr<=nametableRamAddrStart;
            if(flashReadAttributeFlag_trig==1'b1)
                writeAttributeAddr<=attributeRamAddrStart;
        end
        else if(nowState==NAME_READ_DATA)begin
            if(writeNametableEn[3]==1'b1)
                writeNametableAddr<=writeNametableAddr+1'b1;
            else
                writeNametableAddr<=writeNametableAddr;
        end
        else if(nowState==ATTR_READ_DATA)begin
            if(writeAttributeEn[3]==1'b1)
                writeAttributeAddr<=writeAttributeAddr+1'b1;
            else
                writeAttributeAddr<=writeAttributeAddr;
        end
    end
end
//输出信号赋值
assign writeNameEn   = writeNametableEn   ;
assign writeNameAddr = writeNametableAddr ;
assign writeNameData = writeNametableData ;
assign writeAttrEn   = writeAttributeEn   ;
assign writeAttrAddr = writeAttributeAddr ;
assign writeAttrData = writeAttributeData ;

endmodule