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
Pbruitseuil = 24;

% D�tection de la pr�sence du signal
K=70;
presence = zeros(1,Lydec);
for n=1+K:Lydec-K
    ydecfen = ydec(n-K:n+K);
    Ydecfen = fft(ydecfen);
    Ydecfenabs = abs(Ydecfen);
    Ydecfendb = 20*log10(Ydecfenabs);
    if Ydecfendb <= Pbruitseuil
        presence(n-K)=0;
    else
        presence(n-K)=1;
    end
end

% Isolation des fr�quences
test=(0:Tydec:(Lydec-1)/Fse);
NFFT = 2^nextpow2(Lydec);
Ydectest = fft(ydec,NFFT);
ftest = Fse/2*linspace(0,1,NFFT/2+1);
Mag=2*abs(Ydectest(1:NFFT/2+1));

% R�cup�rer uniquement un signal avec les notes
signal = zeros(1,Lydec);
for n=1+K:Lydec-K
    signal(n-K) = presence(n)*ydec(n);
end

% R�cup�rer les intervales des notes
intervales = zeros(1,60); % changer la taille en fonction du nombre de notes
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
fbref = [ 697, 770, 852, 941 ]';
fhref = [ 1209, 1336, 1477, 1637 ]';
fref = [697 770 852 941 1209 1336 1477 1637];
freq_indices = round(fref/Fse*Tydec) + 1;
dft_data = goertzel(ydec,freq_indices);

figure(6)
stem(fref,abs(dft_data))
ax = gca;
ax.XTick = fref;
xlabel('Frequency (Hz)')
title('DFT Magnitude')

dtmf = [ ['1', '2', '3', 'a'];
         ['4', '5', '6', 'b'];
         ['7', '8', '9', 'c'];
         ['*', '0', '#', 'd'];
       ];
   
for l=1:(length(intervalesFinal))/2
    x1 = intervalesFinal(l);
    x2 = intervalesFinal(l+1);
    
% FFT portion du signal
portion = fft(ydec(x1:x2),2000);
fAxis=-Fse/2:Fse/2000:Fse/2-Fse/2000;

[M,I]=max(abs(portion));
freq1=2000-I*Fse/2000;
% display(freq1);

for n=I-70:I+70
    portion(n)=0;
    portion(1000+(1000-n))=0;
end

[H,G]=max(abs(portion));
freq2=2000-G*Fse/2000;
% display(freq2);

% D�termincation du bouton

for n=1:length(fbref)
   if ((freq1 <= (fbref(n)+fbref(n)*3/100)) && (freq1 >= (fbref(n)-fbref(n)*3/100))) || ((freq1 <= (fhref(n)+fhref(n)*3/100)) && (freq1 >= (fhref(n)-fhref(n)*3/100)))
       disp(n);
   end
   if ((freq2 <= (fbref(n)+fbref(n)*3/100)) && (freq2 >= (fbref(n)-fbref(n)*3/100))) || ((freq2 <= (fhref(n)+fhref(n)*3/100)) && (freq2 >= (fhref(n)-fhref(n)*3/100)))
       disp(n);
   end
end
% disp(dtmf(INDEX1,INDEX2));

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

% Pr�sence des fr�quences dans le signal
figure(3)
subplot(2,1,1)
plot(ftest,Mag)
grid on
title('Magnitude Spectrum')
xlabel('Frequency (Hz)')
ylabel('|X(f)|')
legend('Frequency Spectrum')

subplot(2,1,2)
periodogram(ydec,[],[],Fse)

% Portion 1
figure(4)
plot(fAxis,abs(portion))
