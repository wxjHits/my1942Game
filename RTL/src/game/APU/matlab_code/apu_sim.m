clc;                    %�������������
clear all;              %�������������,�ͷ��ڴ�ռ�

%fn          = 261 ;
fn          = 880 ;
Fs          = 44100 ;%������
T           = 0.1 ;%����ʱ��
t           = 0:1/Fs:T-1/Fs ;

y1=square(2*pi*261*t,25);%����
y2=square(2*pi*349*t,25);%����

%y2=sawtooth(2*pi*2000*t,0.5);%���ǲ�
y3=randn(1,T*Fs);%������
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
