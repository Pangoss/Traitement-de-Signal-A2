% TP_DTMF réalisé par David FENG (10250) et Kenza Kettani (10279)

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

% Puissance du signal décimé
Powerydec = y.*y;

% Détermination de la puissance seuil bruit
% filtre moyennant les valeurs, ordre 119
noCoeffs = 120;
coeffs = ones(noCoeffs,1)/noCoeffs;
filteredSignal = filter(coeffs,1,Powerydec);
Pbruitseuil = max(filteredSignal)/2;

% Récupération intervales présence de notes
binSignal = filteredSignal>Pbruitseuil;
positions = binSignal(2:end)-binSignal(1:length(binSignal)-1);
startPositions = find(positions==1);
endPositions = find(positions==-1);

fbref = [ 697, 770, 852, 941 ];
fhref = [ 1209, 1336, 1477, 1637 ];

dtmf = [ ['1', '2', '3', 'a'];
         ['4', '5', '6', 'b'];
         ['7', '8', '9', 'c'];
         ['*', '0', '#', 'd'];
       ];

load 'F697.mat';
A697=F697.tf.num;
B697=F697.tf.den;

load 'F770.mat';
A770=F770.tf.num;
B770=F770.tf.den;

load 'F852.mat';
A852=F852.tf.num;
B852=F852.tf.den;

load 'F941.mat';
A941=F941.tf.num;
B941=F941.tf.den;

load 'F1209.mat';
A1209=F1209.tf.num;
B1209=F1209.tf.den;

load 'F1336.mat';
A1336=F1336.tf.num;
B1336=F1336.tf.den;

load 'F1477.mat';
A1477=F1477.tf.num;
B1477=F1477.tf.den;

load 'F1637.mat';
A1637=F1637.tf.num;
B1637=F1637.tf.den;

F1=zeros(1,4);
F2=zeros(1,4);

for i= 1:length(startPositions)
    portionsignal=y(startPositions(i):endPositions(i));
    
    liste1=zeros(1,4);
    liste2=zeros(1,4);
    
    % Basse fréquence
    indexflow1 = round(600*length(portionsignal)/Fs);
    indexflow2 = round(1000*length(portionsignal)/Fs);

    % Haute fréquence
    indexfhigh1 = round(1100*length(portionsignal)/Fs);
    indexfhigh2 = round(1600*length(portionsignal)/Fs);
    
    % détection 697 Hz
    newsignal697=filter(A697, B697, portionsignal);
    spectre697=abs(fft(newsignal697));
    liste1(1)=max(spectre697(indexflow1:indexflow2));

    % détection 770 Hz
    newsignal770=filter(A770, B770, portionsignal);
    spectre770=abs(fft(newsignal770));
    liste1(2)=max(spectre770(indexflow1:indexflow2));
    
    % détection 852 Hz
    newsignal852=filter(A852, B852, portionsignal);
    spectre852=abs(fft(newsignal852));
    liste1(3)=max(spectre852);
    
    % détection 941 Hz
    newsignal941=filter(A941, B941, portionsignal);
    spectre941=abs(fft(newsignal941));
    liste1(4)=max(spectre941);
    
    % détection 1209 Hz
    newsignal1209=filter(A1209, B1209, portionsignal);
    spectre1209=abs(fft(newsignal1209));
    liste2(1)=max(spectre1209);
    
    % détection 1336 Hz
    newsignal1336=filter(A1336, B1336, portionsignal);
    spectre1336=abs(fft(newsignal1336));
    liste2(2)=max(spectre1336);
    
    % détection 1477 Hz
    newsignal1477=filter(A1477, B1477, portionsignal);
    spectre1477=abs(fft(newsignal1477));
    liste2(3)=max(spectre1477);
    
    % détection 1637 Hz
    newsignal1637=filter(A1637, B1637, portionsignal);
    spectre1637=abs(fft(newsignal1637));
    liste2(4)=max(spectre1637);
    
    [~, valeur1]=max(liste1);
    [~, valeur2]=max(liste2);
    
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
