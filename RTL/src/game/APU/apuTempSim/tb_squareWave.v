`timescale 1ps/1ps

module tb_squareWave();

  reg           cpu_clk     ;
  reg           clk_240Hz   ;
  reg           rstn        ; 

  reg           enableIntr  ;//是否允许中断？
  reg           stepSel     ;//0：4步模式 1：5步模式

  reg [8-1:0]   byte0       ;
  reg [8-1:0]   byte1       ;
  reg [8-1:0]   byte2       ;
  reg [8-1:0]   byte3       ;

  wire          outVolume   ;//输出的音量值

squareWave u_squareWave (
    .cpu_clk   (cpu_clk   ),
    .clk_240Hz (clk_240Hz ),
    .rstn      (rstn      ),
    .enableIntr(0         ),
    .stepSel   (0         ),
    .byte0     (byte0     ),//01 0 0 1111
    .byte1     (byte1     ),//0_011           1_000_0_110
    .byte2     (byte2     ),//1000_1000
    .byte3     (byte3     ),//00100_000
    .outVolume (outVolume ) 
);

initial begin
    cpu_clk=0;
    clk_240Hz=0;
    rstn=0;
    byte0=8'b01001111;
    // byte1=8'b0; 
    byte1=8'b1011_0110;
    byte2=8'b1000_1000;
    byte3=8'b0010_0000;
    #100
    rstn=1;
end
always #1  cpu_clk=~cpu_clk;
always #100 clk_240Hz=~clk_240Hz;
endmodule