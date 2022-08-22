clear; clc; close all;

%% Akuisisi data Real-time

% Buat file sementara 'log.bin' untuk menyimpan data akuisisi
fid = fopen("log.bin","w");
t = 20;                                 % Waktu akuisisi data
Fs = 10000;                             % Frekuensi sampling

d = daq("ni");                          % Inisialisasi device
addinput(d, "myDAQ2", 0:1, "Voltage");    % Set AI channel
d.Rate = 10000;                         % Set rate sinyal
% Set properti DAQ
% Jalankan fungsi 'acquireData' saat telah memenuhi jumlah data
% yang diinginkan (d.ScansAvailableFcnCount)
d.ScansAvailableFcn = @(src,event) acquireData(src, event, fid);
d.ScansAvailableFcnCount = 1000;

startAll = tic;
startAcq = tic;
    start(d, "Duration", seconds(t))        % Mulai akuisisi data

    fprintf("Scans remaining = ");
    while d.Running
        m = numel(sprintf('%d seconds\n', t-(d.NumScansAcquired/d.Rate)));
        fprintf('%d seconds\n', t-(d.NumScansAcquired/d.Rate));
        pause(1)
        fprintf(repmat(char(8), [1 m]));
    end
endAcq = toc(startAcq);

fprintf(repmat(char(8), [1 18]));
fprintf("Acquisition finished with %d scans acquired\n", ...
    d.NumScansAcquired);

fclose(fid);

%% Prediksi sudut dari data sinyal EMG yang diakuisisi
% Buka data akuisisi
fid = fopen('log.bin','r');
[data, ~] = fread(fid,[3,inf],'double');
fclose(fid);
% preds = fopen('preds.bin','r');
% pred = fread(preds,[1,inf],'double');
% fclose(preds);
% Mulai prediksi => prediction = predict(EMG, NARX),
% dimana EMG = input sinyal yang ingin diprediksi
%        NARX = NARX Neural Network yang ingin digunakan
EMG = data(3,:);
POT = data(2,:);
POT = (74.155*POT) - 1.6953;
POT = circshift(POT, -4000);
POT = limitSudut(POT, 0);
TH = 4 * (sum(EMG(1:100)) / 100);
pred = predict(data(3,:), TH, @NARXNNv3);

endAll = toc(startAll);
predTime = endAll - endAcq;
fprintf("Acquisition finished in %.4f seconds\n", ...
    endAcq);
fprintf("Acquisition and Prediction finished in %.4f seconds\n", ...
    endAll);
fprintf("Prediction time: %.4f seconds\n", ...
    predTime);

% filename = "Performance Result\realtime-performance.xlsx";
% disp("Saving performance result of real time prediction...");
% writematrix ([endAcq endAll predTime], ...
%     filename, 'WriteMode', 'append');

save result15.mat EMG POT pred TH endAcq endAll predTime

plotFigure(1:numel(POT), (1:numel(pred))*500, POT, ...
    pred', 'Hasil Pengukuran vs Hasil Prediksi NARX', ...
    'Hasil Pengukuran', 'Hasil Prediksi NARX', 'true')

%% Fungsi Akuisisi Data
function acquireData(src, ~, fid)
    % Mulai baca data
    [data, timestamps, ~] = read(src, src.ScansAvailableFcnCount, ...
        "OutputFormat", "Matrix");
%     TH = 4 * (sum(data(1:100)) / 100);
%     pred = predict(data, TH, @NARXNNv3);
%     fwrite(preds, pred, 'double');
    % Simpan hasil akuisisi data
    datas = [timestamps, data]' ;
    fwrite(fid, datas, 'double');
    % Plot sinyal secara real-time
    animatedline(timestamps, data(:,1), 'Color', 'b');     
    animatedline(timestamps, data(:,2), 'Color', 'r');
    xlabel('Time (s)');
    ylabel('Amplitude (V)');
end