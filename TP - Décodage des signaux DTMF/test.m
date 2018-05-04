clear
clc
% Resolve the 1.24 kHz and 1.26 kHz components in the following
       % noisy cosine which also has a 10 kHz component.
       
       [x, Fs]  = audioread('0123456789.wav');
       L=length(x);
       Ts = 1/Fs;
       t = 0:Ts:(L-1)*Ts;
       
       N = (L+1)/2;
       f = (Fs/2)/N*(0:N-1);              % Generate frequency vector
       indxs = find(f>0.6e3 & f<1.5e3);   % Find frequencies of interest
       X = goertzel(x,indxs);
       Power=abs(X).^2/L;
       
       %----------------------------------------------------
        % Filtrage du 440 Hz
        load 'F440.mat';
        A=F440.tf.num;
        B=F440.tf.den;
        y=filter(A,B,x);
       %----------------------------------------------------
       Fd = 2000; % fréquences fondamentales inférieures à 2000HZ
        Fse = 2*Fd; % fréquence sous échantillonné
        k = floor(Fs/Fse); % facteur de décimation

       ydec = decimate(y,k);
        Tydec = 1/Fse; % période de sous échantillonnage
        Lydec = length(ydec); % longueur du signal décimé
        Fsepas = Fse/(Lydec-1); % pas fréquentiel du signal décimé

        tdec = 0:Tydec:(Lydec-1)*Tydec; % intervalle de temps
        fdec = 0:Fsepas:Fse; % intervalle de fréquences d'étude
        indxs1 = find(fdec>0.6e3 & fdec<1.5e3);
        Y = goertzel(ydec,indxs1);
        Power1=abs(Y).^2/Lydec;
       %----------------------------------------------------
       % Détermination de la puissance seuil bruit
        Pbruitseuil = 24;

        % Détection de la présence du signal
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
       %----------------------------------------------------
       signal = zeros(1,Lydec);
        for n=1+K:Lydec-K
            signal(n-K) = presence(n)*ydec(n);
        end
       %----------------------------------------------------
       % Récupérer les intervales des notes
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

        % Récupérer uniquement les intervales non nuls
        intervalesFinal = zeros(1,indice-1);
        for n=1:indice-1
           intervalesFinal(n) = intervales(n);
        end
        %----------------------------------------------------
        for l=1:(length(intervalesFinal))/2
            x1 = intervalesFinal(l);
            x2 = intervalesFinal(l+1);
            portion = signal(x1:x2);
            indxs2 = find(fdec>0.6e3 & fdec<1.5e3);
            signalFinal = goertzel(portion,indxs2);
            PowerFinal = abs(signalFinal).^2/length(signal);
            
            figure
            plot(fdec(indxs2),PowerFinal)
        end
        %----------------------------------------------------
       
       figure(1)
       plot(f(indxs),20*log10(abs(X)/length(X)));
       title('Mean Squared Spectrum');
       xlabel('Frequency (kHz)');
       ylabel('Power (dB)');
       grid on;
       set(gca,'XLim',[f(indxs(1)) f(indxs(end))]);
       
       figure(2)
       subplot(2,1,1)
       plot(f(indxs),Power);
       subplot(2,1,2)
       plot(fdec(indxs1),Power1);
       
       figure(3)
       subplot(3,1,1)
       plot(tdec,ydec)
       subplot(3,1,2)       
       plot(tdec,presence,'r')
       subplot(3,1,3)
       plot(tdec,signal)
       
       
       