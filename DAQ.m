clear; clc;

%% Global variable

t = 20.00;                       % Time
rate = 10000;                    % Rate

%% Akuisisi data EMG Real-time

s = daq.createSession('ni');                       % Inisialisasi device
addAnalogInputChannel(s,'myDAQ2', 0:1, 'Voltage'); % Set AI channel
s.Rate = rate;                                     % Set rate sinyal
s.DurationInSeconds = t;                           % Set waktu plotting
lh = addlistener(s,'DataAvailable', @collectData); % Akuisisi data
tic
    [data, timestamps] = startForeground(s);       % Mulai plotting
toc

%% Olah dan Plot Data

data_vol = [timestamps data];
potdeg = data(:,1);         
figure(2)
plot(timestamps, potdeg)
% Data EMG
figure(3)
plot(timestamps, data(:,2))
% Gabung data menjadi satu dataset
data_combined = [potdeg data(:,2)];
dataset = [timestamps data_combined];

%% Ganti nama setiap ambil data (Eg. dataset01.mat, dataset02.mat, dst...)
save rawdatavol1.mat data_vol
save rawdataset1.mat dataset

%% Fungsi Akuisisi Data
function collectData(s,event)                        
    time = event.TimeStamps;            % Data waktu
    data = event.Data;                  % Data sinyal
    % Plot sinyal secara real-time
    animatedline(time, data(:,1), 'Color', 'b');     
    animatedline(time, data(:,2), 'Color', 'r');
    xlabel('Time (s)');
    ylabel('Amplitude (V)');
end
