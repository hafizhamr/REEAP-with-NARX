clear; clc; close all hidden;

%% Load dataset ke dalam workspace
%   EMGdata - input time series.
%   POTdata - feedback time series.

data = load('extractedData.mat');
POTdata = data.ida.OutputData;
EMGdata = data.ida.InputData;

% plotFigure(1:length(POTdata), [], POTdata, EMGdata, ...
%     'Data Sudut dan Sinyal EMG', 'Sudut', 'Sinyal EMG')

%% Konversi data ke bentuk standard neural network cell array
% [y,wasMatrix] = tonndata(x,columnSamples,cellTime)
% x             : data yang ingin dikonversi
% columnSamples : True jika orientasinya kolom, false jika baris
% cellTime      : True jika bentuk cell array, false jika bentuk matrix
X = tonndata(EMGdata,false,false);
T = tonndata(POTdata,false,false);

%% Buat model Nonlinear Autoregressive Network with External Input
% Parameter maksimal network yang ingin digunakan
hiddenLayer = 10;    % Buat network dengan 1-10 hidden layer
inputDelay = 5;      % Buat network dengan 1-5 input delay
feedbackDelay = 5;   % Buat network dengan 1-5 feedback delay
netAll = cell(1, hiddenLayer*inputDelay*feedbackDelay)';
NN = 1;

% Pilih fungsi algoritma training
% Levenberg-Marquardt algorithm + Bayesian reqularization
% Bayesian reqularization digunakan untuk meningkatkan kemampuan
% model dalam generalisasi dan meminimalkan kemungkinan untuk overfitting
% Hal ini dilakukan karena dataset yang digunakan tidak terlalu besar
% Penggunaan fungsi 'trainbr' memungkinkan model untuk menentukan
% parameter regularisasi yang optimal secara otomatis
trainFcn = 'trainlm';

