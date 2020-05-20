%% Data Loaction 
start_folder = 'H:\OneDrive\UNSW\Software\quick-2D-plots\_test-data\';
pick_new_file = false;

%% What should I do
plot_slices = true;
global_fit = true;

% plotting figure number
fig_number = 10; % will use fig_number + 0, +1 + 2 + 3

%% Data Options
crop_data = false;
crop_time = [-10E-9,1E-3]; % will
crop_eV = [2.4,0.9]; % will

% pre signal time
ps_neg_time = -1E-9;
fs_neg_time = -1E-12;

% zero for noise region
auto_remove_noise = true; % NaN data with pre-zero std above below thrshold
auto_noise_threshold = 4E-3; % threshold for removal
auto_remove_fraction_max = 0.2; % maximum fraction of data that can be removed via this method

zero_ev = []; % zero the eV region here

%% Plotting

%zlimits
zLim = [-5,5]*1E-3; % leave blank for auto
%zLim = []; % leave blank for auto

% times for spectra
spec_time = [
    -1E-9, 1E-9
    %20E-9, 30E-9
    1E-5, 1E-4
    ];

% eV for kinetics
kin_eV = [
    1.05 ,1.15
    %1.45 ,1.5
    2.45,2.55
    ];

%% Global Fitting Options
kArray = [
    1E-8,      0,      0,    0;
    1E-8, 8.5E-5,      0,    0;
    1E-8, 8.5E-5, 6.7E-5,    0;
    1E-8, 8.5E-5, 6.7E-5, 1E-2;
    ];

tzOffset = [-1E-9,1E-9];
delta = [100E-12,3E-9];
kScaler = [10E-12,1E-1];

%% Error logging level
error_reporting = false;

%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%

try
    
    %% loading, croping, zero regions
    quick_loadCropData
    
    %%   
    f_Plot(data,time,wave,fig_number,'zLim',zLim);
    
    %% make and plot
    if plot_slices
        quick_TA_plots
    end
    
    %% Global Fit
    if global_fit
        quick_GlobFit
    end
    
    %% Clean up workspace
    
catch ME
    %% Error Code
    %pause(1)
    close all
    save('error_dump')
    strErr = [
        'Unable to continue.',newline,...
        ];
    fprintf(2,strErr)
    strErr = [
        'Closing figures. Please send "error_dump.mat" with description of what you are doing',newline,...
        newline,...
        ME.stack(end).name,' (line ',num2str(ME.stack(end).line),')',newline,...
        newline,...
        ME.message
        ];
    disp(strErr)
    %%
    if error_reporting
        save('error_dump')
        warning('Error reporting enabled. Please send "error_dump.mat" with description of what you are doing')
    end
end




