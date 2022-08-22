function [Y,Xf,Af] = NARXNN100(X,Xi,Ai)
%NARXNN100 neural network simulation function.
% 
% [Y,Xf,Af] = NARXNN100(X,Xi,Ai):
% 
%   X = 1xTS cell, 1 input dalam TS timesteps
%   Tiap X{1,ts} = 2xQ matrix, input #1 pada timestep ts.
% 
%   Xi = 1x5 cell 1, initial 5 input delay states.
%   Tiap Xi{1,ts} = 2xQ matrix, initial states untuk input #1.
% 
%   Ai = 2x3 cell 2, initial 5 layer delay states.
%   Tiap Ai{1,ts} = 4xQ matrix, initial states untuk layer #1.
%   Tiap Ai{2,ts} = 1xQ matrix, initial states untuk layer #2.
% 
% dan returns:
%   Y = 1xTS cell, 1 output dalam TS timesteps.
%   Tiap Y{1,ts} = 1xQ matrix, output #1 pada timestep ts.
% 
%   Xf = 1x5 cell 1, final 5 input delay states.
%   Tiap Xf{1,ts} = 2xQ matrix, final states untuk input #1.
% 
%   Af = 2x3 cell 2, final 3 layer delay states.
%   Tiap Af{1ts} = 4xQ matrix, final states untuk layer #1.
%   Tiap Af{2ts} = 1xQ matrix, final states untuk layer #2.
% 
% dimana Q merupakan jumlah sampel (atau series) dan TS merupakan
% jumlah timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [0;0.405664767334685];
x1_step1.gain = [0.0666666666666667;0.0163434676693432];
x1_step1.ymin = -1;

% Layer 1
b1 = [1.155431050505508761;2.1957368482021530909; ...
    0.38855914771777805283;0.29173600817609351976];
IW1_1 = [-0.22929322497998860797 -0.21673987834363489524 ...
    0.71501683575506835844 -0.70350923568587508949 ...
    0.25247116374316164178 0.14891459981764126885 ...
    0.15344094060453145056 -0.98937830628940992561 ...
    0.16643175884647626317 -0.10949425719222050102; ...
    1.7063007182184752875 0.93210203982222195052 ...
    0.93283665125766079829 0.64074663359318273503 ...
    0.2338898597685944436 -0.013426093626393789324 ...
    -0.26470144426044833752 -0.68315658341946750021 ...
    -0.22925134781536932183 -0.097969728812312917299; ...
    0.23437065558304454038 1.1526864870773647631 ...
    0.3421908892700625815 -0.029632646985417985391 ...
    0.10661872706119394916 -0.30934635075432831419 ...
    -0.43294827327096885305 0.12888450882465710134 ...
    -0.36193570986381906618 -0.15655332559854046037; ...
    0.9439476250836569271 1.628765124662251873 ...
    -0.15571682726666286056 -0.55909269844857656384 ...
    -0.52713511664188716921 -0.58569557815374695409 ...
    -0.01781231603541005154 0.1943818356137941572 ...
    \-0.27747486743610683124 -0.25471040690437379839];
LW1_2 = [-0.19883312624903062837 0.017593959979041784436 ...
    -0.2183930431049820875;0.10444796376483445055 ...
    -0.079437119261430141903 0.62367704214963448628; ...
    -0.80262435936065568143 0.12154691050100771554 ...
    -0.11251831276989029962;0.61083267169519028794 ...
    1.1250364250555970891 -1.2214259240671092588];

% Layer 2
b2 = 0.32523390344186031697;
LW2_1 = [-0.47135478995305440941 0.099409921946719131958 ...
    -0.59024402449983337515 0.81601510354806072733];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 0.0197871553594986;
y1_step1.xoffset = 0;

% ===== SIMULATION ========

% Format Input Arguments
isCellX = iscell(X);
if ~isCellX
  X = {X};
end
if (nargin < 2), error('Initial input states Xi argument needed.'); end
if (nargin < 3), error('Initial input states Ai argument needed.'); end

% Dimensions
TS = size(X,2); % timesteps
if ~isempty(X)
  Q = size(X{1},2); % samples/series
elseif ~isempty(Xi)
  Q = size(Xi{1},2);
elseif ~isempty(Ai)
  Q = size(Ai{1},2);
else
  Q = 0;
end
if isempty(Xi)
  Xi=cell(1,5);
  Xi(1,:) = {zeros(2,Q)};
end
if isempty(Ai)
  Ai=cell(2,3);
  Ai(1,:) = {zeros(4,Q)};
  Ai(2,:) = {zeros(1,Q)};
end

% Input 1 Delay States
Xd1 = cell(1,6);
for ts=1:5
    Xd1{ts} = mapminmax_apply(Xi{1,ts},x1_step1);
end

% Layer Delay States
Ad1 = [Ai(1,:) cell(1,1)];
Ad2 = [Ai(2,:) cell(1,1)];

% Allocate Outputs
Y = cell(1,TS);

% Time loop
for ts=1:TS

      % Rotating delay state position
      xdts = mod(ts+4,6)+1;
      adts = mod(ts+2,4)+1;
    
    % Input 1
    Xd1{xdts} = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    tapdelay1 = cat(1,Xd1{mod(xdts-[1 2 3 4 5]-1,6)+1});
    tapdelay2 = cat(1,Ad2{mod(adts-[1 2 3]-1,4)+1});
    Ad1{adts} = tansig_apply(repmat(b1,1,Q) + IW1_1*tapdelay1 + LW1_2*tapdelay2);
    
    % Layer 2
    tapdelay1 = cat(1,Ad1{mod(adts-0-1,4)+1});
    Ad2{adts} = repmat(b2,1,Q) + LW2_1*tapdelay1;
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(Ad2{adts},y1_step1);
end

% Final Delay States
finalxts = TS+(1: 5);
xits = finalxts(finalxts<=5);
xts = finalxts(finalxts>5)-5;
finalats = TS+(1: 3);
ats = mod(finalats-1,4)+1;
Xf = [Xi(:,xits) X(:,xts)];
Af = cell(2,3);
Af(1,:) = Ad1(:,ats);
Af(2,:) = Ad2(:,ats);

% Format Output Arguments
if ~isCellX
  Y = cell2mat(Y);
end
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Sigmoid Symmetric Transfer Function
function a = tansig_apply(n,~)
  a = 2 ./ (1 + exp(-2*n)) - 1;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end
