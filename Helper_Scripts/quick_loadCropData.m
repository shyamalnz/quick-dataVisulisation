%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%
%%
if pick_new_file || ~exist('data_loaded_bg','var')
    
    [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.csv', 'Please pick file', start_folder);
    %
    
    % Update Command Line
    disp_str = 'Loading data';
    dispstat(disp_str);
    
    %
    [data_loaded,time_loaded,wave_loaded] = f_LoadTA([PATHNAME,'\',FILENAME]);
    
    name = FILENAME(1:end-4);
    
    
    if min(diff(time_loaded)) > 1E-12
        is_fs = false;
        neg_time = ps_neg_time;
    else
        is_fs = true;
        neg_time = fs_neg_time;
    end
    
    [data_loaded_bg, collected_bg] = f_SubtractBG(data_loaded,time_loaded,neg_time);
end

%% Update Command Line
disp_str = [
    'Working with file:',newline,...
    FILENAME,' (', PATHNAME,')',newline];
dispstat(disp_str,'keepthis');
%%
if crop_data
    
    % Update Command Line
    disp_str = 'Data has been cropped';
    dispstat(disp_str,'keepthis');
    
    
    [~,i_w] = min(abs(wave_loaded - crop_eV(1)));
    [~,i_w(2)] = min(abs(wave_loaded - crop_eV(2)));
    i_w = sort(i_w);
    [~,i_t] = min(abs(time_loaded - crop_time(1)));
    [~,i_t(2)] = min(abs(time_loaded - crop_time(2)));
    i_t = sort(i_t);
    
    data = data_loaded_bg(i_t(1):i_t(2),i_w(1):i_w(2));
    wave = wave_loaded(i_w(1):i_w(2));
    time = time_loaded(i_t(1):i_t(2));
else
    data = data_loaded_bg;
    wave = wave_loaded;
    time = time_loaded;
end


%%
number_nan = sum(isnan(data(:)));
nan_frac = number_nan./numel(data);

if nan_frac > 0.2
    warning([num2str(nan_frac*100),'% of data is NaN, maybe something went wrong with collection'])
end


%%
if ~isempty(zero_ev)
    
    % Update Command Line
    disp_str = 'Some wavelengths have been zeroed';
    dispstat(disp_str,'keepthis');
    
    [~,i_z] = min(abs(wave - zero_ev(1)));
    [~,i_z(2)] = min(abs(wave - zero_ev(2)));
    i_z = sort(i_z);
    data(:,i_z(1):i_z(2)) = NaN;
end

%%
data_no_nan = data;
data_no_nan(isnan(data_no_nan)) = 0;