clear; clc; close all;

%% Data organization
% Baca file rawdataset1.mat hingga rawdataset(N).mat
dirPath = "D:\Kuliah\Semester 8\Skripsi\Source Code\NEW Dataset " + ...
    "(01-08-22)\datavol";
% datasetFile = dir(fullfile(dirPath,'rawdatavol*.mat'));
datasetFile = natsortfiles(dir(fullfile(dirPath,'rawdatavol36.mat')));
% Note: Gunakan fungsi 'natsort.m' dan 'natsortfiles.m' oleh 
%       Stephen Cobeldick untuk menjalankan kode diatas

window = 50;
dataInWindow = window * 10;

RMSE = zeros(5, 1);
NRMSE = zeros(5, 1);
R = zeros(5, 1);
stDev = zeros(5, 1);
dataPHraw = cell(1, 5);
POTdata = zeros(200000/dataInWindow, 1);

for k = 1 : numel(datasetFile) %k = 6 : numel(datasetFile)-1
    m = numel(sprintf('Preparing dataset %d\n', k));
    fprintf('Preparing dataset %d\n', k);

	% Buka setiap file 
    matFile = load(fullfile(dirPath,datasetFile(k).name));
    EMG = matFile.data_vol(:,3);               % Baca data sinyal EMG
    % EMG = EMG - mean(EMG);
    POT = matFile.data_vol(:,2);           % Baca data potensiometer
    % Cari dan ganti outliers dengan window = 1 detik menggunakan metode
    % median sepanjang data yang ada
    t = seconds(linspace(0, 20, length(EMG))); % Panjang data dalam detik  
    [POT, ~] = filloutliers(POT, 'clip', 'movmedian', ...
        seconds(.1), 'Samplepoints', t);
    TH = 4 * (sum(EMG(1:100)) / 100);
    pred = predict(EMG, TH, window, @NARXNN50);
    % Konversi data potensiometer ke dalam bentuk sudut
    % Parameter (POTdata = a*POTdata + b) didapatkan dari kalibrasi
    % potensiometer dengan menggunakan goniometer
    POT = (74.155*POT) - 1.6953;
    % Hilangkan noise pengukuran
    POT = circshift(POT, -4000);
    POT = limitSudut(POT, 0);
    j = (1:dataInWindow:length(POT))';
    for i = 1:length(POT)/dataInWindow
            POTdata(i) = POT(j(i));
    end

    % Gabung dalam satu variabel placeholder (dataPH)
    dataPHraw{k} = [pred POTdata];
    RMSE(k) = sqrt(goodnessOfFit(pred, POTdata,'MSE'));
    NRMSE(k) = goodnessOfFit(pred, POTdata,'NRMSE');
    % NRMSE(k) = (1 - NRMSE) * 100;
    [R(k),~,~] = regression(num2cell(POTdata),num2cell(pred),'one');
    % stDev(k) = std(pred);
    
    fprintf(repmat(char(8), [1 m]));
end

k = (1:k)';
avgRMSE = mean(RMSE(6:end)) %#ok
avgR = mean(R(6:end))       %#ok
dataCombRaw = cat(1, dataPHraw{:});
% filename = "Performance Result\testPerformance-100.xlsx";
% writematrix ([k RMSE R NRMSE], filename, 'WriteMode', 'append');

% plot(dataCombRaw)
lenData = (window/1000:window/1000:20)';
plotFigure(lenData, [], POTdata, pred, ...
    'Sudut Terukur dan Estimasi Sudut', 'Sudut Terukur', ...
    'Estimasi Sudut', 'true')
xlabel('Waktu (s)')
ylabel('Sudut (°)')


