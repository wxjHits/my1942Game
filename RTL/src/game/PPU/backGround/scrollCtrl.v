 module scrollCtrl(
    //clk & rstn
    input   wire            clk     ,
    input   wire            rstn    ,

    //CPU AHB-Lite
    input   wire            scrollEn        ,//背景滚动使能
    input   wire    [07:0]  scrollCntMax    ,//背景滚动的速度控制
    input   wire    [23:0]  flashAddrStart  ,//关卡数据从flash的什么地址开始
    input   wire    [07:0]  mapBackgroundMax,//地图在当前关卡一共有几幅图
    output  reg     [07:0]  mapBackgroundCnt,//当前开始扫描第几幅图片
    output  wire    [07:0]  mapScrollPtr    ,//名称表的滚动指针的低8bit
    output  reg             scrollingFlag   ,//表明背景正在滚动中
    //to nameTableRam.v
    output  wire    [03:0]  writeNameEn     ,
    output  wire    [08:0]  writeNameAddr   ,
    output  wire    [31:0]  writeNameData   ,
    output  wire    [03:0]  writeAttrEn     ,
    output  wire    [08:0]  writeAttrAddr   ,
    output  wire    [31:0]  writeAttrData   ,
    //SPI
    output  wire            SPI_CLK         ,
    output  wire            SPI_CS          ,
    output  wire            SPI_MOSI        ,
    input   wire            SPI_MISO        ,
    //vga帧率中断
    input   wire            vgaIntr         ,
    //to backTileDraw.v
    output wire [8:0]   scrollPtrOut
);

// /*****寄存器定义*****/
// reg         scrollEn        ;//背景滚动使能
// reg [07:0]  scrollCntMax    ;
reg [08:0]  scrollPtr       ;//名称表的滚动指针
reg [08:0]  scrollPtr_delay       ;//名称表的滚动指针

// reg [23:0]  flashAddrStart  ;//关卡数据从flash的什么地址开始
// reg [07:0]  mapBackgroundMax;//地图在当前关卡一共有几幅图
// reg [07:0]  mapBackgroundCnt;//当前开始扫描第几幅图片

// reg         scrollingFlag   ;//表明背景正在滚动中

/*****AHB-Lite对上述寄存器的读写*****/

