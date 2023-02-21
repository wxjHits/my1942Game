/*
对于音调译码模块，我们用2位16进制数表示音调，
高位表示音的高低，如1表示低音，2表中音，3表示高音；
低位表示具体的音调，如1是do，2是ri等等。
8'h11就表示低音do。
通过查找音乐专业知识，使每一种音调下tune_pwm_parameter取相应的常数，
使得时钟分频后得到相应音调的频率。
*/
module tune_decoder(
    input        [7 :0]  tune,
    output  reg  [19:0]  tune_pwmParameter
);
localparam tune_pwm_parameter_do = 20'h2EA9B;//do 261.6hz
localparam tune_pwm_parameter_ri = 20'h29902;//ri 293.7hz
localparam tune_pwm_parameter_mi = 20'h25093;//mi 329.6hz
localparam tune_pwm_parameter_fa = 20'h22F50;//fa 349.2hz
localparam tune_pwm_parameter_so = 20'h1F23F;//so 392hz
localparam tune_pwm_parameter_la = 20'h1BBE4;//la 440hz
localparam tune_pwm_parameter_xi = 20'h18B73;//xi 493.9hz
localparam tune_pwm_parameter_Do = 20'h1753B;//中音do 523.3hz
localparam tune_pwm_parameter_Ri = 20'h14C8F;//中音ri 587.3hz
localparam tune_pwm_parameter_Mi = 20'h1283E;//中音mi 659.3hz
localparam tune_pwm_parameter_Fa = 20'h11B44;//中音fa 698.5hz
localparam tune_pwm_parameter_So = 20'hF920; //中音so 784hz
localparam tune_pwm_parameter_La = 20'hDDF2; //中音la 880hz
localparam tune_pwm_parameter_Xi = 20'hC5BA; //中音xi 987.8hz
localparam tune_pwm_parameter_DO = 20'hBAA2; //高音do 1046.5hz
localparam tune_pwm_parameter_RI = 20'hA644; //高音ri 1174.7hz
localparam tune_pwm_parameter_MI = 20'h9422; //高音mi 1318.5hz
localparam tune_pwm_parameter_FA = 20'h8BD2; //高音fa 1396.9hz
localparam tune_pwm_parameter_SO = 20'h7C90; //高音so 1568hz
localparam tune_pwm_parameter_LA = 20'h6EF9; //高音la 1760hz
localparam tune_pwm_parameter_XI = 20'h62DE; //高音xi 1975.5hz
always @(tune) begin
    case (tune)
        8'h11: tune_pwmParameter = tune_pwm_parameter_do;
        8'h12: tune_pwmParameter = tune_pwm_parameter_ri;
        8'h13: tune_pwmParameter = tune_pwm_parameter_mi;
        8'h14: tune_pwmParameter = tune_pwm_parameter_fa;
        8'h15: tune_pwmParameter = tune_pwm_parameter_so;
        8'h16: tune_pwmParameter = tune_pwm_parameter_la;
        8'h17: tune_pwmParameter = tune_pwm_parameter_xi;
        8'h21: tune_pwmParameter = tune_pwm_parameter_Do;
        8'h22: tune_pwmParameter = tune_pwm_parameter_Ri;
        8'h23: tune_pwmParameter = tune_pwm_parameter_Mi;
        8'h24: tune_pwmParameter = tune_pwm_parameter_Fa;
        8'h25: tune_pwmParameter = tune_pwm_parameter_So;
        8'h26: tune_pwmParameter = tune_pwm_parameter_La;
        8'h27: tune_pwmParameter = tune_pwm_parameter_Xi;       
        8'h31: tune_pwmParameter = tune_pwm_parameter_DO;
        8'h32: tune_pwmParameter = tune_pwm_parameter_RI;
        8'h33: tune_pwmParameter = tune_pwm_parameter_MI;
        8'h34: tune_pwmParameter = tune_pwm_parameter_FA;
        8'h35: tune_pwmParameter = tune_pwm_parameter_SO;
        8'h36: tune_pwmParameter = tune_pwm_parameter_LA;
        8'h37: tune_pwmParameter = tune_pwm_parameter_XI;
        default:tune_pwmParameter = 20'd0; 
    endcase 
end
endmodule