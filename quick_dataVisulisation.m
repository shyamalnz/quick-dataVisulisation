%% Data Loaction
start_folder = 'H:\OneDrive\UNSW\Software\quick-2D-plots\_test-data\';
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

plot_slices = true; % every day traces

plot_slices_LSQ = true; % trys to measure surface with LSQ fitting

do_SVD = true;

do_global_fit = true;

%% Data Cropping Options
crop_data = true; % do you actually want to crop the data

% zero for noise region
zero_ev = []; % zero the eV region here

crop_time = [-10E-9,1E-3]; % will
crop_eV = [2.1,0.9]; % will

zLim = [-3,3]*1E-3;
zLim_norm = [-1,1.1];
%zLim = []; % leave blank for auto

%% Plotting
% times for spectra
spec_time = [
     %start,   % end, norm scalar,  plot_norm
    -0.1E-12,  0.1E-12,   0.9131E-3,   0
     100E-12,  200E-12,    2.128E-3,   1
        1E-9,     4E-9,    1.544E-3,   1
    ];

% eV for kinetics
kin_eV = [
    %start, % end, norm scalar, plot_norm
    1.45,    1.47,          -2.627E-3,  1
    1.31,    1.32,          -2.037E-3,  1
    2.15,    2.16,           2.183E-3,  1
    ];

%% Global Fitting Options
start_lifetimes = {
    '10 n',      '',    '', ''
    '10 n', '100 n',    '', ''
    '10 n', '100 n', '1 u', ''
    '10 n', '100 n', '1 u', '10 u'
    };

tzOffset = [-5E-9,5E-9];%Range of possibe time zero
delta = [100E-15,3E-9]; %Range of possibe IRF
kScaler = [10E-15,1E-1]; %Range of possibe lifetimes

%% SVD
components_to_plot = 4;

%% Error logging level
error_reporting = false;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Script is below here (don't change!) %%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
start_directory = pwd;
working_folder = [start_directory,'\Nordak_Steelfists_Spellbok\'];
cd(working_folder);

quick_dataV_helper

cd(start_directory);

    



