clear
clc

% Chargement le fichier audio
[s,Fs] = audioread('0123456789.wav');

L = length(s); % Longueur du signal original
Ts = 1/Fs; % P�riode du signal originial
Fspas = Fs/(L-1); % Pas fr�quentiel du signal original

t = 0:Ts:(L-1)*Ts; % intervalle de temps
f = 0:Fspas:Fs; % intervalle de fr�quences d'�tude

% D�cimation du signal
% fr�quences [697 +- 10.455 Hz; 1637 +- 24.555 Hz]
Fd = 2000; % fr�quences fondamentales inf�rieures � 2000HZ
Fse = 2*Fd; % fr�quence sous �chantillonn�
k = floor(Fs/Fse); % facteur de d�cimation

% Signal d�cim�
ydec = decimate(s,k);
Tydec = 1/Fse; % p�riode de sous �chantillonnage
Lydec = length(ydec); % longueur du signal d�cim�
Fsepas = Fse/(Lydec-1); % pas fr�quentiel du signal d�cim�

tdec = 0:Tydec:(Lydec-1)*Tydec; % intervalle de temps
fdec = 0:Fsepas:Fse; % intervalle de fr�quences d'�tude

load 'F697.mat';
A=F697.tf.num;
B=F697.tf.den;
y=filter(A,B,ydec);
absfft=abs(fft(y));
plot(fdec,absfft);

