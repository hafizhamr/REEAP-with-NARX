clear; clc;

%% Data organization
% Baca file rawdataset1.mat hingga rawdataset(N).mat
dirPath = "~\Dataset_raw";	% Full path folder dataset
%datasetFile = dir(fullfile(dirPath,'rawdataset*.mat'));
datasetFile = natsortfiles(dir(fullfile(dirPath,'rawdataset*.mat')));
% Note: Gunakan fungsi 'natsort.m' dan 'natsortfiles.m' oleh 
%       Stephen Cobeldick untuk menjalankan kode diatas

[TH, dataPHraw, dataPHfilter] = assignVar();

for k = 1 : numel(datasetFile)
    m = numel(sprintf('Preparing dataset %d\n', k));
    fprintf('Preparing dataset %d\n', k);

	% Buka setiap file 
    matFile = load(fullfile(dirPath,datasetFile(k).name));
    EMG = matFile.data_vol(:,3);               % Baca data sinyal EMG
    % EMG = EMG - mean(EMG);
    POTdata = matFile.data_vol(:,2);           % Baca data potensiometer
    % Cari dan ganti outliers dengan window = 1 detik menggunakan metode
    % median sepanjang data yang ada
    t = seconds(linspace(0, 20, length(EMG))); % Panjang data dalam detik  
    [POTdata, ~] = filloutliers(POTdata, 'clip', 'movmedian', ...
        seconds(.1), 'Samplepoints', t);

    % Konversi data potensiometer ke dalam bentuk sudut
    % Parameter (POTdata = a*POTdata + b) didapatkan dari kalibrasi
    % potensiometer dengan menggunakan goniometer
    POTdata = (74.155*POTdata) - 1.6953;
    % Hilangkan noise pengukuran
    POTdata = circshift(POTdata, -4000);
    POTdata = limitSudut(POTdata, 0);
    % POTdataNorm = sudutNorm(POTdata, 0, 100);

    % Cari nilai threshold untuk ekstraksi fitur Zero Crossing
    % Threshold data sinyal EMG didapatkan dengan:
    % TH = 4 * (1/N * sum(EMG(1:N)), lihat: Toledo-Pérez et.al (2016)
    % dimana N merupakan jumlah sampel sinyal EMG dalam keadaan relaksasi
    TH(k) = 4 * (sum(EMG(1:1000)) / 1000);

    % Gabung dalam satu variabel placeholder (dataPH)
    dataPHraw{k} = [POTdata EMG];
    % dataPHfilter{k} = [POTdataNorm EMG];

    fprintf(repmat(char(8), [1 m]));
end

% Buka data dan jadikan satu variabel
dataCombRaw = cat(1, dataPHraw{:});    
dataCombFilter = cat(1, dataPHfilter{:});
% Data sudut potensiometer raw
POTdata = dataCombRaw(:,1);       
% POTdata = dataCombFilter(:,1);
% Data sinyal EMG raw
EMGdata = dataCombRaw(:,2);
% EMGdata = dataCombFilter(:,2);
% lenData = (1:length(POTdata))';
fs = 10000;
lenData = (1/fs:1/fs:20)';

fprintf("Data preparation finished   \x2713\n");

plotFigure(lenData, [], POTdata, EMGdata, 'Data Raw Sudut dan EMG', ...
    'Sudut', 'Raw EMG')

% save newrawDataset.mat dataCombRaw
% save newrawDatasetFilt.mat dataCombFilter
% save newDatasetNorm.mat dataCombFilter

clearVar()

%% Olah sudut dan sinyal EMG
disp("Data preprocessing in progress...");

% Filter sinyal EMG dengan Butterworth IIR Filter
% Bandpass filter orde 4 dengan rentang frekuensi 10Hz - 450 Hz
% Biasanya sinyal EMG yang diambil berada pada rentang 10-20 Hz (high-pass)
% dan pada rentang 450-500 Hz (low-pass)
% Notch Filter orde 2 di frekuensi 50Hz untuk PLI
EMGfilter = dfilter(EMGdata, 'fft');
% EMGfilter = dfilter(EMGdata);
% Note: Gunakan fungsi 'dfilter.m' untuk menjalankan kode diatas

% Olah data sudut dengan moving average untuk smoothing dan
% menghilangkan motion artifacts
POTfilter = movavge(POTdata, 500);
POTfilter = movavge(POTfilter, 500);
t = seconds(linspace(0, 780, length(POTfilter)));
[POTfilter, ~] = filloutliers(POTfilter, 'clip', 'movmedian', ...
        seconds(.1), 'Samplepoints', t);

stDev = std(POTfilter)  %#ok
numData = 200000;
i = 1:numData:length(EMGfilter);
j = numData:numData:length(EMGfilter);
EMGCont = cell(1, 39);
POTCont = cell(1, 39);
for k = 1:numel(i)
    EMGCont{k} = EMGfilter(i(k):j(k));
    POTCont{k} = POTfilter(i(k):j(k));
end

fprintf(repmat(char(8), [1 34]));
fprintf("Data preprocessing finished \x2713\n");

plotFigure(lenData, [], POTfilter, EMGfilter, ...
    'Filtered sudut dan Filtered EMG', 'Filtered sudut', 'Filtered EMG')

plotFigure(lenData, [], EMGdata, EMGfilter, 'Raw EMG dan Filtered EMG', ...
    'Raw EMG', 'Filtered EMG')

plotFigure(lenData, [], POTdata, POTfilter, ...
    'Sudut Raw dan Filtered Sudut', 'Sudut Raw', 'Filtered Sudut', 'true')

clear lenData numData

%% EMG Feature Extraction
disp("Feature extraction in progress...");
[zc, iemg, sudut] = extractVar();

for k = 1:numel(i)
    % Ekstraksi fitur EMG dengan panjang window 50 ms
    % Setiap 0.1 detik data sinyal EMG akan diekstraksi dengan IEMG
    feature = extract(EMGCont{k}, POTCont{k}, TH(k), 50);
    % Note: Gunakan fungsi 'extract.m' untuk menjalankan kode diatas
    zc{k} = feature.zc;                    % Ambil data Zero Crossing EMG
    iemg{k} = feature.iemg;                % Ambil data Integrated EMG
    sudut{k} = feature.sudut;              % Ambil data sudut
end

zcComb = cat(1, zc{:});
iemgComb = cat(1, iemg{:});
sudutComb = cat(1, sudut{:}); 
time = 1:length(sudutComb);
ida = iddata(sudutComb, [zcComb iemgComb], .05);     % Gabung data
ida.InputName = {'Zero Crossing', 'Integrated EMG'}; % Set nama Input
ida.OutputName = {'Sudut'};                          % Set nama output

save extractedData-50.mat ida

fprintf(repmat(char(8), [1 34]));
fprintf("Feature extraction finished \x2713\n");

figure
plot(ida)

plotFigure(time', [], sudutComb, zcComb, 'Sudut dan Zero Crossing', ...
    'Sudut', 'Zero Crossing')

plotFigure(time', [], sudutComb, iemgComb, 'Sudut dan Integrated EMG', ...
    'Sudut', 'Integrated EMG');
yLim = get(gca,'YLim');
set(gca,'YLim', [0 yLim(2)]);

clear feature leg k

disp("All processes are done.");

%% Blok Fungsi
function [TH, dataPHraw, dataPHfilter] = assignVar()
    TH = zeros(39, 1);
    dataPHraw = cell(1, 39);
    dataPHfilter = cell(1, 39);
end
function [zc, iemg, sudut] = extractVar()
    zc = cell(1, 39);
    iemg = cell(1, 39);
    sudut = cell(1, 39);
end
function clearVar()
evalin( 'base', 'clear EMG dirPath dataPHraw dataPHfilter')
evalin('base', 'clear dataCombRaw dataCombFilter matFile k m datasetFile')
end
