%% Data Loaction
start_folder = 'F:\OneDrive\UNSW\Software\quick-2D-plots\';
pick_new_file = false;


%% General Options
% plotting figure number
fig_number = 10; % will use fig_number + (0 to 9)

% pre signal time
ps_neg_time = -1E-9;
fs_neg_time = -1E-12;

y_units = ['\DeltaT/T'];

%% What do I want to do, options below
crop_data = true;
plot_slices = true; % every day traces
plot_slices_LSQ = false; % trys to measure surface with LSQ fitting
do_SVD = false;
do_global_fit = false;

%% Data Cropping Options
% zero for noise region
zero_ev = []; % zero the eV region here

crop_time = [-10E-9,1E-3]; % will
crop_eV = [2.05,0.9]; % will

zLim = [-2,1]*1E-3;
zLim_norm = [-2,1];
%zLim = []; % leave blank for auto

%% Plotting

% times for spectra
spec_time = [
    %start, % end, norm scalar,  plot_norm
    -0.1E-9,  0.1E-9,   0.9131E-3,   1
    1E-9,    2E-9,    1.293E-3,   1
    0.9E-7,    2E-7,        1E-3,   0
    %1E-4,    3E-4,        1E-3,   0
    ];

% eV for kinetics
kin_eV = [
    %start, % end, norm scalar, plot_norm
    2.08,  2.07,     1    ,  1
    1.95,  2.05,     1    ,  1
    1.291, 1.259,    1    ,  0
    0.9911, 0.9386,  1    ,  0
    ];

%% Global Fitting Options
start_lifetimes = {
    '10 n',      '',     '', ''
    '10 n', '100 n',    '', ''
    '10 n', '100 n', '1 u', ''
    '10 n', '100 n', '1 u', '10 u'
    };

tzOffset = [-5E-9,5E-9];
delta = [100E-12,3E-9];
kScaler = [10E-12,1E-1];


%% SVD
components_to_plot = 4;

%% Error logging level
error_reporting = false;

%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%
try
    fig_c = fig_number;
    
    keep_vars = {
        ''
        };
    
    %% loading, croping, zero regions
    quick_loadCropData
    
    %% make slices
    if plot_slices || plot_slices_LSQ
        quick_do_traces
    end
    
    %% Plot Simple
    fig_c = fig_c + 1;
    if plot_slices
        quick_plot_simple
        pause(1);
    end
    
    %% Plot LSW
    fig_c = fig_c + 1;
    if plot_slices_LSQ
        quick_plot_LSQ
        pause(1);
    end
    
    %% Global Fit
    fig_c = fig_c + 1;
    if do_global_fit
        quick_do_GF
        pause(1);
    end
    
    %% Global Fit
    fig_c = fig_c + 1;
    if do_SVD
        [ U,S,V,diagS ] = f_SVD( data_no_nan, time, wave,'NumPlotted',components_to_plot);
    end
    
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
    %
    if error_reporting
        save('error_dump')
        warning('Error reporting enabled. Please send "error_dump.mat" with description of what you are doing')
    end
end

%% Clean up workspace




