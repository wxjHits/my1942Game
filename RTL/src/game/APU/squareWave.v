/*
    byte0:
        [7:6]占空比:12.5% 25% 50% 75%
        [5]是否持续播放
        [4]音量控制方式:固定音量或者包络控制 0:固定 1：包络
        [3:0]音量数值/包络分频
    byte1:
        [7]是否采用滑音sweep
        [6:4]滑音的周期，sweep的分频计数
        [3:0]滑音的分频改变值：[3]滑音是否为负值，控制音乐频率的增大或减小，[2:0]用于音频增大或者减少的数值
    byte2:
        [7:0]分频数值的低8位置
    byte3:
        [7:3]长度计数器的初始值
        [2:0]分频数值的高3位
*/
`include "C:/Users/hp/Desktop/my_1942/define.v"
module squareWave (
    input   wire    cpu_clk,
    input   wire    clk_240Hz,
    input   wire    rstn, 

    input   wire    enableIntr,//是否允许中断？
    input   wire    stepSel,//0：4步模式 1：5步模式

    input   wire    [`BYTE-1:0] byte0,
    input   wire    [`BYTE-1:0] byte1,
    input   wire    [`BYTE-1:0] byte2,
    input   wire    [`BYTE-1:0] byte3,

    output  reg     [3:0] outVolume//输出的音量值
);
    //控制字的译码
    reg [1:0] DUTY;
    reg       ISLOOP;
    reg       ISCONSTANTVOLUME;
    reg [3:0] VOLUME_OR_ENEVLOPCLKDIV;

    reg       ISSWEEP;
    reg [2:0] SWEEPCLKDIV;
    reg       SWEEP_FREQUENCY_ADDORSUB;
    reg [2:0] SWEEP_FREQUENCY_CHANGEVALUE;

    reg [10:0] TIMERCLKDIV;
    reg [4:0] LENGTHCOUNTER_INIT_VALUE;

    reg sweep_clkDivClk;
    reg [11:0] sweep_frequency_delta;//滑音频率的增量SWEEP_FREQUENCY_CHANGEVALUE

    always @(*) begin
        DUTY=byte0[7:6];
        ISLOOP=byte0[5];
        ISCONSTANTVOLUME=byte0[4];
        VOLUME_OR_ENEVLOPCLKDIV=byte0[3:0];
        ISSWEEP=byte1[7];
        SWEEPCLKDIV=byte1[6:4];
        SWEEP_FREQUENCY_ADDORSUB=byte1[3];
        SWEEP_FREQUENCY_CHANGEVALUE=byte1[2:0];
        TIMERCLKDIV= (byte3[2:0]<<8)|byte2;
        LENGTHCOUNTER_INIT_VALUE=byte3[7:3];
    end

    //timer时钟TIMERCLKDIV
    reg sweep_clkDivClk_r0      ;
    reg sweep_clkDivClk_r1      ;
    reg sweep_clkDivClk_r2      ;
    reg sweep_clkDivClk_UpEdge  ;//sweep_clk分频后时钟上升沿同步到
    wire timer_clk;//用于输出声音的频率，也就是采样率
    reg [10:0] timer_nowDiv;

    //timer时钟分频
    reg [10:0] cpuClkDivCnt;
    always@(posedge cpu_clk)begin
        if(~rstn)
            cpuClkDivCnt<=0;
        else if(cpuClkDivCnt<(timer_nowDiv-1))
            cpuClkDivCnt<=cpuClkDivCnt+1'b1;
        else
            cpuClkDivCnt<=0;
    end

    assign timer_clk = (cpuClkDivCnt==(timer_nowDiv-1))?1'b1:1'b0;

    always@(posedge cpu_clk)begin
        if(~rstn)begin
            sweep_clkDivClk_r0    <=0;
            sweep_clkDivClk_r1    <=0;
            sweep_clkDivClk_r2    <=0;
            sweep_clkDivClk_UpEdge<=0;
        end
        else if(timer_clk)begin
            sweep_clkDivClk_r0    <=sweep_clkDivClk;
            sweep_clkDivClk_r1    <=sweep_clkDivClk_r0;
            sweep_clkDivClk_r2    <=sweep_clkDivClk_r1;
            sweep_clkDivClk_UpEdge<=sweep_clkDivClk_r1&(~sweep_clkDivClk_r2);
        end
    end

    always@(posedge cpu_clk)begin
        if(~rstn)
            timer_nowDiv<=TIMERCLKDIV;
        else if(ISSWEEP&sweep_clkDivClk_UpEdge)begin
            if(SWEEP_FREQUENCY_ADDORSUB==1'b1)//add
                timer_nowDiv<=timer_nowDiv+sweep_frequency_delta;
            else//sub
                timer_nowDiv<=timer_nowDiv-sweep_frequency_delta;
        end
        else
            timer_nowDiv<=timer_nowDiv;
    end

    //占空比的数值选择
    reg [7:0] duty_r;
    always@(*)begin
        case(DUTY)
            2'b00:duty_r<=8'b0000_0001;//占空比12.5%
            2'b01:duty_r<=8'b0000_0011;//占空比25.0%
            2'b10:duty_r<=8'b0000_1111;//占空比50.0%
            2'b11:duty_r<=8'b0011_1111;//占空比75.0%
        endcase
    end

/*************************240Hz时钟生成***************************/
//包络时钟envelop_clk、长度计数器时钟lengthCounter_clk和滑音时钟sweep_clk的生成
    //4步或者5步序列选择
    wire [2:0] clk_240Hz_DivCntMax = (stepSel==1'b0) ? 3'd4:3'd5;
    reg  [2:0] clk_240Hz_DivCnt;
    always@(posedge clk_240Hz or negedge rstn)begin
        if(~rstn)
            clk_240Hz_DivCnt<=0;
        else if(clk_240Hz_DivCnt<clk_240Hz_DivCntMax-1)
            clk_240Hz_DivCnt<=clk_240Hz_DivCnt+1'b1;
        else
            clk_240Hz_DivCnt<=0;
    end

    //当前只支持4步模式
    wire envelop_clk       = clk_240Hz;
    wire lengthCounter_clk = (clk_240Hz_DivCnt==3'd1||clk_240Hz_DivCnt==3'd3)?1'b1:1'b0;
    wire sweep_clk         = lengthCounter_clk;

/***************************包络音量产生通路***************************/
    //包络时钟envelop_clk分频 VOLUME_OR_ENEVLOPCLKDIV
    reg [3:0] envelop_clkDivCnt;
    always @(posedge envelop_clk or negedge rstn)begin
        if(~rstn)
            envelop_clkDivCnt<=0;
        else if(envelop_clkDivCnt<VOLUME_OR_ENEVLOPCLKDIV>>1-1)
            envelop_clkDivCnt<=envelop_clkDivCnt+1'b1;
        else
            envelop_clkDivCnt<=0;
    end
    //包络时钟分频后的时钟
    reg envelop_clkDivClk;
    always @(posedge envelop_clk or negedge rstn)begin
        if(~rstn)
            envelop_clkDivClk<=0;
        else if(envelop_clkDivCnt==(VOLUME_OR_ENEVLOPCLKDIV>>1-1))
            envelop_clkDivClk=~envelop_clkDivClk;
        else
            envelop_clkDivCnt<=envelop_clkDivClk;
    end

    //包络音量递减15->0
    reg [3:0] envelop_volumeValue;//包络音量值
    always@(posedge envelop_clkDivClk or negedge rstn)begin
        if(~rstn)
            envelop_volumeValue<=0;
        else if(ISLOOP==1'b1)begin//允许包络循环
            if(envelop_volumeValue==4'd0)
                envelop_volumeValue<=4'd15;
            else
                envelop_volumeValue<=envelop_volumeValue-1'b1;
        end
        else
            envelop_volumeValue<=envelop_volumeValue-1'b1;
    end

/***************************长度计数器计数通路***************************/
reg [7:0] lengthCounterMax;
always@(*)begin
    case(LENGTHCOUNTER_INIT_VALUE)
        5'd0:lengthCounterMax=10;
        5'd1:lengthCounterMax=20;
        5'd2:lengthCounterMax=30;
        5'd3:lengthCounterMax=40;
        5'd4:lengthCounterMax=50;
        default:lengthCounterMax=10;
    endcase
end
reg [7:0] lengthCounter;
always@(posedge lengthCounter_clk or negedge rstn)begin
    if(~rstn)
        lengthCounter<=0;
    else if(lengthCounter<lengthCounterMax-1)
        lengthCounter<=lengthCounter+1'b1;
    else
        lengthCounter<=0;
end

/***************************SWEEP滑音通路***************************/
//滑音时钟sweep_clk分频 SWEEPCLKDIV
reg [2:0] sweep_clkDivCnt;
always @(posedge sweep_clk or negedge rstn)begin
    if(~rstn)
        sweep_clkDivCnt<=0;
    else if(sweep_clkDivCnt<SWEEPCLKDIV-1)
        sweep_clkDivCnt<=sweep_clkDivCnt+1'b1;
    else
        sweep_clkDivCnt<=0;
end
//滑音时钟分频后的时钟
always @(posedge sweep_clk or negedge rstn)begin
    if(~rstn)
        sweep_clkDivClk<=0;
    else if(sweep_clkDivCnt==SWEEPCLKDIV-1)
        sweep_clkDivClk=1'b1;
    else
        sweep_clkDivClk<=1'b0;
end

always@(*)begin
    if(~rstn)
        sweep_frequency_delta=0;
    else if(ISSWEEP)//开启滑音
        sweep_frequency_delta=TIMERCLKDIV>>SWEEP_FREQUENCY_CHANGEVALUE;
    else
        sweep_frequency_delta=0;
end

/***************************音量的输出***************************/
wire [3:0] volume = ISCONSTANTVOLUME==1'b1 ? envelop_volumeValue:VOLUME_OR_ENEVLOPCLKDIV;

reg [2:0] volumeCnt;
always@(posedge timer_clk or negedge rstn)begin
    if(~rstn)begin
        volumeCnt<=0;
        outVolume<=0;
    end
    else begin
        volumeCnt<=volumeCnt+1'b1;
        if(duty_r[volumeCnt]==1'b1)
            outVolume<=volume;
        else
            outVolume<=0;
    end
end

endmodule