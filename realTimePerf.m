clear; clc; close all;

%% Data organization
% Baca file rawdataset1.mat hingga rawdataset(N).mat
dirPath = "D:\Kuliah\Semester 8\Skripsi\Source Code";
% datasetFile = dir(fullfile(dirPath,'rawdatavol*.mat'));
datasetFile = natsortfiles(dir(fullfile(dirPath,'result8.mat')));
% Note: Gunakan fungsi 'natsort.m' dan 'natsortfiles.m' oleh 
%       Stephen Cobeldick untuk menjalankan kode diatas

perf = cell(1, numel(datasetFile));
window = 200;
dataInWindow = window * 10;
i = dataInWindow:dataInWindow:200000;
j = 1:dataInWindow:200000;
endPred = zeros(1,length(i));
pred = zeros(length(i),1);

for k = 1 : numel(datasetFile)
    m = numel(sprintf('Preparing real-time data and prediction result %d\n', k));
    fprintf('Preparing real-time data and prediction result %d\n', k);

	% Buka setiap file 
    matFile = load(fullfile(dirPath,datasetFile(k).name));
    EMG = matFile.EMG;               % Baca data sinyal EMG
    TH = 4 * (sum(EMG(1:100)) / 100);
    for t = 1:length(i)
        emgs = EMG(j(t):i(t));
        % pred = predict(emgs, TH, @NARXNNv3);
        startPred = tic;
            pred = predict(emgs, TH, window, @NARXNN200);
        endPred(t) = toc(startPred);
    end
    
    POT = (matFile.POT)';            % Baca data potensiometer
    ts = seconds(linspace(0, 20, length(POT))); 
    [POT, ~] = filloutliers(POT, 'clip', 'movmedian', ...
        seconds(.1), 'Samplepoints', ts);
    POT = circshift(POT, 1900);
    POT = movavge(POT, 500);
    POT = movavge(POT, 500);
    POT = downsample(POT, dataInWindow);
    
    pred = predict(EMG, TH, window, @NARXNN200);
    
    RMSE = sqrt(goodnessOfFit(pred, POT,'MSE'));
    NRMSE = goodnessOfFit(pred, POT,'NRMSE');
    [R,~,~] = regression(num2cell(POT),num2cell(pred),'one');
    
    TH = matFile.TH;
    endAcq = matFile.endAcq;
    endAll = matFile.endAll;
    predTime = matFile.predTime;
    
    time = mean(endPred);
    
    % Gabung dalam satu variabel placeholder (dataPH)
    perf{k} = [k RMSE NRMSE R TH endAcq endAll predTime time];
    fprintf(repmat(char(8), [1 m]));
    
end

perfs = cat(1, perf{:}); 

% save realTimePerf.mat perf

fprintf("Data preparation finished   \x2713\n");
%%

% filename = "Performance Result\realtime-performance-200.xlsx";
% disp("Saving performance result of real time prediction...");
% writematrix (perfs, filename, 'WriteMode', 'append'); %perfs(:,9)
lenData = (window/1000:window/1000:20)';
plotFigure(lenData, [], POT, ...
    pred', 'Hasil Pengukuran vs Hasil Prediksi NARX', ...
    'Hasil Pengukuran', 'Hasil Prediksi NARX', 'true')