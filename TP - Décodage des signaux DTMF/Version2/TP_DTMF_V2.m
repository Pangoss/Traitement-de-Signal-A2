clear
clc

% Chargement le fichier audio
[s,Fs] = audioread('0123456789.wav');

L = length(s); % Longueur du signal original
Ts = 1/Fs; % P�riode du signal originial
Fspas = Fs/(L-1); % Pas fr�quentiel du signal original

t = 0:Ts:(L-1)*Ts; % intervalle de temps
f = 0:Fspas:Fs; % intervalle de fr�quences d'�tude

% Filtrage du 440 Hz
% The dial tone is a sinusoidal signal.
% Its frequency is equal to 440Hz.
load 'F440.mat';
A=F440.tf.num;
B=F440.tf.den;
y=filter(A,B,s);

% D�cimation du signal
% fr�quences [697 +- 10.455 Hz; 1637 +- 24.555 Hz]
Fd = 2000; % fr�quences fondamentales inf�rieures � 2000HZ
Fse = 2*Fd; % fr�quence sous �chantillonn�
k = floor(Fs/Fse); % facteur de d�cimation

% Signal d�cim�
ydec = decimate(y,k);
Tydec = 1/Fse; % p�riode de sous �chantillonnage
Lydec = length(ydec); % longueur du signal d�cim�
Fsepas = Fse/(Lydec-1); % pas fr�quentiel du signal d�cim�

tdec = 0:Tydec:(Lydec-1)*Tydec; % intervalle de temps
fdec = 0:Fsepas:Fse; % intervalle de fr�quences d'�tude

% Puissance du signal d�cim�
Powerydec = ydec.*ydec;

% D�termination de la puissance seuil bruit
% filtre moyennant les valeurs, ordre 119
noCoeffs = 120;
coeffs = ones(noCoeffs,1)/noCoeffs;
filteredSignal = filter(coeffs,1,Powerydec);
Pbruitseuil = max(filteredSignal)/2;



