function [data, wave, time] = f_CropData(data, wave, time, wl_min, wl_max, t_min, t_max)
%[data, wave, time] = f_CropData(data, wave, time, wl_min, wl_max, t_min, t_max)
%   Removes NaN values from data by deleting whole lines of matrix, will
%   first check time for NaNs then wave
%
%   %%Inputted Values
%   data                nxm matrix of intensity values
%   wave                vector wavelengths (or pixel)
%   time                vector of time points
%   wave and time bounds
%
%   %%Returned Values
%   data                nxm matrix of intensity values
%   wave                vector of wavelengths (or pixel)
%   time                vector of time points
%
%   %%Options
%

if nargin <= 3 || wl_min < min(wave), wl_min = 'f'; end
if nargin <= 4 || wl_max > max(wave), wl_max = 'f'; end
if nargin <= 5 || t_min < min(time), t_min = 'f';  end
if nargin <= 6 || t_max > max(time), t_max = 'f';  end

if size(data,1) ~= size(time,1), data = data'; end

%%% Checks that wave and time arrays are ordered highest to lowerst
if wave(1) > wave(end)
    wave = wave(linspace(length(wave),1, length(wave)));
    data = data(:,linspace(length(wave),1, length(wave)));
end

if time(1) > time(end)
    time = time(linspace(length(time),1, length(time)));
    data = data(linspace(length(time),1, length(time)),:);
end
%%%%%%%%%%%%%%%%%%%%%%

%find indices of nearest wavelengths otherwise get absoulte end value
if   wl_min ~= 'f',
    [~,wl_min_ind] = min(abs(wl_min-wave));       
else wl_min_ind = 1;                                     
end                                  

if   wl_max ~= 'f',
    [~,wl_max_ind] = min(abs(wl_max-wave));
else wl_max_ind = length(wave);
end
%%%%%%%%%%%%%%%%%

%find indices of nearest times otherwise get absoulte end value
if   t_min ~= 'f',
    [~,time_min_ind] = min(abs(t_min-time));    
else time_min_ind = 1;                               
end                                
if   t_max ~= 'f',
    [~,time_max_ind] = min(abs(t_max-time));
else time_max_ind = length(time);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%cropping wavelengths
if wl_min || wl_max
    wave = wave(wl_min_ind:wl_max_ind);
    data = data(:,wl_min_ind:wl_max_ind);
end
%%%cropping times
if t_max || t_min
    time = time(time_min_ind:time_max_ind);
    data = data(time_min_ind:time_max_ind,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

