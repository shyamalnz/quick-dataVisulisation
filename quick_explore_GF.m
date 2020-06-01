%%


fit_to_explore = 3;
use_r_inv = false;

rotation_matrix = [
    1,   -1,     0, 0
    0,   1,     -1, 0
    0,   0,     1, -1
    0,   0,     0, 1
    ];

rotation_inv = [
    1,   0,     0, 0
    0,   1,     0, 0
    0,   0,     1, 0
    0,   0,     0, 1
    ];



%% Get Data
working_data = fullSummary.(['k',num2str(fit_to_explore)]);

DAS = working_data.DAS';
Decay = working_data.ExponentialDecay;
time_u = fullSummary.time;
wave_u = fullSummary.wave;

dataPredict = Decay*DAS;


%% Rotation
R_use = rotation_matrix(1:size(DAS,1),1:size(DAS,1));
R_use_inv = rotation_inv(1:size(DAS,1),1:size(DAS,1));


if use_r_inv
    
    conc_profile = Decay*inv(R_use_inv);
    SAS = R_use_inv*DAS;
    
else
    conc_profile = Decay*R_use;
    SAS = inv(R_use)*DAS;
end


%% Build Surfaces



%% Plot

% Rotation Effects
[h,fh] = f_MultiLinLogAxes(2,1,'RowStyles',{'Linear','LinLog'}');

f_Plot(Decay,time_u,h(3:4),'LineStyle','-','YLabel','DAS');
f_Plot(conc_profile,time_u,h(5:6),'LineStyle','-','YLabel','Relative Concentration');


f_Plot(DAS,wave_u,h(1));
f_Plot(SAS,wave_u,h(2));