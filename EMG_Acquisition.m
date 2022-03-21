% Akuisisi data EMG Real-time

fid = fopen('dataEMG01.bin', 'w');
s = daq('ni');                                      % Inisialisasi device
addinput(s,'myDAQ1', 0, 'Voltage');                 % Set AI channel device
s.Rate = 1000;                                      % Set rate sinyal
s.DurationInSeconds = 5;                            % Set waktu plotting
lh = addlistener(s,'DataAvailable', @collectData);  % Ambil data dari devices
s.startBackground();                                % Start plotting

%fclose(fileID);

function collectData(s,event)                       % Fungsi ambil data
    time = event.TimeStamps;                        % Waktu
    data = event.Data;                              % Data sinyal
    timedata = [time data];
    save dataEMG01.mat timedata
    h = animatedline(time, data);                   % Tampilkan garis plot sinyal
    xlabel('Time (s)');
    ylabel('Amplitude (V)');

    %fprintf(fileID,time,data);
    %timeanddata = [event.TimeStamps event.Data]';
    %fwrite(fid, timeanddata, 'double');
end
