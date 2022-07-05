clear; clc;

%% Data organization
% Baca file rawdataset1.mat hingga rawdataset(N).mat
dirPath = "~\Dataset_raw";	% Full path folder dataset
datasetFile = dir(fullfile(dirPath,'rawdataset*.mat'));
%datasetFile = natsortfiles(dir(fullfile(dirPath,'rawdataset*.mat')));
% Note: Gunakan fungsi 'natsort' dan 'natsortfiles' oleh Stephen Cobeldick
%       untuk menjalankan kode diatas
dataPH = cell(1, numel(datasetFile));

for k = 1 : numel(datasetFile)
	% Buka setiap file dan gabung menjadi satu file dalam variabel
    % placeholder (dataPH)
    matFile = load(fullfile(dirPath,datasetFile(k).name));
    EMG = matFile.dataset(:,3);               % Baca data sinyal EMG
    t = seconds(linspace(0,20, length(EMG)));  % Panjang data dalam detik  
    % Cari dan ganti outliers dengan window = 1 detik menggunakan metode
    % median sepanjang data yang ada
    [EMGfilter, TF] = filloutliers(EMG, 'clip', 'movmedian', ...
        seconds(.1), 'Samplepoints', t); 
    dataPHraw{k} = matFile.dataset(:,2:3);
    dataPHfilter{k} = [matFile.dataset(:,2) EMGfilter];
end

% Buka data dan jadikan satu variabel
dataCombRaw = cat(1, dataPHraw{:});    
dataCombFilter = cat(1, dataPHfilter{:});
POTdata = dataCombRaw(:,1);        % Data sudut potensiometer raw
EMGdata = dataCombRaw(:,2);       % Data sinyal EMG raw
%EMGdata = dataCombFilter(:,2);
lenData = (1:length(POTdata));

figure
yyaxis left
plot(lenData, POTdata)
yyaxis right
plot(lenData, EMGdata)
leg = legend('Sudut', 'Raw EMG');
leg.ItemHitFcn = @legendToggle;

% save newrawDataset.mat dataCombRaw
% save newrawDatasetFilt.mat dataCombFilter

%% Olah sudut dan sinyal EMG
% Filter sinyal EMG dengan Butterworth IIR Filter
% Bandpass filter orde 2 dengan rentang frekuensi 10Hz - 500 Hz
% Biasanya sinyal EMG yang diambil berada pada rentang 10-20 Hz (high-pass)
% dan pada rentang 450-500 Hz (low-pass)
% Notch Filter di frekuensi 50Hz untuk PLI
EMGfilter = dfilter(EMGdata);
% Note: Gunakan fungsi 'dfilter' untuk menjalankan kode diatas

% Olah data sudut dengan moving average untuk smoothing dan
% menghilangkan spike artifacts
windowWidth = 100;
kernel = ones(windowWidth, 1) / windowWidth;
POTfilter = filtfilt(kernel, 1, POTdata);
%POTfilter = POTdata;
 
% Gabung data menjadi dataset
dataCombFilt = [POTfilter EMGfilter];
compEMGData = [EMGdata EMGfilter];
compPOTData = [POTdata POTfilter];
dataset = [POTdata EMGfilter];

% save newrawDataset_filt.mat dataCombFilt
% save newdataset.mat dataset

figure
yyaxis left
plot(lenData, POTfilter)
yyaxis right
plot(lenData, EMGfilter)
leg = legend('Filtered sudut', 'Filtered EMG');
leg.ItemHitFcn = @legendToggle;

figure
subplot(2,1,1)
yyaxis left
plot(lenData, EMGdata)
yyaxis right
plot(lenData, EMGfilter)
title('Raw EMG dan Filtered EMG');
leg = legend('Raw EMG', 'Filtered EMG');
leg.ItemHitFcn = @legendToggle;
subplot(2,1,2)
plot(compPOTData)
title('Sudut Raw dan Filtered Sudut');
leg = legend('Sudut Raw', 'Filtered Sudut');
leg.ItemHitFcn = @legendToggle;

%% EMG Feature Extraction
% Ekstraksi fitur EMG dengan panjang window 100 ms
% Setiap 0.1 detik data sinyal EMG akan diekstraksi dengan IEMG
feature = extract(EMGfilter*1000, POTfilter, 50);
zc = feature.zc;                % Ambil data Zero Crossing EMG
iemg = feature.iemg/1000;            % Ambil data Integrated EMG
sudut = feature.sudut;          % Ambil data sudut
time = feature.ts;              % Ambil data waktu total
ida = iddata(sudut, [zc iemg], .1);  % Gabung data
ida.InputName = {'zc','emg'};        % Set nama Input
ida.OutputName = {'sudut'};     % Set nama output

save new2dataFull.mat ida

figure
plot(ida)

figure
yyaxis left
plot(time, sudut)
yyaxis right
plot(time, iemg)
title('Sudut dan IEMG');
leg = legend('Sudut', 'IEMG');
leg.ItemHitFcn = @legendToggle;

% figure
% yyaxis left
% plot(EMGfilter)
% yyaxis right
% plot((1:numel(iemg))*100,iemg)

%% Normalization
% % Normalisasi data dengan jangkauan 0 hingga 1
% normalizedRaw = normalize(dataCombRaw, 'range');
% normalizedFilt = normalize(dataCombFilt, 'range');
% 
% % Normalisasi data dengan zero mean
% % normalizedRaw = dataCombRaw - mean(dataCombRaw);
% % normalizedFilt = dataCombFilt - mean(dataCombFilt);
% 
% figure
% subplot(2,1,1)
% plot(normalizedRaw)
% title('Sudut dan Raw EMG Ternormalisasi');
% legend('Sudut', 'Raw EMG');
% subplot(2,1,2)
% plot(normalizedFilt)
% title('Sudut dan Filtered EMG Ternormalisasi');
% legend('Sudut', 'Filtered EMG');
% save rawNormDataset_raw.mat normalizedRaw
% save rawNormDataset_filt.mat normalizedFilt
