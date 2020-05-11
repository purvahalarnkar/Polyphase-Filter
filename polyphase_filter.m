clc
clear all
close all

[x,Fs]=audioread('ExcerptChopin.wav');
x=x(:,1); %select a single channel
f=Fs/length(x);
af=0:f:(length(x)*f)-f;
figure(1)
semilogx(af, 20*log10(abs(fft(x))))
grid on
axis([10e0 10e4 -100 100])
title('Original Single Channel Spectrum')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')

%Upsampling
L=3; M=3;
yu=upsample(x,L);
Fs1=Fs*L; 
f1=Fs1/length(yu);
af1=0:f1:(length(yu)*f1)-f1;

%LPF after upsampling
N   = 120;
Fp  = 20000;
Ap  = 0.01;
Ast = 80;
Rp  = (10^(Ap/20) - 1)/(10^(Ap/20) + 1);
Rst = 10^(-Ast/20);
lp = firceqrip(N,Fp/(Fs/2),[Rp Rst],'passedge');

lp1=filter(lp,1,yu);

%polynomial tf
p=polyval([0 1 0 0.5],lp1);

lp2=filter(lp,1,p);
figure(2)
semilogx(af1, 20*log10(abs(fft(lp2))),'r')
axis([10e0 10e7 -100 100])
grid on
title('Interpolated output')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')

%downsampling
yd=downsample(lp2,M);

%polyphase implementation
H=mfilt.firinterp(L);
y=filter(H,x);
figure(3)
semilogx(af1, 20*log10(abs(fft(y))),'b')
axis([10e0 10e4 -100 100])
grid on
title('Polyphase filter output')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')