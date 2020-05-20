function [ resMatrixOrig, DAS, expTime, dataPred, delta, tzOffset, k_out] = f_GlobalFit( k, data, time, wave, kScaler, delta,  tzOffset, weighting, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global kTrial
global resTrial
global xTrial
global deltaTrial
global tzOffsetTrial
global deltaTrial2
global tzOffsetTrial2

global h_progress
global h_progresSurf

%% Check input varibales
if max(delta) ~= delta(1), delta = [delta(2), delta(1)]; end
if size(delta,2) ~= 2, delta = delta'; end
if max(tzOffset) ~= tzOffset(1), tzOffset = [tzOffset(2), tzOffset(1)]; end
if size(tzOffset,2) ~= 2, tzOffset = tzOffset'; end
if max(kScaler) ~= kScaler(1), kScaler = [kScaler(2), kScaler(1)]; end
if size(kScaler,2) ~= 2, kScaler = kScaler'; end

if size(data,1) ~= size(time,1), data = data'; end
if size(weighting,1) ~= size(time,1), weighting = weighting'; end

%% Sets Options
% default options
opt.deltaThreshold = 0.001*min(abs(delta));
opt.tzOffsetTrial = 0.01*min(abs(tzOffset));
opt.plotProgress = 0;
opt.removeScalers = 1;
opt.nonNegative = 0;
% user input
[opt] = f_OptSet(opt, varargin);

%% Checks if the results for delta and/or tzOffset have been consistnet for 5 trials
if length(delta) > 1 &&...
        length(deltaTrial2) >= 5 &&...
        sum(abs(deltaTrial2(end-4:end) - deltaTrial2(end))) < opt.deltaThreshold
    
    delta = deltaTrial2(end);
else
    if length(deltaTrial2) >= 5
        %sum(abs(deltaTrial2(end-4:end) - deltaTrial2(end))) 
    end
end
if length(delta) > 1 &&...
        length(tzOffsetTrial2) >= 5 &&...
        sum(abs(tzOffsetTrial2(end-4:end) - tzOffsetTrial2(end))) < opt.tzOffsetTrial
    
    tzOffset = tzOffsetTrial2(end);
else
    if length(tzOffsetTrial2) >= 5
        %sum(abs(tzOffsetTrial2(end-4:end) - tzOffsetTrial2(end))) 
    end
end

%% Preallocagte Variables
xTrial = [xTrial; k];

%% Rescales values for fitting
concScaler = [];
[k] = f_FittingScaler(k, kScaler, 0);
k = 10.^k;
scaleFactor = max(max(abs(data)));
data = data./scaleFactor; % data must be between +/- 1

%% Keeps record of k values that have been trialed
if size(kTrial,2) ~= length(k)
    kTrial = k;
else
    kTrial = [kTrial; k];
end

%% Finds best delta and tzOffset
if length(delta) > 1 || length(tzOffset) > 1
    x = [];
    %% adds delta from previous or zero
    if length(delta) > 1
        if ~isempty(deltaTrial2)
            [delt] = f_FittingScaler(deltaTrial2(end), delta, 1);
        else
            delt = 0;
        end
        x = [x, delt];
    end
    %% adds tzOffset from previous or zero
    if length(tzOffset) > 1
        if ~isempty(tzOffsetTrial2)
            [tzO] = f_FittingScaler(tzOffsetTrial2(end), tzOffset, 1);
        else
            tzO = 0;
        end
        x = [x, tzO];
    end
    %% Sets Bounds
    if length(delta) > 1 && length(tzOffset) > 1
        LB = [-0.5; -0.5];
        UB = [0.5; 0.5];
    else
        LB = -0.5;
        UB = 0.5;
    end
    %% Runs fitting
    deltaTrial = [];
    tzOffsetTrial = [];
    x = lsqnonlin(@searchDeltaTzOffset,x,LB,UB,...
        optimset('Algorithm', 'trust-region-reflective', 'FinDiffType', 'central', 'TolFun', 1E-4, 'Display', 'off' ),...
        k, data, time, wave, delta, tzOffset, weighting, concScaler);
    %% Converts from scalled values back to normal
    if length(tzOffset) > 1
        [tzOffset] = f_FittingScaler(x(end), tzOffset, 0);
        x = x(1:end-1);
        tzOffsetTrial2 = [tzOffsetTrial2; tzOffset];
    end
    if length(delta) > 1
        [delta] = f_FittingScaler(x(end), delta, 0);
        deltaTrial2 = [deltaTrial2; delta];
    end   
end

%% Calculates resMatrix (and DAS)if isempty(concScaler)
if isempty(concScaler)
    [ expTime ] = f_ExpConvIRF( time + tzOffset, k, 0, delta );
else
    [ expTime ] = f_ConvConcentrations(time + tzOffset,k,delta,concScaler);
end
expTime = expTime(:,sum(expTime)~=0);
DAS = expTime\data;
DAS = DAS'; %for consistency
if opt.nonNegative
    DAS(DAS < 0) = 0;
end
dataPred = [DAS*expTime']';
resMatrixOrig = data-dataPred;
resMatrix = resMatrixOrig.*weighting;
%% Rescales values
DAS = DAS.*scaleFactor;
dataPred = dataPred.*scaleFactor;
resMatrixOrig = resMatrixOrig.*scaleFactor;
%% Keeps record of residual squared sums
resTrial = [resTrial; sum(sum(resMatrix.^2))];

if opt.plotProgress
    if isempty(h_progress) || ~ishandle(h_progress(end))
        [ h_progress ] = f_MultiLinLogAxes( 2, opt.plotProgress, 'rowStyles', [{'Linear'};'Linear';'Linear']);
        %ylim(h_progress(1),[min(xTrial) max(xTrial)])
    end
    
    f_PlotTraces(xTrial, 1:length(xTrial), h_progress(1), 'Ylabel', 'x value');
    f_PlotTraces(resTrial, 1:length(resTrial), h_progress(2), 'Ylabel', 'residual');
    if ~isempty(deltaTrial2), f_PlotTraces(deltaTrial2, 1:length(deltaTrial2), h_progress(3), 'Ylabel', 'delta'); end
    if ~isempty(tzOffsetTrial2), f_PlotTraces(tzOffsetTrial2, 1:length(tzOffsetTrial2), h_progress(4), 'Ylabel', 'tzOffset'); end
    if ~isempty(deltaTrial), f_PlotTraces(deltaTrial, 1:length(deltaTrial), h_progress(5), 'Ylabel', 'delta'); end
    if ~isempty(tzOffsetTrial), f_PlotTraces(tzOffsetTrial, 1:length(tzOffsetTrial), h_progress(6), 'Ylabel', 'tzOffset'); end
    
    
    if isempty(h_progresSurf) || ~ishandle(h_progresSurf(end))
        [ h_progresSurf ] = f_MultiLinLogAxes( 1, opt.plotProgress+1, 'rowStyles', [{'Linear'};'LinLog';'LinLog']);
    end
    f_PlotTraces(DAS, wave, h_progresSurf(1));
    f_PlotTraces(expTime, time, [h_progresSurf(2),h_progresSurf(3)]);
    f_PlotSurf( resMatrixOrig, time, wave, [h_progresSurf(4),h_progresSurf(5)], 'ZLim', [min(min(resMatrixOrig))/10, max(max(resMatrixOrig))/10]);
    pause(0.001);
end

k_out = k;

end

function [resMatrix ] = searchDeltaTzOffset(x, k, data, time, wave, delta, tzOffset, weighting,concScaler)
global deltaTrial
global tzOffsetTrial
global h_TzDelta

opt.nonNegative = 0;
plotDetail = 0;

if length(tzOffset) > 1
    [tzOffset] = f_FittingScaler(x(end), tzOffset, 0);
    x = x(1:end-1);
    tzOffsetTrial = [tzOffsetTrial; tzOffset];
end

if length(delta) > 1
    [delta] = f_FittingScaler(x(end), delta, 0);
    x = x(1:end-1);
    deltaTrial = [deltaTrial; delta];
end

%% Calculates resMatrix (and DAS)

if isempty(concScaler)
    [ expTime ] = f_ExpConvIRF( time + tzOffset, k, 0, delta );
else
    [ expTime ] = f_ConvConcentrations(time + tzOffset,k,delta,concScaler);
end

expTime = expTime(:,sum(expTime)~=0);
DAS = expTime\data; %linear combination that minizes each spectra (LSQ)
DAS = DAS'; %for consistency
if opt.nonNegative
    DAS(DAS < 0) = 0;
end
dataPred = [DAS*expTime']';
resMatrix = data-dataPred;
resMatrix = resMatrix.*weighting;

if plotDetail
    if isempty(h_TzDelta) || ~ishandle(h_TzDelta(end))
        [ h_TzDelta ] = f_MultiLinLogAxes( 1, 10, 'rowStyles', [{'Linear'};'LinLog';'LinLog']);
    end
    f_PlotTraces(DAS, wave, h_TzDelta(1));
    f_PlotTraces(expTime, time, [h_TzDelta(2),h_TzDelta(3)]);
    f_PlotSurf( resMatrix, time, wave, [h_TzDelta(4),h_TzDelta(5)], 'ZLim', [min(min(resMatrix))/100, max(max(resMatrix))/100]);
    pause(0.001);
end
end