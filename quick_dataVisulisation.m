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
plot_surface = true;

plot_slices = false; % every day traces

plot_slices_LSQ = false; % trys to measure surface with LSQ fitting

do_SVD = false;

do_global_fit = false;

%% Data Cropping Options
crop_data = true; % do you actually want to crop the data

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
     %start,   % end, norm scalar,  plot_norm
    -0.1E-9,  0.1E-9,   0.9131E-3,   1
       1E-9,    2E-9,    1.293E-3,   1
     0.9E-7,    2E-7,        1E-3,   0
      %1E-4,    3E-4,        1E-3,   0
    ];

% eV for kinetics
kin_eV = [
    %start, % end, norm scalar, plot_norm
    %2.08,   2.07,           1,  1
    1.95,    2.05,           1.45e-3,  1
    1.291,  1.259,           0.645e-3,  1
    0.9911,0.9386,           1,  0
    ];

%% Global Fitting Options
start_lifetimes = {
    '10 n',      '',    '', ''
    '10 n', '100 n',    '', ''
    '10 n', '100 n', '1 u', ''
    '10 n', '100 n', '1 u', '10 u'
    };

tzOffset = [-5E-9,5E-9];%Range of possibe time zero
delta = [100E-12,3E-9]; %Range of possibe IRF
kScaler = [10E-12,1E-1]; %Range of possibe lifetimes

%% SVD
components_to_plot = 4;

%% Error logging level
error_reporting = false;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script is below here (don't change!) %%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
start_directory = pwd;
working_folder = [start_directory,'\Helper_Scripts\'];
cd(working_folder);

quick_dataV_helper

cd(start_directory);

    



