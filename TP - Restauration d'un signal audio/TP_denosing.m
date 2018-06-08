clear;
close all;
clc;

% il s'agit d'un signal avec un echo, ie déphaser
% et présence de deux autres fréquences porteuses
% [(s(n)+a*s(n-p))cos(2*pi*f1*Te)]*cos(2*pi*f2*Te)
% Z0=1*exp(j*2*pi*f/Fe)
% (1-Z0Z^-1)(1-Z0*Z^-1)=1-Z0*Z^(-1)-Z0Z^(-1)+1*Z^(-2)
% h0=1  h1=-(Z0+Z0*)   h2=1
% (1-P0Z^(-1))(1-P0*Z^(-1))(1-P1Z^(-1))(1-P1*Z^(-1))
% P0=0.8*exp(j*2*pi*(freq-d)/Fe)
% d=30
% fonction de transfert : H(Z)=1+aZ^(-p)

[signal,Fe]=audioread('11.wav');
L=length(signal);
Te=1/Fe;
t=0:Te:(L-1)*Te;
f=0:Fe/(L-1):Fe;

% spectre du signal
NFFT=pow2(nextpow2(L));
SFFT=fft(signal,NFFT);
spectrum=abs(SFFT);

% Recherche de la première fréquence porteuse
indexF1=find(spectrum==max(spectrum));
freq1=indexF1(1)*Fe/NFFT;

% Freq1 - Poles and zeros
Z0=1*exp(2*pi*1j*freq1/Fe);
Z0conj=conj(Z0);

numerateur=[Z0 Z0conj];
PolyNum=poly(numerateur);

d=30;
P0=0.8*exp(2*pi*1j*(freq1+d)/Fe);
P0conj=conj(P0);
P1=0.8*exp(2*pi*1j*(freq1-d)/Fe);
P1conj=conj(P1);

denominateur=[P0 P0conj P1 P1conj];
PolyDen=poly(denominateur);

newsignal=filter(PolyNum, PolyDen, signal);

% spectre du signal
NFFT=pow2(nextpow2(L));
SFFT=fft(newsignal,NFFT);
spectrum=abs(SFFT);

% Recherche de la deuxième fréquence porteuse
indexF2=find(spectrum==max(spectrum));
freq2=indexF2(1)*Fe/NFFT;

% Freq2 - Poles and zeros
Z0=1*exp(2*pi*1j*freq2/Fe);
Z0conj=conj(Z0);

numerateur=[Z0 Z0conj];
PolyNum=poly(numerateur);

d=30;
P0=0.8*exp(2*pi*1j*(freq2+d)/Fe);
P0conj=conj(P0);
P1=0.8*exp(2*pi*1j*(freq2-d)/Fe);
P1conj=conj(P1);

denominateur=[P0 P0conj P1 P1conj];
PolyDen=poly(denominateur);

newnewsignal=filter(PolyNum, PolyDen, newsignal);

% Cancel Echo
% rxx(0)=E[X(n)^2]=E[(S(n)+aS(n-r))^2]=E[S(n)^2+a^2*S(n-r)^2]
% rxx(0)=(1+a^2)E[S(n)^2]=(1+a^2)*Ps

% rxx(r)=E[X(n)X(n-r)]=E[(S(n)+a*S(n-r))(S(n-r)+a*S(n-2r))]
% rxx(r)=E[a*S(n-r)^2]=a*E[S(n-r)^2]=a*Ps

% E[S(n)S(n-r)]=E[S(n)]E[S(n-r)]=0  ==> S(n) est centrée
% E[S(i)S(j)]=0 if i!=j

% Ps=rxx(r)/a
% rxx(0)=(1+a^2)rxx(r)/a=rxx(r)/a+a*rxx(r)
% a*rxx(0)=rxx(r)+a^2*rxx(r)
% a^2-a*rxx(0)/rxx(r)+1=0
Ryy = xcorr(newnewsignal);

% R0=rxx(0)
[R0, I1] = max(Ryy);
% delay entre 100 ms et 400 ms
m1 = max(0, I1+round(0.1*Fe));
m2 = min(length(Ryy), I1+round(0.4*Fe));

% Rp=rxx(r)
[Rp, I2] = max(Ryy(m1:m2));
indexP = I2+m1-1;
P = indexP-I1;

% Résolution de l'équation du second ordre
EquationAlpha = [1, -R0/Rp, 1];
a = roots(EquationAlpha);

if abs(a(1))<1  % coefficient d'atténuation 0<alpha<1
    alpha = a(1);
else
    alpha = a(2);
end
display(alpha);

A = [1, zeros(1,P-1), alpha];
S = filter(1, A, newnewsignal);

% Lecture of the signal
p = audioplayer(S,Fe);
p.play;

figure(1)
subplot(2,1,1)
plot(t,signal)
subplot(2,1,2)
plot(t,newnewsignal)

% figure(2)
% plot(f,spectrum)
