clear
clc

% Chargement le fichier audio
[s,Fs] = audioread('0123456789.wav');

L = length(s); % Longueur du signal original
Ts = 1/Fs; % Période du signal originial
Fspas = Fs/(L-1); % Pas fréquentiel du signal original

t = 0:Ts:(L-1)*Ts; % intervalle de temps
f = 0:Fspas:Fs; % intervalle de fréquences d'étude

% Décimation du signal
% fréquences [697 +- 10.455 Hz; 1637 +- 24.555 Hz]
Fd = 2000; % fréquences fondamentales inférieures à 2000HZ
Fse = 2*Fd; % fréquence sous échantillonné
k = floor(Fs/Fse); % facteur de décimation

% Signal décimé
ydec = decimate(s,k);
Tydec = 1/Fse; % période de sous échantillonnage
Lydec = length(ydec); % longueur du signal décimé
Fsepas = Fse/(Lydec-1); % pas fréquentiel du signal décimé

tdec = 0:Tydec:(Lydec-1)*Tydec; % intervalle de temps
fdec = 0:Fsepas:Fse; % intervalle de fréquences d'étude

load 'F697.mat';
A=F697.tf.num;
B=F697.tf.den;
y=filter(A,B,ydec);
absfft=abs(fft(y));
plot(fdec,absfft);

