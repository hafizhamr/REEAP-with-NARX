clear; clc;

%% Global variable

t = 20.00;                       % Time
rate = 1000;                     % Rate
V_ref = 5;                       % Tegangan masukan/ref
fullDeg = 360;                   % Sudut maksimum potensiometer

%% Akuisisi data EMG Real-time

s = daq.createSession('ni');                         % Inisialisasi device
addAnalogInputChannel(s,'myDAQ1', 0:1, 'Voltage');   % Set AI channel device
s.Rate = rate;                                       % Set rate sinyal
s.DurationInSeconds = t;                             % Set waktu plotting
lh = addlistener(s,'DataAvailable', @collectData);   % Ambil data dari devices
tic
    [data, timestamps] = startForeground(s);         % Start plotting
toc

%% Olah dan Plot Data

data_vol = [timestamps data];
potdeg = (data(:,1) * fullDeg) / V_ref;              % Data sudut potensiometer
figure(2)
plot(timestamps, potdeg)
figure(3)
plot(timestamps, data(:,2))                          % Data EMG
data_combined = [potdeg data(:,2)];
dataset = [timestamps data_combined];

%% Ganti nama setiap ambil data (Eg. dataset01.mat, dataset02.mat, dst...)
save datavol01.mat data_vol
save dataset01.mat dataset

%% Fungsi Akuisisi Data
function collectData(s,event)                        
    time = event.TimeStamps;                         % Data waktu
    data = event.Data;                               % Data sinyal
    animatedline(time, data(:,1), 'Color', 'b');     % Sinyal real-time
    animatedline(time, data(:,2), 'Color', 'r');
    xlabel('Time (s)');
    ylabel('Amplitude (V)');
end