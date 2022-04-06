clear; clc;

%% Global variable

t = 20;                       % Time
rate = 1000;                  % Rate

%% Acquire EMG Data

s = daq.createSession('ni');
ana = addAnalogInputChannel(s, 'myDAQ1', 0:1, 'Voltage');
s.Rate = rate;
s.DurationInSeconds = t;
lh = addlistener(s,'DataAvailable', @collectData);
tic
    [data, timestamps] = startForeground(s);
toc
dataset = [timestamps data];
save dataEMG01.mat dataset

function collectData(s,event)                   
    time = event.TimeStamps;                        
    data = event.Data;                             
    animatedline(time, data(:,1));                  
    animatedline(time, data(:,2));
    xlabel('Time (s)');
    ylabel('Amplitude (V)');
end
