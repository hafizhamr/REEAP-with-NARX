clear; 

s = daq('ni');
ch1 = addinput(s, 'myDAQ1', 'ctr0', 'Position');

%%
ch1.TerminalA
ch1.TerminalB
ch1.TerminalZ
ch1.EncoderType = 'X2';

%%
encoderCPR = 2048;
t = 500;
time = (1:t)

for i=1:t
    encoderPosition(i) = read(s, 1, 'OutputFormat', 'Matrix');;
    encoderPositionDeg(i) = encoderPosition(i) * 360/encoderCPR
end

plot(time, encoderPositionDeg); 
xlabel('Time (s)');
ylabel('Angular position (deg.)');