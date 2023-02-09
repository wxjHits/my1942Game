/*
    APU的三角波音频处理
    byte0:
        [7]是否持续播放
        [6:0]线性计数器的初始值,在0~该值之间计数,用于幅值的控制
    byte1:
        [7:0]null
    byte2:
        [7:0]分频数值的低8位
    byte3:
        [7:3]长度计数器的初始值
        [2:0]分频数值的高3位
    
    将采样周期sampleClk进行分频得到一个波形计数时钟divClk,
*/

`include "C:/Users/hp/Desktop/my_1942/define.v"
module triangularWave(
    input   wire                clk,
    input   wire                rstn,

    //
    input   wire                sampleClk,//音频采样clk
    input   wire                decodeEn,
    input   wire    [`BYTE-1:0] byte0,
    input   wire    [`BYTE-1:0] byte1,
    input   wire    [`BYTE-1:0] byte2,
    input   wire    [`BYTE-1:0] byte3
);
    reg             isContinueFlag;//是否持续播放 
    reg     [6:0]   lineCntInitNum;//线性计数器
    reg     [4:0]   longCntInitNum;//长度计数器初始值
    reg     [10:0]  divNumMax;//分频数值
    always@(*)begin
        isContinueFlag  = byte0[7];
        lineCntInitNum  = byte0[6:0];
        longCntInitNum  = byte3[7:3];
        divNumMax       = {byte3[2:0],byte2[7:0]};
    end

    //根据分频数值将采样时钟分频
    reg sampleClkDelay;
    reg sampleClkRaiseEdge;
    reg             divClk;
    reg     [10:0]  divNumCnt;      
    always@(posedge clk)begin
        if(~rstn)begin
            sampleClkDelay<=0;
            sampleClkRaiseEdge<=0;
        end
        else if(decodeEn)begin
            sampleClkDelay<=sampleClk;
            sampleClkRaiseEdge<=(~sampleClkDelay)&(sampleClk);
        end
    end
    always@(posedge clk)begin
        if(~rstn)
            divNumCnt<=0;
        else if(sampleClkRaiseEdge)begin
            if(divNumCnt<divNumMax>>1-1)
                divNumCnt<=divNumCnt+1'b1;
            else
                divNumCnt<=0;
        end
        else
            divNumCnt<=0;
    end
    always@(*)begin
        if(~rstn)
            divClk=0;
        else if(divNumCnt==divNumMax>>1-1)
            divClk=~divClk;
        else
            divClk=divClk;
    end

    //在分出来的时钟divClk下进行三角波波形生成
    always@(posedge divClk)begin

    end
    reg     [4:0]   longCnt;//


endmodule