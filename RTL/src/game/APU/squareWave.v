/*
    byte0:
        [7:6]占空比:12.5% 25% 50% 75%
        [5]是否持续播放
        [4]音量控制方式:固定音量或者包络控制
        [3:0]音量数值/包络时间
    byte1:
        [7]是否采用滑音
        [6:4]滑音的周期
        [3:0]滑音的分频改变值
    byte2:
        [7:0]分频数值的低8位置
    byte0:
        [7:3]长度计数器的初始值
        [2:0]分频数值的高3位
*/
`include "C:/Users/hp/Desktop/my_1942/define.v"
module squareWave (
    input   wire    [`BYTE-1:0] byte0,
    input   wire    [`BYTE-1:0] byte1,
    input   wire    [`BYTE-1:0] byte2,
    input   wire    [`BYTE-1:0] byte3
);
    
endmodule