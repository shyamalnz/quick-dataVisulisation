function [traces, traceLabel, numPoints, int_region, unit] = f_Traces(data, traceAxis, int_range, varargin)
%[traces, traceLabel, numPoints, int_region, unit] = f_Traces(data, traceAxis, int_range, varargin)
%   Detailed explanation goes here

%% Check input varibales
if size(traceAxis,1) == 1, traceAxis = traceAxis'; end
if length(traceAxis) ~= size(data, 1), data = data'; end

%% Sets Options
% default options
opt.useIndex = 0;
opt.intergrate = 0;
opt.percent = 10;

if traceAxis(2)-traceAxis(1) == 1 && traceAxis(1) < 200
    opt.unit = ' pixel';
elseif mean(log10(abs(diff(traceAxis)))) < -5
    opt.unit = 's';
elseif max(traceAxis) < 100
    opt.unit = 'eV';
else
    opt.unit = 'nm';
end

%% user input
[opt] = f_OptSet(opt, varargin);

%% Checks input
if opt.percent > 1, opt.percent = opt.percent/100; end
unit = opt.unit;
%% if Time converts to log scale
% if strcmp(opt.unit,'s')
%     trace_sign = sign(traceAxis);
%     traceAxis = log10(abs(traceAxis)).*trace_sign;
%     int_range = log10(int_range);
% end

%% Makes variables
number_of_traces = size(int_range,1);
traces = nan(size(data,2),number_of_traces);

int_label = nan(1,number_of_traces);

alt_range = 1 + opt.percent;
index_temp = nan(1,2);

if opt.useIndex
    index = int_range;
    %% Checks index limits
    index(index < 1) = 1;
    index(index > length(traceAxis) ) = length(traceAxis);
else
    index = zeros(number_of_traces,2);
    for n = 1 : number_of_traces
        if size(int_range,2) > 1
            [~,index_temp(1,1)] = min(abs(int_range(n,1)-traceAxis));
            [~,index_temp(1,2)] = min(abs(int_range(n,2)-traceAxis));
        else
            [~,index_temp(1,1)] = min(abs(int_range(n,1)/alt_range-traceAxis));
            [~,index_temp(1,2)] = min(abs(int_range(n,1)*alt_range-traceAxis));
        end
        index(n,:) = sort(index_temp);
    end
end


%% Makes Traces
numPoints = range(index,2) + 1;
for n = 1:number_of_traces
    int_label(n) = mean(traceAxis([index(n,1),index(n,2)]));
    if index(n,1) == index(n,2)
        if index(n,1) ~= 1 && index(n,1)~= size(data,1)
            traces(:,n) = data(index(n,1), :);
        end
    else
        if opt.intergrate
            traces(:,n) = trapz(traceAxis(index(n,1):index(n,2)),data(index(n,1):index(n,2),:))./range(traceAxis([index(n,1),index(n,2)]));
        else
            int_label(n) = mean(traceAxis([index(n,1):index(n,2)]));
            
            data_ave = data(index(n,1):index(n,2),:);
            %if sum(sum(isnan(data_ave)))/numel(data_ave) < 0.5
                traces(:,n) = nanmean(data_ave);
            %end
        end
    end
end

%% set region
int_region = traceAxis(index);

%% Makes Labels
numPoints_str = arrayfun(@num2str, numPoints, 'uniformoutput',0);
numPoints_str = strcat('(',numPoints_str,')');

    traceLabel = [];
try
    
traceLabel_1 = num2strEng(int_label',3);
add_space = ~cellfun(@isempty,regexp(traceLabel_1,'\d$'));
traceLabel_1(add_space) = strcat(traceLabel_1(add_space),{' '});

traceLabel_2 = num2strEng(traceAxis(index),3);
add_space = ~cellfun(@isempty,regexp(traceLabel_2,'\d$'));
traceLabel_2(add_space) = strcat(traceLabel_2(add_space),{' '});


traceLabel = [strcat([traceLabel_1,traceLabel_2],unit),strcat([traceLabel_1,traceLabel_2],[numPoints_str,numPoints_str])];
traceLabel = traceLabel';

catch ME
end
