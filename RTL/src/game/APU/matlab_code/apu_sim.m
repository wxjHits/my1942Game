clc;                    %清除命令行命令
clear all;              %清除工作区变量,释放内存空间

%fn          = 261 ;
fn          = 880 ;
Fs          = 44100 ;%采样率
T           = 0.1 ;%采样时间
t           = 0:1/Fs:T-1/Fs ;

y1=square(2*pi*261*t,25);%方波
y2=square(2*pi*349*t,25);%方波

%y2=sawtooth(2*pi*2000*t,0.5);%三角波
y3=randn(1,T*Fs);%白噪声
%y=[mapminmax(y1,0,1),mapminmax(y2,0,1),mapminmax(y3,0,1)];
y=[mapminmax(y1,0,1),mapminmax(y2,0,1)];
%y=[mapminmax(y1+y3,0,1)];
figure(1)
subplot(311);
plot(t,mapminmax(y1,0,1));
subplot(312);
plot(t,mapminmax(y2,0,1));
subplot(313);
plot(t,mapminmax(y3,0,1));
for i=0:1:100
    sound(y,Fs);
end
