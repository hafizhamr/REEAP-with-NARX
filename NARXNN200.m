function [Y,Xf,Af] = NARXNN200(X,Xi,Ai)
%NARXNN200 neural network simulation function.
% 
% [Y,Xf,Af] = NARXNN200(X,Xi,Ai):
% 
%   X = 1xTS cell, 1 input dalam TS timesteps
%   Tiap X{1,ts} = 2xQ matrix, input #1 pada timestep ts.
% 
%   Xi = 1x2 cell 1, initial 2 input delay states.
%   Tiap Xi{1,ts} = 2xQ matrix, initial states untuk input #1.
% 
%   Ai = 2x5 cell 2, initial 2 layer delay states.
%   Tiap Ai{1,ts} = 6xQ matrix, initial states untuk layer #1.
%   Tiap Ai{2,ts} = 1xQ matrix, initial states untuk layer #2.
% 
% dan returns:
%   Y = 1xTS cell, 1 output dalam TS timesteps.
%   Tiap Y{1,ts} = 1xQ matrix, output #1 pada timestep ts.
% 
%   Xf = 1x2 cell 1, final 2 input delay states.
%   Tiap Xf{1,ts} = 2xQ matrix, final states untuk input #1.
% 
%   Af = 2x5 cell 2, final 5 layer delay states.
%   Tiap Af{1ts} = 6xQ matrix, final states untuk layer #1.
%   Tiap Af{2ts} = 1xQ matrix, final states untuk layer #2.
% 
% dimana Q merupakan jumlah sampel (atau series) dan TS merupakan
% jumlah timesteps.

%#ok<*RPMT0>

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = [0;0.936199866611256];
x1_step1.gain = [0.032258064516129;0.010793652410778];
x1_step1.ymin = -1;

% Layer 1
b1 = [-5.9391865342394449812;3.2215825875187338312;0.095262755818345715153;-1.1342536508286646946;2.3417332487302706667;-0.78178440179330177529];
IW1_1 = [1.2753854199662253421 -7.9652625600915998305 0.83626808823942133664 1.8966112356692237384;0.068097103485856624872 5.9072955148765018407 1.0261359572279706853 -2.4368024967642232248;0.34719859666285673994 0.027978809259311752944 0.57087414735118879872 0.47550147141669790729;-0.97203289382065249935 -1.9648987453294366468 0.70045308122797822481 0.53343120938836618983;0.016444800154338676257 1.6223664867667657585 -1.0824024307785580223 1.4107830487230608174;0.20350029266073352274 -1.2556464812926420027 0.32873501575220348547 0.97732698593086964056];
LW1_2 = [-1.0264797147221564888 0.78120201804751554508 0.80166524716436660114 -0.96672593503449621988 -0.7896215003859685666;0.10320076482350167002 -0.086707242556777419651 2.2727352391600557091 -2.3532895812122429646 -0.30261279374374872031;-0.12713933770107030408 -0.9454002824967460139 0.7136820903480871614 -0.61764471271174603562 0.92126123698097628356;-0.94083403171051149805 0.21361845139508800484 0.26367731696083440696 1.008693764211438415 -0.85198927882524488897;-0.43604457447585098784 0.47727247521024090959 -0.13351961861333697112 -0.83453810718617049691 0.97048807842197515328;-0.12248929966060669028 -0.62727422426455647919 0.57214137862684788516 -0.43210137625829575514 0.69628576931293839625];

% Layer 2
b2 = -0.048092307547292892367;
LW2_1 = [-0.50144354545503622145 0.43908705620719840068 -1.3105573875377694026 -0.71610517260712558407 -0.38268302079508975666 1.7742966707122052039];

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
  Xi=cell(1,2);
  Xi(1,:) = {zeros(2,Q)};
end
if isempty(Ai)
  Ai=cell(2,5);
  Ai(1,:) = {zeros(6,Q)};
  Ai(2,:) = {zeros(1,Q)};
end

% Input 1 Delay States
Xd1 = cell(1,3);
for ts=1:2
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
      xdts = mod(ts+1,3)+1;
      adts = mod(ts+4,6)+1;
    
    % Input 1
    Xd1{xdts} = mapminmax_apply(X{1,ts},x1_step1);
    
    % Layer 1
    tapdelay1 = cat(1,Xd1{mod(xdts-[1 2]-1,3)+1});
    tapdelay2 = cat(1,Ad2{mod(adts-[1 2 3 4 5]-1,6)+1});
    Ad1{adts} = tansig_apply(repmat(b1,1,Q) + IW1_1*tapdelay1 + LW1_2*tapdelay2);
    
    % Layer 2
    tapdelay1 = cat(1,Ad1{mod(adts-0-1,6)+1});
    Ad2{adts} = repmat(b2,1,Q) + LW2_1*tapdelay1;
    
    % Output 1
    Y{1,ts} = mapminmax_reverse(Ad2{adts},y1_step1);
end

% Final Delay States
finalxts = TS+(1: 2);
xits = finalxts(finalxts<=2);
xts = finalxts(finalxts>2)-2;
finalats = TS+(1: 5);
ats = mod(finalats-1,6)+1;
Xf = [Xi(:,xits) X(:,xts)];
Af = cell(2,5);
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
