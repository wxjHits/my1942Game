/*
    节拍也就是表示时长
    然后我们完成节拍译码和节拍计数模块，
    我们设定一个全音的长度，从而定下全音的分频频率，
    其他二分音符、四分音符分频频率只需要在全音的频率上倍除即可。
    我们用1位16进制数表示音节的长度，4'h1表示全音，4'h2表示二分音符以此类推
*/
module beat_decoder(
    input [3:0] beat,
    output reg [27:0] beat_cnt_parameter
);
    
localparam tune_pwm_parameter_4 = 27'h4C4B400;//全音�? 四拍
localparam tune_pwm_parameter_2 = 27'h2625A00;//二分音符 二拍
localparam tune_pwm_parameter_1 = 27'h1312D00;//四分音符 �?�?
localparam tune_pwm_parameter_1_2 = 27'h989680;//八分音符 半拍
localparam tune_pwm_parameter_1_4 = 27'h4C4B40;//十六分音�? 四分之一�?
localparam tune_pwm_parameter_1_8 = 27'h2625A0;//三十二分音符 八分之一�?
always @(beat) begin
    case (beat)
        4'h1: beat_cnt_parameter = tune_pwm_parameter_4;
        4'h2: beat_cnt_parameter = tune_pwm_parameter_2;
        4'h3: beat_cnt_parameter = tune_pwm_parameter_1;
        4'h4: beat_cnt_parameter = tune_pwm_parameter_1_2;
        4'h5: beat_cnt_parameter = tune_pwm_parameter_1_4;
        4'h6: beat_cnt_parameter = tune_pwm_parameter_1_8;
        default:beat_cnt_parameter = 27'd0; 
    endcase 
end
endmodule