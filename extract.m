function [feature] = extract(emg, sudut, tresholdZC, windowSize)
    Fs = 10000;
    Ts = 1/Fs;
    window = windowSize/1000;               % s
    dataInWindow = Fs*window;
    winSum = floor(length(emg) / dataInWindow) - 1;  % Jumlah window
    
    emgs = zeros(1,dataInWindow);
    suduts = zeros(1,dataInWindow);
    zc = zeros(1,length(emg)/dataInWindow);
    iemg = zeros(1,length(emg)/dataInWindow);
    sudutS = zeros(1,length(emg)/dataInWindow);
    
    % Looping setiap window
    for k = 0:winSum                           
        % Inisialisasi data pada masing-masing window dari data awal
        j = k * dataInWindow;
        for jj = 1:dataInWindow         % Looping untuk windowing
            emgs(jj) = emg(j+jj);       % Ambil data EMG untuk 1 window
            suduts(jj) = sudut(j+jj);   % Ambil data Sudut untuk 1 window
        end
        % Hitung banyaknya Zero Crossing dalam 1 window
        zc(k+1) = jZC(emgs*dataInWindow, tresholdZC);
        % Hitung nilai Integrated EMG dalam satu window
        iemg(k+1) = sum(abs(emgs));  
        % Ambil data sudut dalam 1 window
        sudutS(k+1) = suduts(dataInWindow);
    end
    
    ts = 0:(Ts*dataInWindow):Ts*dataInWindow*winSum; %Time sampling
    feature.zc = zc';
    feature.iemg = iemg';
    feature.sudut = sudutS';
    feature.ts = ts';
end
