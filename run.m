clear; clc; close all;

startProgram()

% Process data
prompt = 'Process data? Y/N: ';
x = input(prompt, 's');
calcNumel(prompt, x)
if (numel(x) == 1 || isempty(x))
    if isempty(x)
        x = 'N';
        ignoreProc(n, m)
        return
    elseif (x == 'Y' || x == 'y')
        fprintf(repmat(char(8), [1 1+n+m]));
        DatasetPreparation
        fprintf('\n')
    else
        ignoreProc(n, m)
        return
    end
else
    ignoreProc(n, m)
    return
end

% Train model NARX
prompt = 'Train NARX model from extracted data? Y/N: ';
x = input(prompt, 's');
calcNumel(prompt, x)
if (numel(x) == 1 || isempty(x))
    if isempty(x)
        x = 'N';
        ignoreTrain(n, m)
        return
    elseif (x == 'Y' || x == 'y')
        fprintf(repmat(char(8), [1 1+n+m]));
        disp('NARX training starting...')
        NARXgen
    else
        ignoreTrain(n, m)
        return
    end
else
    ignoreTrain(n, m)
    return
end

% Real-time Prediction
while 1
    prompt = 'Start real-time prediction? Y/N: ';
    x = input(prompt, 's');
    calcNumel(prompt, x)
    if (numel(x) == 1 || isempty(x))
        if isempty(x)
            x = 'N';
            ignorePred(n,  m)
            break
        elseif (x == 'Y' || x == 'y')
            fprintf(repmat(char(8), [1 1+n+m]));
            RealTimePrediction
        else
            ignorePred(n, m)
            break
        end
    else
        ignorePred(n, m)
        break
    end
end

function calcNumel(prompt,x)
    n = numel(sprintf(prompt));
    m = numel(sprintf(x));
    assignin('base', "n", n)
    assignin('base', "m", m)
end
function ignoreProc(n,m)
    fprintf(repmat(char(8), [1 1+n+m]));
    fprintf('Cancelled.\n')
    evalin( 'base', 'clear m n x prompt')
    endProgram()
end
function ignoreTrain(n,m)
    fprintf(repmat(char(8), [1 1+n+m]));
    fprintf('Training cancelled.\n')
    evalin( 'base', 'clear m n x prompt')
    endProgram()
end
function ignorePred(n,m)
    fprintf(repmat(char(8), [1 1+n+m]));
    fprintf('Prediction cancelled.\n')
    evalin( 'base', 'clear m n x prompt')
    endProgram()
end
function startProgram()
    disp("   _____________   ___  ___________  _______    ")      
    disp("  / __/_  __/ _ | / _ \/_  __/  _/ |/ / ___/    ")       
    disp(" _\ \  / / / __ |/ , _/ / / _/ //    / (_ / _ _ ")
    disp("/___/ /_/ /_/ |_/_/|_| /_/ /___/_/|_/\___(_|_|_)")
    fprintf("\n")
    disp("Real-time Estimation of Elbow Angular Position using ")
    fprintf("EMG Signal with NARX Model (2022).\n\n")
    fprintf("Created by Muhammad Amrul Muhafizh\n\n")
end
function endProgram()
    disp("  _______                __")      
    disp(" / ___/ /__  ___ ___ ___/ /")       
    disp("/ /__/ / _ \(_-</ -_) _  / ")
    disp("\___/_/\___/___/\__/\_,_(_)")
    fprintf("\n")
end