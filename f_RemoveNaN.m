function [ data, time, wave ] = f_RemoveNaN( data, time, wave )
%[ data, time, wave ] = f_RemoveNaN( data, time, wave )
%   Removes NaN values from data by deleting whole lines of matrix, will
%   first check time for NaNs then wave
%
%   %%Inputted Values
%   data                nxm matrix of intensity values
%   wave                vector wavelengths (or pixel)
%   time                vector of time points
%
%   %%Returned Values
%   data                nxm matrix of intensity values
%   wave                vector of wavelengths (or pixel)
%   time                vector of time points
%
%   %%Options
%
%   06-07-14 Shyamal - inital updated


%% Check input varibales
% time and wave are column vectors
iTime = 0; if size(time,1) ~= length(time), time = time'; iTime = 1; end
iWave = 0; if size(wave,1) ~= length(wave), wave = wave'; iWave = 1; end


%% Removes NaN first from time then from wave
if size(data,1) == length(time) % determines if time is on data row or column
    row = ~any(isnan(data),2);
    time = time(row,:);
    if size(data,1) == length(row), data = data(row,:);
    else data = data(:,row'); end
    
    column = ~any(isnan(data),1);
    wave = wave(column',:);
    if size(data,1) == length(column), data = data(column',:);
    else data = data(:,column); end
else
    column = ~any(isnan(data),1);
    time = time(column',:);
    if size(data,1) == length(column), data = data(column',:);
    else data = data(:,column); end
    
    row = ~any(isnan(data),2);
    wave = wave(row,:);
    if size(data,1) == length(row), data = data(row,:);
    else data = data(:,row'); end
end


%% returns time and wave to orignial vector form
if iTime, time = time'; end
if iWave, wave = wave'; end

end

