clear;
clc;

[signal,Fs]=audioread('0123456789.wav');
t=0:1/Fs:(length(signal)-1)*1/Fs;
%figure(1), plot(signal);

load 'F440.mat';

newsignal = filter(F440.tf.num, 1, signal);
figure(1), plot(newsignal);

powersignal = newsignal.*newsignal;
figure(2), plot(powersignal);

%design of averaging filter of order 119
noCoeffs = 120;
coeffs = ones(noCoeffs,1)/noCoeffs;
filteredSignal = filter(coeffs,1,powersignal);
seuil = max(filteredSignal)/2;
binSignal = filteredSignal>seuil;
figure(3),plot(t,binSignal);
positions = binSignal(2:end)-binSignal(1:length(binSignal)-1);

startPositions = find(positions==1);
endPositions = find(positions==-1);
length(startPositions);
length(endPositions);

fbref = [ 697, 770, 852, 941 ];
fhref = [ 1209, 1336, 1477, 1637 ];

dtmf = [ ['1', '2', '3', 'a'];
         ['4', '5', '6', 'b'];
         ['7', '8', '9', 'c'];
         ['*', '0', '#', 'd'];
       ];

F1=zeros(1,4);
F2=zeros(1,4);

%start analysing the subsignals
for i= 1:length(startPositions)
    subsignal = newsignal(startPositions(i):endPositions(i));
    spectrum = abs(fft(subsignal));
    figure(i+3), plot(spectrum);

    iflow1 = round(600*length(subsignal)/Fs);
    iflow2 = round(1000*length(subsignal)/Fs);

    ifhigh1 = round(1100*length(subsignal)/Fs);
    ifhigh2 = round(1600*length(subsignal)/Fs);

    [~,indexFlow] = max(spectrum(iflow1:iflow2));
    indexLowFreq = indexFlow+iflow1-1;
    lowFreq = indexLowFreq*Fs/length(subsignal);

    [~,indexFhigh] = max(spectrum(ifhigh1:ifhigh2));
    indexhighFreq = indexFhigh+ifhigh1-1;
    highFreq = indexhighFreq*Fs/length(subsignal);
    
    for n=1:length(fbref)
        F1(n)=abs(lowFreq-fbref(n));
        F2(n)=abs(highFreq-fhref(n));
    end
    
    valeur1=find(F1==min(F1));
    valeur2=find(F2==min(F2));

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






