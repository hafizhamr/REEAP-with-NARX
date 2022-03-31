clear; clc;

%% Global variable

encoderCPR = 2048;              % Encoder quadrature cycle
t = 20;                         % Time
rate = 100;                     % Rate

%% Acquire Encoder Data

e = daq('ni');                                      % Create Session
addinput(e, 'myDAQ1', 'ctr0', 'Position');
s = daq('ni'); 
addinput(s,'myDAQ1', 'ai0', 'Voltage'); 

%ch1 = addinput(s, 'myDAQ1', 'ctr0', 'Position');    % Add input Channel
%ch1.EncoderType = 'X2';                             % Encoding Type

% Read encoder data and convert to degree
for i=1:t*rate
    encoderPosition(i) = read(e, 1, 'OutputFormat', 'Matrix')
    EMGdata(i) = read(s, 1, 'OutputFormat', 'Matrix');
end

%%
encoderPositionDeg = encoderPosition * 360/encoderCPR;
%encoderPositionDeg = encoderPositionDeg';

%% Acquire EMG Data

% s = daq.createSession('ni'); 
% addAnalogInputChannel(s,'myDAQ1', 'ai0', 'Voltage'); 
% s.Rate = 100; 
% s.inputSingleScan;
% s.DurationInSeconds = t; 
% [EMGdata, time] = s.startForeground; 

%%
% load('dataEMG01.mat', 'timedata')
% time = timedata(1);
% EMG_data = timedata(2);

%% Normalize Data
%dataset = [time, EMG_data, encoderPositionDeg]
EMGdata_norm = normalize(EMGdata, 'range');
encoderPositionDeg_norm = normalize(encoderPositionDeg, 'range');

%% Plot Data
%plot(time, EMGdata); 
time = [1:t*rate];
%plot(time, encoderPositionDeg_norm, time, EMGdata_norm);
%plot(time, encoderPositionDeg);
plot(time, EMGdata_norm);

xlabel('Time (s)');
ylabel('Angular position (deg.)');
yyaxis right
ylabel('Voltage');

%% Save Data
% save_path = 'D:\Kuliah\Semester 8\Skripsi\Dataset';
% filename = 'data02.mat';
% save(fullfile(save_path, filename), 'dataset')


%% Acquire EMG Data

% s = daq('ni');
% addinput(s,'myDAQ1', 'ai0', 'Voltage');
% s.Rate = 1000;
% s.ScansAvailableFcn = @(src,evt) plotDataAvailable(src, evt);
% s.ScansAvailableFcnCount = 1000;
% start(s, "continuous");
% 
% function plotDataAvailable(src, ~)
%     [EMGdata, timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
%     plot(timestamps, EMGdata); 
%     timedata = [timestamps EMGdata];
%     save dataEMG01.mat timedata
%     t = 20;
%     if (timestamps >= t-1)
%         src.stop()
%     end
% end
