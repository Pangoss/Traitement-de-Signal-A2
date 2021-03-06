% TP_DTMF r�alis� par David FENG (10250) et Kenza Kettani (10279)

% Chargement le fichier audio
[s,Fs] = audioread('numero4.wav');

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

% FFT du signal d'origine
Sfft = fft(s); % transform�e de Fourier du signal d'origine
Sabs = abs(Sfft); % abs de la fft du signal s
Sdb = 20*log10(Sabs); % gain en dB du signal s

% FFT du signal filtr� 440Hz
Yfft = fft(y); % transform�e de Fourier du signal filtr� 440 Hz
Yabs = abs(Yfft); % abs de la fft du signal filtr� 440 Hz
Ydb = 20*log10(Yabs); % gain en dB du signal filtr� 440 Hz

% FFT du signal filtr� 440 Hz et d�cim�
Ydecfft = fft(ydec); % transform�e de Fourier du signal filtr� 440 Hz et d�cim�
Ydecabs = abs(Ydecfft); % abs de la fft du signal filtr� 440 Hz et d�cim�
Ydecdb = 20*log10(Ydecabs); % gain en dB du signal filtr� 440 Hz et d�cim�

% D�termination de la puissance seuil bruit
% filtre moyennant les valeurs, ordre 119
noCoeffs = 120;
coeffs = ones(noCoeffs,1)/noCoeffs;
filteredSignal = filter(coeffs,1,Powerydec);
Pbruitseuil = max(filteredSignal)/2;

% Signal Binaire de pr�sence
K = 70;
presence = zeros(1,Lydec);
for n=1:Lydec
    if filteredSignal(n) < Pbruitseuil
        presence(n)=0;
    else
        presence(n)=1;
    end
end

% R�cup�rer uniquement un signal avec les notes
signal = zeros(1,Lydec);
for n=1+K:Lydec-K
    signal(n-K) = presence(n)*ydec(n);
end

% R�cup�rer les intervales des notes
intervales = zeros(1,100); % changer la taille en fonction du nombre de notes
indice = 1;
for n=1:(length(presence)-1)
    if (presence(n)==0) && (presence(n+1)==1)
        intervales(indice) = n+1;
        indice = indice + 1;
    end
    if (presence(n)==1) && (presence(n+1)==0)
        intervales(indice) = n;
        indice = indice + 1;
    end
end

% R�cup�rer uniquement les intervales non nuls
intervalesFinal = zeros(1,indice-1);
for n=1:indice-1
   intervalesFinal(n) = intervales(n);
end

%------------------------------------------------------------------

% valeurs de r�f�rences
fbref = [ 697, 770, 852, 941 ];
fhref = [ 1209, 1336, 1477, 1637 ];
fref = [697 770 852 941 1209 1336 1477 1637];

dtmf = [ ['1', '2', '3', 'a'];
         ['4', '5', '6', 'b'];
         ['7', '8', '9', 'c'];
         ['*', '0', '#', 'd'];
       ];

F1=zeros(1,8);
F2=zeros(1,8);
for l=1:2:(length(intervalesFinal))
x1 = intervalesFinal(l);
x2 = intervalesFinal(l+1);
    
% FFT portion du signal
portionsignal = signal(x1:x2);
portion = abs(fft(portionsignal));

% Basse fr�quence
indexflow1 = round(600*length(portionsignal)/Fse);
indexflow2 = round(1000*length(portionsignal)/Fse);

% Haute fr�quence
indexfhigh1 = round(1100*length(portionsignal)/Fse);
indexfhigh2 = round(1600*length(portionsignal)/Fse);

[M,I1] = max(portion(indexflow1:indexflow2));
IndexBasseFq = I1+indexflow1-1;
freq1 = IndexBasseFq*Fse/length(portionsignal);

[H,G] = max(portion(indexfhigh1:indexfhigh2));
IndexHauteFq = G+indexfhigh1-1;
freq2 = IndexHauteFq*Fse/length(portionsignal);

% D�termination du bouton
for n=1:length(fbref)
    F1(n)=abs(freq1-fbref(n));
    F2(n)=abs(freq2-fbref(n));
end
for n=length(fbref)+1:(length(fbref)+length(fhref))
    F1(n)=abs(freq1-fhref(n-4));
    F2(n)=abs(freq2-fhref(n-4));
end

% Recherche de la diff�rence la plus basse
% car une tol�rance de 1.5% est beaucoup trop faible
valeur1=find(F1==min(F1));
valeur2=find(F2==min(F2));

% R�indexation
if(valeur1>4)
    valeur1=valeur1-4;
elseif(valeur2>4)
    valeur2=valeur2-4;
end

% Combinaison de low et high fr�quences
if(valeur1==1 && valeur2==1)
    disp(dtmf(1));
elseif(valeur1==2 && valeur2==1)
    disp(dtmf(2));
elseif(valeur1==3 && valeur2==1)
    disp(dtmf(3));
elseif(valeur1==4 && valeur2==1)
    disp(dtmf(4));
elseif(valeur1==1 && valeur2==2)
    disp(dtmf(5));
elseif(valeur1==2 && valeur2==2)
    disp(dtmf(6));
elseif(valeur1==3 && valeur2==2)
    disp(dtmf(7));
elseif(valeur1==4 && valeur2==2)
    disp(dtmf(8));
elseif(valeur1==1 && valeur2==3)
    disp(dtmf(9));
elseif(valeur1==2 && valeur2==3)
    disp(dtmf(10));
elseif(valeur1==3 && valeur2==3)
    disp(dtmf(11));
elseif(valeur1==4 && valeur2==3)
    disp(dtmf(12));
elseif(valeur1==1 && valeur2==4)
    disp(dtmf(13));
elseif(valeur1==2 && valeur2==4)
    disp(dtmf(14));
elseif(valeur1==3 && valeur2==4)
    disp(dtmf(15));
elseif(valeur1==4 && valeur2==4)
    disp(dtmf(16));
end

end
%------------------------------------------------------------------

% les figures affich�es
figure(1)
% Signal source
subplot(5,1,1)
plot(t,s)
xlabel('temps en s')
ylabel('amplitude')
title('signal source')

% Signal filtr� 440Hz
subplot(5,1,2)
plot(t,y)
xlabel('temps en s')
ylabel('amplitude')
title('signal source, 440Hz filtr�')

% Signal d�cim�
subplot(5,1,3)
plot(tdec,ydec)
xlabel('temps en s')
ylabel('amplitude')
title('signal d�cim�')

% Pr�sence signal
subplot(5,1,4)
plot(tdec,presence,'r')
xlabel('temps en s')
ylabel('pr�sence/absence')
title('pr�sence du signal d�cim�')

% Signal d�cim�
subplot(5,1,5)
plot(tdec,signal)
xlabel('temps en s')
ylabel('amplitude')
title('Signal x Pr�sence')

figure(2)
% Gain en dB du signal s
subplot(3,1,1)
plot(f,Sdb)
xlabel('fr�quence en Hz')
ylabel('Gains en dB')
title('fft Signal source')

% Gain en dB du signal d�cim�
subplot(3,1,2)
plot(f,Ydb);
xlabel('fr�quence en Hz')
ylabel('Gains en dB')
title('fft signal filtr� 440 Hz')

% Gain en dB du signal d�cim�
subplot(3,1,3)
plot(fdec,Ydecdb);
xlabel('fr�quence en Hz')
ylabel('Gains en dB')
title('fft signal filtr� 440 Hz et d�cim�')
