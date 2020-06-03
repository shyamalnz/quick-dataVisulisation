%%
fit_to_explore = 3;
use_r_inv = false;

rotation = [
    1,   0.1,     0.3, 0,0
    0,    1,      0.1, 0,0
    0,    0,        1, 0,0
    0,    0,        0, 1,0
    0,    0,        0, 0, 1
    ];

%% Get Data
DAS = spectra';
Decay = decay_LSQ';
dataPredict = Decay*DAS;
res = data - dataPredict;
%% Rotation
R_use = rotation;
R_use_inv = inv(R_use);

conc_profile = Decay*R_use;
SAS = R_use_inv*DAS;

%% Plot
% Rotation Effects
RowStyles = {
    'LinLog','Linear','Linear'
    'LinLog','LinLog','LinLog'
    };

axesNumTxt = {
    'a. Data Surface'
    'c. Spectra'
    'e. Species Associated Spectra (SAS)'
    'b. Residual'
    'd. Spectra - LSQ Kinetics'
    'f. Relative Concentration'
    };

[h,fh] = f_MultiLinLogAxes(3,1,'RowStyles',RowStyles,'xPadding',150,'lowerNumAxes',0,'axesNumTxt',axesNumTxt);

h_s = h(1:2);
h_r = h(5:6);

h_DAS = h(3);
h_Decay = h(7:8);

h_SAS = h(4);
h_Conc = h(9:10);

%
f_Plot(data,time,wave,h_s,'zLim',zLim,'zLabel','');
f_Plot(res,time,wave,h_r,'zLim',zLim);
%
f_Plot(Decay,time_u,h_Decay,'LineStyle','-','YLabel','DAS');
f_Plot(DAS,wave_u,h_DAS,'Legend',specLabel(4,:));
%
f_Plot(conc_profile,time_u,h_Conc,'LineStyle','-','YLabel','DAS');
f_Plot(SAS,wave_u,h_SAS);

