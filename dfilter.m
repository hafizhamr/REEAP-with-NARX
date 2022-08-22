function filtered_emg = dfilter(emg, varargin)
    % Filter sinyal EMG dengan Butterworth IIR Filter
    % Bandpass filter orde 2 dengan rentang frekuensi 10Hz - 500 Hz
    % Notch Filter di frekuensi 50Hz untuk PLI
    
    fs = 10000;                         % Sampling rate
    wnb = [10 450] / (fs / 2);          % Frekuensi cut-off bandpass
    wnn = [49 51] / (fs / 2);           % Frekuensi cut-off notch
    
    % Bandpass filter
    [z,p,k] = butter(4, wnb, 'bandpass');
    [sos,g] = zp2sos(z,p,k);
    % fvtool(sos, 'Analysis', 'freq', 'Fs', 10000)
    filtered_emg = filtfilt(sos, g, emg);

    % Notch filter
    [z,p,k] = butter(2, wnn, 'stop');
    [sos,g] = zp2sos(z,p,k);
    % fvtool(sos, 'Analysis', 'freq', 'Fs', 10000)
    filtered_emg = filtfilt(sos, g, filtered_emg);

    if nargin == 1
        useFFT = 'false';
    else
        useFFT = "true";
    end

    if useFFT == "true"
        L = length(emg);
        f = fs*(0:(L/2))/L;
        
        Y = fft(emg);
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        
        Y2 = fft(filtered_emg);
        P4 = abs(Y2/L);
        P3 = P4(1:L/2+1);
        P3(2:end-1) = 2*P3(2:end-1);
        
        plotFigure(f, [], P1, P3, 'Raw EMG dan Filtered EMG', ...
            'Raw EMG', 'Filtered EMG', 'true')
        ylim([0 0.0015])
        xlim([0 700])
        grid on
    else
    end
end
