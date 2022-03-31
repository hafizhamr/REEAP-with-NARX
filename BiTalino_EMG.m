%clear; clc;

%MACIdList = Bitalino.findDevices
% Create the object
b = Bitalino('btspp://98D391FD575B', 100);
% Start background acquisition
b.startBackground;
% Pause to acquire data for 20 seconds
pause(20);
% Read the data from the device
data = b.read;
% Stop background acquisition of data
b.stopBackground;
% Clean up the bitalino object
delete(b)

%%
ECG_raw = data(:,8);
%load('ECG_raw.mat'); % Comment this line to use live data
figure;
plot(ECG_raw);