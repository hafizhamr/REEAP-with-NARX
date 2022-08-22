clear; clc; close all;

%% Kalibrasi Potensiometer
dataFile = load("D:\Kuliah\Semester 8\Skripsi\Source Code\" + ...
    "potensio.mat"); %#ok

d = (5:5:100)';
degM = cell(1, length(d));
for k = 1:length(d)
    deg = eval(sprintf("dataFile.myDAQ2_%ddeg.myDAQ2_ai0", d(k)));
    degM{k} = mean(deg);
end

degM = cat(1, degM{:});   
filename = "Potentiometer Calibration\potcal1.xlsx";
writematrix ([d degM], filename, 'WriteMode', 'append');

linReg = fitlm(degM, d,'linear');
plotAdded(linReg)
title("Hasil Regresi Linier")
xlabel("Tegangan Potensiometer (V)")
ylabel("Sudut (°)")
grid on

T1 = table(linReg.Fitted,'VariableName',{'degM'});
T2 = table(d,'VariableName',{'d'});
error = mean(abs(T1.degM - T2.d));

a = num2str(linReg.Coefficients.Estimate(2));
b = num2str(linReg.Coefficients.Estimate(1));
disp(append('Hasil Regresi Linier = ',a,'*V + ',b))
disp(append('RMSE = ', num2str(linReg.RMSE)));
disp(append('Error = ', num2str(error)));

clear k deg filename T1 T2 dataFile a b