//按键滤波，防止抖动
module  key_intr
#(
    parameter CNT_MAX = 20'd999_999 //计数器计数最大值
)(
    input   wire    clk         ,   //系统时钟50Mhz
    input   wire    rstn        ,   //全局复位
    input   wire    key_in      ,   //按键输入信号

    output  reg     key_intr        //按键产生的中断
);

reg     key_out ;
reg     [19:0]  cnt_20ms    ;   //计数器

//cnt_20ms:如果时钟的上升沿检测到外部按键输入的值为低电平时，计数器开始计数
always@(posedge clk     or negedge rstn     )
    if(rstn      == 1'b0)
        cnt_20ms <= 20'b0;
    else    if(key_in == 1'b1)
        cnt_20ms <= 20'b0;
    else    if(cnt_20ms == CNT_MAX && key_in == 1'b0)
        cnt_20ms <= cnt_20ms;
    else
        cnt_20ms <= cnt_20ms + 1'b1;

//key_out:当计数满20ms后产生按键有效标志位
//且key_out在999_999时拉高,维持一个时钟的高电平
always@(posedge clk     or negedge rstn     )begin
    if(rstn      == 1'b0)
        key_out <= 1'b0;
    else if(cnt_20ms == CNT_MAX - 1'b1)
        key_out <= 1'b1;
    else
        key_out <= 1'b0;        
end

//生成中断信号
reg key_out_r0;
always@(posedge clk or negedge rstn)begin
    if(~rstn)begin
        key_out_r0<=0;
        key_intr<=0;
    end
    else begin
        key_out_r0<=key_out;
        key_intr<=key_out&(~key_out_r0);
    end
end

endmodule
