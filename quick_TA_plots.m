%%
start_folder = 'H:\OneDrive\UNSW\Software\quick-2D-plots\_test-data\';

pick_new_file = false;

% data limits
crop_data = false;
crop_time = [-10E-9,1E-3]; % will
crop_eV = [2.4,0.9]; % will

% zlimits
zLim = [-20,10]*1E-3; % leave blank for auto
%zLim = []; % leave blank for auto

% plotting figure number
fig_number = 2;

% times for spectra
spec_time = [
    450E-12 , 550E-12
    0.9E-8  ,  1.1E-8
    0.9E-5  ,  1.1E-5
    ];

% eV for kinetics
kin_eV = [
    1.05 ,1.15
    1.45 ,1.5
    2.45,2.55
    ];

norm_spec_index = 1; % which region above to plot normalized spectra

% pre signal time
ps_neg_time = -1E-9;
fs_neg_time = -1E-12;

% zero for noise region
auto_remove_noise = true; % NaN data with pre-zero std above below thrshold
auto_noise_threshold = 4E-3; % threshold for removal
auto_remove_fraction_max = 0.2; % maximum fraction of data that can be removed via this method

zero_ev = []; % zero the eV region here

% Plotting Styles

ls_kinetics = '-'; % linestyle for kinetics
ls_spectra = '-'; % linestyle for spectra
colour_patch = false; % make colours match

%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%

%% Load data

if pick_new_file || ~exist('data_loaded_bg','var')
    
    [FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.csv', 'Please pick file', start_folder);
    
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
%%
if crop_data
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
    [~,i_z] = min(abs(wave - zero_ev(1)));
    [~,i_z(2)] = min(abs(wave - zero_ev(2)));
    i_z = sort(i_z);
    data(:,i_z(1):i_z(2)) = NaN;
end

if auto_remove_noise
    [~,i_neg] = min(abs(time - neg_time));
    std_noSig = std(data(1:i_neg,:));
    
    rem = std_noSig > auto_noise_threshold;
    rem_frac = sum(rem)./size(data,2);
    if rem_frac > auto_remove_fraction_max
        warning(['Auto noise rejection failed! (',num2str(rem_frac*100),'% of data is noise by given limits']);
    else
        data(:,rem) = NaN;
    end
end

%% Make Colours
spec_c = f_ColorPicker(size(spec_time,1),'type','sequential','hue','blue');
kin_c = f_ColorPicker(size(kin_eV,1),'type','sequential','hue','red');


%% Create Traces
[kinetics, kinLabel] = f_Traces(data, wave, kin_eV);
[spectra, specLabel] = f_Traces(data, time, spec_time);

%% Normalize if requested


%%
if colour_patch
    spec_patch_c = kin_c;
    spec_patch_c(spec_patch_c>1) = 1;
    
    kin_patch_c = spec_c;
    kin_patch_c(kin_patch_c>1) = 1;
else
    spec_patch_c = [0.8,0.8,0.8];
    kin_patch_c = [0.8,0.8,0.8];
end
%% Plot data
RowStyles = {
    'LinLog'
    'Linear'
    };
[h,fh] = f_MultiLinLogAxes(2,fig_number,'RowStyles',RowStyles,'title',name,'xPadding',200,'xRightOffset',100);


f_Plot(data,time,wave,h(1:2),'zLim',zLim);

f_Plot(kinetics,time,h(3:4),'zLim',zLim,'LineStyle',ls_kinetics,...
    'patch',spec_time,'patch_color',kin_patch_c,'Legend',kinLabel(2,:),'PlotStyles',kin_c);
f_Plot(spectra,wave,h(5),'zLim',zLim,'LineStyle',ls_spectra,...
    'patch',kin_eV,'patch_color',spec_patch_c,'Legend',specLabel(2,:),'PlotStyles',spec_c);



[~,I_n] = min(abs(wave - kin_eV(norm_spec_index,1)));
[~,I_n(2)] = min(abs(wave - kin_eV(norm_spec_index,2)));
I_n = sort(I_n);
n_s = max(abs(spectra(I_n(1):I_n(2),:)));
spectra_n = spectra./n_s;

f_Plot(spectra_n,wave,h(6),'zLim',zLim./max(n_s),'LineStyle',ls_spectra,...
    'patch',kin_eV(norm_spec_index,:),'Legend',specLabel(2,:),'PlotStyles',spec_c);


%%
%clearvars -except data time wave data_loaded_bg kinetics kinLabel spectra specLabel name h fh zLim fig_number
