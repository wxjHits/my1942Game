/*
    背景的绘制，单纯对名称表进行索引，并找到对应的tile
*/
`include "C:/Users/hp/Desktop/my1942Game/RTL/src/game/PPU/define.v"
module backTileDraw(
    input   wire                            clk                 ,
    input   wire                            rstn                ,
    //from VGA_driver
    input   wire    [`VGA_POSXY_BIT-1:0]    vgaPosX             ,
    input   wire    [`VGA_POSXY_BIT-1:0]    vgaPosY             ,
    //from scrollCtrl.v
    input   wire    [8:0]                   scrollPtrOut        ,
    //当前VGA坐标对应的名称表位置
    output  reg     [9-1:0]                 nameTableRamIndex   , //0~32*30/4=240
    input   wire    [4*(`BYTE)-1:0]         nameTableRamDataO   ,
    //当前VGA坐标对应的属性表位置
    output  wire    [9-1:0]                 attributeAddr       , //0~32*30/4=240
    input   wire    [4*(`BYTE)-1:0]         attributeTableDataO ,
    //索引背景的图案表
    output  reg     [`BYTE-1:0]             backTileIndex       ,
    input   wire    [128-1:0]               backTileDataI       ,
    //to VGA_driver.v
    output  reg     [`RGB_BIT-1:0]          backGroundVgaRgbOut 
);

/*****将25.2MHz的数据同步到当前快时钟域下*****/
reg [`VGA_POSXY_BIT-1:0] vgaPosX_r;
reg [`VGA_POSXY_BIT-1:0] vgaPosY_r;
always@(posedge clk)begin //2023.02.22添加，优化了一下时序，显示效果好了许多
    if(~rstn)begin
        vgaPosX_r<=0;
        vgaPosY_r<=0;
    end
    else begin
        vgaPosX_r<=vgaPosX;
        vgaPosY_r<=vgaPosY;
    end
end

reg [`VGA_POSXY_BIT-1:0] gameVgaPosX;
reg [`VGA_POSXY_BIT-1:0] gameVgaPosY;
always@(posedge clk)begin
    if(~rstn)begin
        gameVgaPosX<=0;
        gameVgaPosY<=0;
    end
    else begin
        gameVgaPosX<=vgaPosX_r-`GAME_START_POSX;
        gameVgaPosY<=vgaPosY_r-`GAME_START_POSY;
    end
end

/*****nameTable扫描*****/
wire [8:0] gameVgaPosY_temp = gameVgaPosY+scrollPtrOut;
always@(posedge clk)begin
    if(scrollPtrOut>=0&&scrollPtrOut<=239)begin
        if(gameVgaPosY_temp<=9'd239)
            nameTableRamIndex<={gameVgaPosY_temp[8:3]+2'b00,gameVgaPosX[7:5]};
        else
            nameTableRamIndex<={gameVgaPosY_temp[8:3]+2'b10,gameVgaPosX[7:5]};//+16
    end
    else if(scrollPtrOut>=256&&scrollPtrOut<=495)begin
        if(gameVgaPosY_temp<=9'd495)
            nameTableRamIndex<={gameVgaPosY_temp[8:3]+2'b00,gameVgaPosX[7:5]};
        else
            nameTableRamIndex<={gameVgaPosY_temp[8:3]+2'b10,gameVgaPosX[7:5]};
    end
end

always@(*)begin
    case(gameVgaPosX[4:3])
        2'b00:backTileIndex=nameTableRamDataO[31:24];
        2'b01:backTileIndex=nameTableRamDataO[23:16];
        2'b10:backTileIndex=nameTableRamDataO[15:08];
        2'b11:backTileIndex=nameTableRamDataO[07:00];
    endcase
end

reg [$clog2(`SPRITE_TILEDATA_BIT)-1:0] whichBit;
always@(posedge clk)begin
    whichBit <={1'b0,gameVgaPosY_temp[2:0],gameVgaPosX[2:0]}; 
end

//č˛ĺ˝Š
wire  [`RGB_BIT-1:0] PaletteColor00;
wire  [`RGB_BIT-1:0] PaletteColor01;
wire  [`RGB_BIT-1:0] PaletteColor10;
wire  [`RGB_BIT-1:0] PaletteColor11;

//该点的2-bit的组合情况
wire [1:0] twoBitsFlag={backTileDataI[63-whichBit],backTileDataI[127-whichBit]};

always@(*)begin
    case(twoBitsFlag)
        2'b00:backGroundVgaRgbOut=PaletteColor00;
        2'b01:backGroundVgaRgbOut=PaletteColor01;
        2'b10:backGroundVgaRgbOut=PaletteColor10;
        2'b11:backGroundVgaRgbOut=PaletteColor11;
        default:backGroundVgaRgbOut=0;
    endcase
end

/*****调色板的选择（根据属性表的解析结果）*****/
reg [8:0] attributeAddr_r;
assign attributeAddr = attributeAddr_r;
always@(*)begin
    if(nameTableRamIndex[8]==1'b0)
        attributeAddr_r =  {nameTableRamIndex[7:5],gameVgaPosX[7]} + 9'd240;
    else
        attributeAddr_r =  {nameTableRamIndex[7:5],gameVgaPosX[7]} + 9'd496;
end

reg [7:0] attibuteByte;
always@(*)begin
    case(gameVgaPosX[6:5])
        2'b00:attibuteByte = attributeTableDataO[31:24];
        2'b01:attibuteByte = attributeTableDataO[23:16];
        2'b10:attibuteByte = attributeTableDataO[15:08];
        2'b11:attibuteByte = attributeTableDataO[07:00];
    endcase
end 

reg [1:0] paletteSelect;
always@(*)begin
    case({nameTableRamIndex[4],gameVgaPosX[4]})
        2'b00:paletteSelect=attibuteByte[1:0];
        2'b01:paletteSelect=attibuteByte[3:2];
        2'b10:paletteSelect=attibuteByte[5:4];
        2'b11:paletteSelect=attibuteByte[7:6];
    endcase
end

paletteBackground paletteBackground_inst (
    .PaletteChoice(paletteSelect),
    .PaletteColor00(PaletteColor00),
    .PaletteColor01(PaletteColor01),
    .PaletteColor10(PaletteColor10),
    .PaletteColor11(PaletteColor11)
);

endmodule
