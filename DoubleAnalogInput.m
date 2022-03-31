clear; clc;

%% Global variable

t = 20;                       % Time
rate = 1000;                     % Rate

%% Acquire EMG Data

s = daq.createSession('ni');
ana = addAnalogInputChannel(s, 'myDAQ1', 0:1, 'Voltage');
s.Rate = rate;
s.DurationInSeconds = t;
tic
    [data, timestamps] = startForeground(s);
toc

%%
dataset = [timestamps, data];
plot(timestamps, data)