/*****scrollingFlag的赋值*****/
always@(*)begin
    if(scrollEn==1'b1)begin
        if(mapBackgroundCnt<=mapBackgroundMax)
            scrollingFlag=1;
        else
            scrollingFlag=0;
    end
    else
        scrollingFlag=0;
end
/*****scrollPtr滚动指针的控制*****/
    //vgaIntr的上升沿检测
    wire vgaIntrPluse;
    reg vgaIntr0;
    reg vgaIntr1;
    always@(posedge clk)begin
        if(~scrollEn)begin
            vgaIntr0<=0;
            vgaIntr1<=0;
        end
        else begin
            vgaIntr0<=vgaIntr;
            vgaIntr1<=vgaIntr0;
        end
    end
    assign vgaIntrPluse = vgaIntr0 & (~vgaIntr1);
    //滚动速度控制
    reg [7:0] cnt;
    always@(posedge clk)begin
        if(~scrollEn)
            cnt<=0;
        else if(~scrollingFlag)
            cnt<=cnt;
        else begin
            if(vgaIntrPluse==1'b1)begin
                if(cnt>=scrollCntMax)
                    cnt<=0;
                else
                    cnt<=cnt+1'b1;
            end
            else
                cnt<=cnt;
        end
    end
    //scrollPtr计数器,名称表的指针0~239 & 256~495
    always@(posedge clk)begin
        if(~scrollEn)begin
            scrollPtr<=0;
            scrollPtr_delay<=0;
        end
        else begin
            if(vgaIntrPluse==1'b1 && cnt==scrollCntMax)begin
                if(scrollPtr==9'd256)//256
                    scrollPtr<=9'd239;
                else if(scrollPtr==9'd0)
                    scrollPtr<=9'd495;
                else
                    scrollPtr<=scrollPtr-1'b1;
                scrollPtr_delay<=scrollPtr;
            end
            else begin
                scrollPtr<=scrollPtr;
                scrollPtr_delay<=scrollPtr_delay;
            end
        end
    end
/*****mapBackgroundCnt关卡的计数器*****/
    //
    always@(posedge clk)begin
        if(~scrollEn)
            mapBackgroundCnt<=0;
        else begin
            if(vgaIntrPluse==1'b1 && cnt==scrollCntMax)begin
                if(scrollPtr==9'd256||scrollPtr==9'd0)
                    mapBackgroundCnt<=mapBackgroundCnt+1'b1;
                else
                    mapBackgroundCnt<=mapBackgroundCnt;
            end
            else
                mapBackgroundCnt<=mapBackgroundCnt;
        end
    end

/*****从flash读出数据传给nameTableRam*****/
    wire [23:0] flashAddrNametable;
    wire [23:0] flashAddrAttribute;
    reg [23:0] flashAddrNametable_r;
    reg [23:0] flashAddrAttribute_r;
    assign flashAddrNametable = flashAddrNametable_r;
    assign flashAddrAttribute = flashAddrAttribute_r;
    always@(*)begin
        if(~scrollEn)begin
            flashAddrNametable_r=0;
            flashAddrAttribute_r=0;
        end
        else begin
            flashAddrNametable_r = flashAddrStart+(mapBackgroundCnt<<10)+(scrollPtr[7:3]<<5);//需要从该地址连续读出32个数据，然后写进名称表中
            flashAddrAttribute_r = flashAddrStart+(mapBackgroundCnt<<10)+24'd960+(scrollPtr[7:5]<<3);//需要从该地址连续读出08个数据，然后写进属性表中
        end
    end
    //触发读flash的状态机
    wire flashReadNametableFlag;//从flash读取名称表的Flag信号
    wire flashReadAttributeFlag;//从flash读取属性表的Flag信号
    assign flashReadNametableFlag = (scrollPtr[2:0]==3'b111);
    assign flashReadAttributeFlag = (scrollPtr[4:0]==5'b11111||scrollPtr==9'd495||scrollPtr==9'd239);
    //写nameTableRam对应的nametable & attribute地址
    wire [08:0] nametableRamAddrStart = {scrollPtr[8:3],3'b000};
    wire [08:0] attributeRamAddrStart = {scrollPtr[8],8'b00000000}+9'd240+(scrollPtr[7:5]<<1);
    flashToNametable u_flashToNametable(
        //clk & rstn
        .clk                    (clk                    ),
        .rstn                   (rstn                   ),
        //scrollCtrl
        .flashAddrNametable     (flashAddrNametable     ),
        .flashAddrAttribute     (flashAddrAttribute     ),
        .flashReadNametableFlag (flashReadNametableFlag ),
        .flashReadAttributeFlag (flashReadAttributeFlag ),
        .nametableRamAddrStart  (nametableRamAddrStart  ),
        .attributeRamAddrStart  (attributeRamAddrStart  ),
        //nameTableRam.v
        .writeNameEn            (writeNameEn            ),
        .writeNameAddr          (writeNameAddr          ),
        .writeNameData          (writeNameData          ),
        .writeAttrEn            (writeAttrEn            ),
        .writeAttrAddr          (writeAttrAddr          ),
        .writeAttrData          (writeAttrData          ),
        //SPI
        .SPI_CLK                (SPI_CLK                ) ,
        .SPI_CS                 (SPI_CS                 ) ,
        .SPI_MOSI               (SPI_MOSI               ) ,
        .SPI_MISO               (SPI_MISO               ) 
    );

/*****模块输出信号幅值*****/
assign scrollPtrOut = scrollPtr_delay;
assign mapScrollPtr = scrollPtr[7:0];

endmodule