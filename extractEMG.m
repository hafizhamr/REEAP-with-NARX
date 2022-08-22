function [feature] = extractEMG(emg, threshold, window)
    dataInWindow = 10 * window;
    winSum = floor(length(emg) / dataInWindow) - 1;  % Jumlah window
    
    emgs = zeros(1,dataInWindow);
    zc = zeros(1,length(emg)/dataInWindow);
    iemg = zeros(1,length(emg)/dataInWindow);
    
    % Looping setiap window
    for k = 0:winSum                           
        % Inisialisasi data pada masing-masing window dari data awal
        j = k * dataInWindow;
        for jj = 1:dataInWindow         % Looping untuk windowing
            emgs(jj) = emg(j+jj);       % Ambil data EMG untuk 1 window
        end
        % Hitung banyaknya Zero Crossing dalam 1 window
        zc(k+1) = jZC(emgs*dataInWindow, threshold);
        % Hitung nilai Integrated EMG dalam satu window
        iemg(k+1) = sum(abs(emgs));     
    end

    feature.ft = [zc' iemg'];
end