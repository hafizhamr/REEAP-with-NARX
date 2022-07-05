function [feature] = extract(emg, sudut, tresholdZC)
    Ts = .001;
    window = 100;
    winSum = floor(length(emg) / window) - 1;  % Jumlah window
    
    % Looping setiap window
    for k = 0:winSum                           
        % Inisialisasi data pada masing-masing window dari data awal
        j = k * window;
        for jj = 1:window               % Looping untuk windowing
            emgs(jj) = emg(j+jj);       % Ambil data EMG untuk 1 window
            suduts(jj) = sudut(j+jj);   % Ambil data Sudut untuk 1 window
        end
        % Hitung banyaknya Zero Crossing dalam 1 window
        zc(k+1) = jZC(emgs, tresholdZC);
        % Hitung nilai Integrated EMG dalam satu window
        iemg(k+1) = sum(abs(emgs));  
        % Ambil data sudut dalam 1 window
        sudutS(k+1) = suduts(window);       
    end
    
    ts = 0:(Ts*window):Ts*window*winSum; %Time sampling
    feature.zc = zc';
    feature.iemg = iemg';
    feature.sudut = sudutS';
    feature.ts = ts';
    clear 'zc';
    clear 'iemg';
    clear 'sudutS';
end