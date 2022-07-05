%% Kode Fungsi dfilter
function filtered_emg = dfilter(emg)
    % Filter sinyal EMG dengan Butterworth IIR Filter
    % Bandpass filter orde 2 dengan rentang frekuensi 10Hz - 500 Hz
    % Notch Filter di frekuensi 50Hz untuk PLI
    
    fs = 1000;                         % Sampling rate
    wnb = [20 400] / (fs / 2);          % Frekuensi cut-off bandpass
    wnn = [49.98 50.02] / (fs / 2);     % Frekuensi cut-off notch
    
    % Bandpass filter
    [b, a] = butter(1, wnb, 'bandpass');
    emg_f = filtfilt(b, a, emg);
    %figure(3)
    %grpdelay(b, a, [])

    % Notch filter
    [b, a] = butter(1, wnn, 'stop');
    filtered_emg = filtfilt(b, a, emg_f);
    
%     % Rectification of filtered EMG signal
%     filtered_emg = abs(filtered_emg);
%     
%     % Envelope / IEMG
%     [filtered_emg,~] = envelope(filtered_emg, 100, 'peak');
%     filtered_emg = abs(filtered_emg);
end