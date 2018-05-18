clear
clc

% Chargement le fichier audio
[s,Fs] = audioread('0123456789.wav');

L = length(s); % Longueur du signal original
Ts = 1/Fs; % Période du signal originial
Fspas = Fs/(L-1); % Pas fréquentiel du signal original

t = 0:Ts:(L-1)*Ts; % intervalle de temps
f = 0:Fspas:Fs; % intervalle de fréquences d'étude

% Filtrage du 440 Hz
% The dial tone is a sinusoidal signal.
% Its frequency is equal to 440Hz.
load 'F440.mat';
A=F440.tf.num;
B=F440.tf.den;
y=filter(A,B,s);

% Décimation du signal
% fréquences [697 +- 10.455 Hz; 1637 +- 24.555 Hz]
Fd = 2000; % fréquences fondamentales inférieures à 2000HZ
Fse = 2*Fd; % fréquence sous échantillonné
k = floor(Fs/Fse); % facteur de décimation

% Signal décimé
ydec = decimate(y,k);
Tydec = 1/Fse; % période de sous échantillonnage
Lydec = length(ydec); % longueur du signal décimé
Fsepas = Fse/(Lydec-1); % pas fréquentiel du signal décimé

tdec = 0:Tydec:(Lydec-1)*Tydec; % intervalle de temps
fdec = 0:Fsepas:Fse; % intervalle de fréquences d'étude

% Puissance du signal décimé
Powerydec = ydec.*ydec;

% Détermination de la puissance seuil bruit
% filtre moyennant les valeurs, ordre 119
noCoeffs = 120;
coeffs = ones(noCoeffs,1)/noCoeffs;
filteredSignal = filter(coeffs,1,Powerydec);
Pbruitseuil = max(filteredSignal)/2;