%% Training model Nonlinear Autoregressive Network with External Input
for hiddenLayerSize = 1:hiddenLayer
    for ID = 1:inputDelay
        for FD = 1:feedbackDelay
            net = narxnet(1:ID, 1:FD, hiddenLayerSize,'open',trainFcn);

            net.name = sprintf("Hidden-%d, ID-%d, FD-%d", ...
                    hiddenLayerSize,ID,FD);
                
            % Input dan Feedback Pre/Post-Processing Functions
            % Fungsi ini digunakan untuk normalisasi dan denormalisasi
            % data saat melakukan training
            % Fungsi 'mapminmax' menormalisasi input/target dalam 
            % rentang [-1, 1]
            net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
            net.inputs{2}.processFcns = {'removeconstantrows','mapminmax'};
            
            % Siapkan data untuk training dan simulasi
            [x,xi,ai,t] = preparets(net,X,{},T);
            
            %% Bagi dataset ke data untuk Training, Validation, dan Testing
            net.divideFcn = 'divideblock';  % Bagi data ke dalam blok data
            net.divideMode = 'time';        % Bagi data setiap sampel
            net.divideParam.trainRatio = 60/100;    % Training data 60%
            net.divideParam.valRatio = 20/100;      % Validation data 20%
            net.divideParam.testRatio = 20/100;     % Testing data 20%
            
            %% Parameter early stopping untuk meningkatkan generalisasi
            net.trainParam.epochs = 1000; % Maksimum epoch
            net.trainParam.mu = 1;        % Nilai mu awal
            net.trainParam.mu_dec = 0.5;
            net.trainParam.mu_inc = 1.5;
            net.trainParam.goal = .0001;
            %net.trainParam.max_fail = 10;  % Gagal validasi maksimum
            
            %% Performance Function
            % Opsi: help nnperformance
            net.performFcn = 'mse';  % Mean Squared Error
            % Regularisasi (untuk fungsi training 'trainlm')
            % net.performParam.regularization = 0.5;
            
            %% Plot Functions
            % Opsi: help nnplot
            net.plotFcns = {'plotperform', 'plottrainstate', ...
                'ploterrhist', 'plotregression', 'plotresponse', ...
                'ploterrcorr', 'plotinerrcorr'};
            
            %% Train the Network
            % Gunakan blok kode berikut untuk training, test, dan untuk
            % mengetahui dan mengevaluasi network dengan parameter yang 
            % memiliki performa terbaik. 
            % Ganti (false) => (true) untuk menggunakan kode dibawah
            % Note: Sebelum digunakan, ganti nilai hiddenLayerSize, 
            %       input delay, dan feedback delay pada perulangan 
            %       sesuai dengan parameter yang diinginkan.
            if (false)
                % Masukkan parameter hiddenLayerSize, input delay, dan
                % feedback delay network yang diinginkan
                if (hiddenLayerSize == 6) && (ID == 2) && (FD == 5)
                    numNN = 10;    % Jumlah network yang ingin ditraining
                    numCL = 20;
                    predTotal = zeros(size(t));
                    netM = cell(1, numNN);
                    perfs = zeros(1, numNN);
                    pred = cell(1, numNN);
                    
                    % Train the network
                    for i = 1:numNN
                        m = numel(sprintf('Training %d/%d\n', i, numNN));
                        fprintf('Training %d/%d\n', i, numNN);
                        netM{i} = train(net,x,t,xi,ai);
                        fprintf(repmat(char(8), [1 m]));
                    end
                    
                    % Test the network
                    for i = 1:numNN
                        neti = netM{i};
                        [pred{i},~,~] = neti(x,xi,ai);
                        % perfs(i) = perform(neti, t, pred{i}); % MSE
                        predCont = pred{i};
                        perfs(i) = sqrt(goodnessOfFit([predCont{:}]', ...
                            [t{:}]','MSE'));                    % MSE
                        preds = cell2mat(pred{i});
                        predTotal = predTotal + preds;
                    end
                   
                    % Hitung performa network rata-rata
                    predAverage = num2cell(predTotal / numNN);
                    perfAverage = perform(netM{1}, t, ...
                        predAverage);
                    netw = [netM; num2cell(perfs)]';
                    avgRMSE = sqrt(goodnessOfFit([predAverage{:}]', ...
                        [t{:}]','MSE'));
                    NRMSE = goodnessOfFit([predAverage{:}]', ...
                        [t{:}]','NMSE');
                    disp("Performance result of the Open-loop" + ...
                        " network...");
                    fprintf("Hidden-%d, ID-%d, FD-%d \n", ...
                        hiddenLayerSize,ID,FD);
                    disp(perfs);
                    fprintf("Average RMSE: %.4f \n\n", avgRMSE);
                    fprintf("Average NRMSE: %.4f \n\n", NRMSE);
                    
                    save net-200.mat netw

                    clear m n i
                end
                
                perfIndex = find(perfs > 0);
                [~, index] = min(perfs(perfIndex)); %#ok<FNDSB>
                fprintf("Best Open-loop Network is " + ...
                        "Network %d with RMSE: %.4f \n\n", ...
                        index, perfs(index));
                
                pred = cell2mat(pred{index});
                % Gunakan kode berikut untuk membatasi output prediksi
                % network closed-loop dari model
                if (true)
                    % limitSudut(sudut,lower,upper)
                    pred = limitSudut(pred,0);
                end
                
                lenData = (1:length(pred))';
                plotFigure(lenData, [], pred, cell2mat(t), ...
                    'Hasil Uji Network Open-loop', ...
                    'Predicted Angle', 'Measured Angle', 'true')
                
                % Ubah network ke dalam bentuk closed-loop
                % load('netAll.mat')
                % netcl = closeloop(netAll{});
                netcl = closeloop(netM{index});
                % Train closed-loop network dengan data yang sama dengan
                % open-loop network
                netcl.inputs{1}.processFcns = {'removeconstantrows', ...
                    'mapminmax'};
                netcl.performFcn = 'mse';
                % Bagi data setiap sampel dalam tiga blok data
                [Xcs, Xci, Aci, Tcs] = preparets(netcl,X,{},T);
                netcl.divideFcn = 'divideblock';
                netcl.divideMode = 'time';        
                netcl.divideParam.trainRatio = 60/100;% Training data 60%
                netcl.divideParam.valRatio = 20/100;  % Validation data 20%
                netcl.divideParam.testRatio = 20/100; % Testing data 20%
                
                netCL = cell(numCL, 1);
                perfs = zeros(1, numCL);
                for i = 1:numCL
                    m = numel(sprintf('Training %d/%d\n', i, numCL));
                    fprintf('Training %d/%d\n', i, numCL);
                    netCL{i} = train(netcl,Xcs,Tcs,Xci,Aci);
                    fprintf(repmat(char(8), [1 m]));
                end
                
                for i = 1:numCL
                    neti = netCL{i};
                    pred = neti(Xcs,Xci,Aci);
                    perfs(i) = perform(neti, Tcs, pred);
                    perfs(i) = sqrt(goodnessOfFit([pred{:}]', ...
                        [Tcs{:}]','MSE'));
                end
                disp("Performance result of the Closed-loop network...");
                disp(perfs);
                perfIndex = find(perfs > 0);
                [~, index] = min(perfs(perfIndex));
                fprintf("Best Close-loop Network is " + ...
                    "Network %d \n\n", index);
                
                % Test closed-loop network 
                bestnetCL = netCL{index};
                yPred = bestnetCL(Xcs,Xci,Aci);
                yPred = cell2mat(yPred);
                
                % Gunakan kode berikut untuk membatasi output prediksi
                % network closed-loop dari model
                if (true)
                    % limitSudut(sudut,lower,upper)
                    yPred = limitSudut(yPred,0);
                end
                
                yPred = num2cell(yPred);
                e = gsubtract(Tcs,yPred);
                [R,~,~] = regression(Tcs,yPred);
                clPerf = sqrt(goodnessOfFit([yPred{:}]',[Tcs{:}]','MSE'));
                NRMSEcl = goodnessOfFit([yPred{:}]', ...
                        [Tcs{:}]','NRMSE');
                fprintf("Closed-loop RMSE: %.4f \n\n", clPerf);
                fprintf("Closed-loop NRMSE: %.4f \n\n", NRMSEcl);
                
                lenData = (1:length(cell2mat(yPred)))';
                plotFigure(lenData, [], cell2mat(yPred), cell2mat(Tcs), ...
                    'Hasil Uji Network Closed-loop', ...
                    'Predicted Angle', 'Measured Angle', 'true')
                
                % save FD-200.mat Aci
                % save ID-200.mat Xci
                % save netCL-200.mat netCL index clPerf NRMSEcl R
                % save bestnetCL-200.mat bestnetCL
                
                % genFunction(bestnetCL,'NARXNN200'); 
                
                clear perfIndex lenData
                if (hiddenLayerSize == hiddenLayer) && ...
                        (ID == inputDelay) && (FD == feedbackDelay)
                    fprintf('Training finished.\n\n')
                    % sound(sin(1:3000));
                    break
                end
            end

            %%
            % Train the network
            [net, tr] = train(net,x,t,xi,ai);
            
            % Test the Network
            y = net(x,xi,ai);
            e = gsubtract(t,y);
            performance = sqrt(goodnessOfFit([y{:}]',[t{:}]','MSE'));
            %view(net)
            
            %% Hitung performa Training, Validation dan Test
            trainTargets = gmultiply(t,tr.trainMask);
            valTargets = gmultiply(t,tr.valMask);
            testTargets = gmultiply(t,tr.testMask);
            trainPerformance = sqrt(goodnessOfFit([y{:}]', ...
                [trainTargets{:}]','MSE'));
            valPerformance = sqrt(goodnessOfFit([y{:}]', ...
                [valTargets{:}]','MSE'));
            testPerformance = sqrt(goodnessOfFit([y{:}]', ...
                [testTargets{:}]','MSE'));
            
            %% Hitung nilai performa (NRMSE dan regresi)
            % Nilai NRMSE
            % 0 => Perfect fit to reference data (zero error)
            % -Inf => Bad fit
            % 1 => x is no better than a straight line at matching xref
            % goodnessOfFit(yout,yref,'MSE;NMSE;NRMSE');
            NRMSE = goodnessOfFit([y{:}]',[t{:}]','NRMSE');
            % Nilai regresi
            [R,~,~] = regression(t,y);
            
            %% Plots
            %figure, plotperform(tr)
            %figure, plottrainstate(tr)
            %figure, ploterrhist(e)
            %figure, plotregression(t,y)
            %figure, plotresponse(t,y)
            %figure, ploterrcorr(e)
            %figure, plotinerrcorr(x,e)
            
            %% Closed Loop Network
            % Untuk multi-step prediction.
            % Fungsi CLOSELOOP  mengganti feedback input dengan
            % koneksi langsung output layer.
            netc = closeloop(net);
            netc.name = [net.name ' - Closed Loop'];
            % view(netc)
            [xc,xic,aic,tc] = preparets(netc,X,{},T);
            yc = netc(xc,xic,aic);
            closedLoopPerformance = sqrt(goodnessOfFit([yc{:}]', ...
                [tc{:}]','MSE'));
            
%             figure
%             plot(cell2mat(yc))
%             hold on
%             plot(cell2mat(tc))

            %% Simulasi Multi-step Prediction
            % Simulasi network dalam bentuk open-loop selama terdapat data
            % output yang diketahui dan berganti ke bentuk closed-loop
            % untuk melakukan multistep prediction dengan external input.
            
            % Semua kecuali 5 timestep dari input series dan target series
            % digunakan untuk mensimulasi network dalam bentuk open-loop
            numTimesteps = size(x,2);
            knownOutput = (numTimesteps-5):numTimesteps;
            predictOutput = 1:(numTimesteps-4);
            X1 = X(:,knownOutput);
            T1 = T(:,knownOutput);
            [x1,xio,aio] = preparets(net,X1,{},T1);
            [y1,xfo,afo] = net(x1,xio,aio);
            % Selanjutnya network dikonversi ke dalam bentuk closed-loop
            % untuk membuat lima prediksi hanya dengan lima input
            x2 = X(1,predictOutput);
            [netcl,xicl,aicl] = closeloop(net,xfo,afo);
            [pred,xfc,afc] = netcl(x2,xicl,aicl);
            multiStepPerformance = sqrt(perform(net, ...
                T(1,predictOutput),pred));
            
%             disp(multiStepPerformance)
%             len = 1:length(pred);
%             plotFigure(len, [], cell2mat(pred), ...
%                 cell2mat(T(1,predictOutput)), ...
%                 'Hasil Estimasi Sudut dan Sudut Sebenarnya', ...
%                 'Estimasi Model', 'Sudut Sebenarnya', 'true')
            
            %% Step-Ahead Prediction Network
            % Original network memberikan prediksi y(t+1) disaat yang sama
            % ketika diberi y(t+1). Untuk memprediksi y(t+1) saat y(t),
            % ketika sebelum y(t+1) muncul, network bisa dibuat untuk
            % memberikan outputnya lebih awal dengan menghapus delay
            % sehingga tap delay minimalnya 0 (tidak lagi 1). Network
            % akan memberikan output yang sama dengan Original network,
            % tapi outputnya digeser satu timestep.
            nets = removedelay(net);
            nets.name = [net.name ' - Predict One Step Ahead'];
            % view(nets)
            [xs,xis,ais,ts] = preparets(nets,X,{},T);
            ys = nets(xs,xis,ais);
            stepAheadPerformance = sqrt(goodnessOfFit([ys{:}]', ...
                [ts{:}]','MSE'));
            
%             figure
%             plot(cell2mat(ys))
%             hold on
%             plot(cell2mat(ts))
            
            %% Simpan network
            netAll{NN} = net;
            NN = NN + 1;
            
            % Simpan hasil performa model
            filename = "Performance Result\" + ...
                "performance-50.xlsx";
            disp("Saving performance result of the network...");
            fprintf("Hidden-%d, ID-%d, FD-%d \n", hiddenLayerSize,ID,FD);
            writematrix ([hiddenLayerSize ID FD tr.num_epochs ...
                performance R NRMSE trainPerformance valPerformance ...
                testPerformance closedLoopPerformance ...
                multiStepPerformance stepAheadPerformance'], ...
                filename, 'WriteMode', 'append');
            fprintf("RMSE: %.4f \n", performance);
            fprintf("Done. \n\n");
        end
    end
end

clearVar()

save netAll-50-2.mat netAll

% sound(sin(1:3000));

%% Deployment
% Ganti (false) => (true) untuk menggunakan kode dibawah
if (false)
    % Generate MATLAB function
    % genFunction(net,'NNFcn'); 
    % Generate matrix-only MATLAB function
    % genFunction(net,'NNFcn','MatrixOnly','yes');
    % Generate model dalam Simulink diagram
    % gensim(net);
end

%% Blok Fungsi
function clearVar()
    evalin( 'base', 'clear FD ID NN numTimesteps hiddenLayer')
    evalin('base', 'clear feedbackDelays inputDelays')
    evalin('base', 'clear filename predictOutput knownOutput')
end