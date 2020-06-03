%%
fit_to_explore = 3;
use_r_inv = false;

initial_yields = [
    1
    1
    0
    ];

transfer_fraction = [
    %start %end  %Yield
    %1,       2,    0.5
    %1,       3,     1
    2,       3,     2
    ];

rotation_inv = [
    1,   0,     0,
    0,   1,     0,
    0,   0,     1,
    ];

%% Get Data
working_data = fullSummary.(['k',num2str(fit_to_explore)]);

DAS = working_data.DAS';
Decay = working_data.ExponentialDecay;

res = working_data.ResidualMatrix;

time_u = fullSummary.time;
wave_u = fullSummary.wave;

dataPredict = Decay*DAS;

%
lifetimes = 1./working_data.RateConstants;
lifetimes_str = arrayfun(@(x) num2strEng(x,3),lifetimes,'UniformOutput',0);
lifetimes_str = strcat(lifetimes_str,'s');

%% Rotation



if use_r_inv
    R_use_inv = rotation_inv(1:size(DAS,1),1:size(DAS,1));
    R_use = inv(R_use_inv);
    
else
    % make rotation matrix
    
    R_use = zeros(size(DAS,1));
    
    for n = 1 : length(R_use)
        
        R_use(n,n) = initial_yields(n);
        
        i_update = transfer_fraction(:,1) == n;
        
        R_use(n,transfer_fraction(i_update,2)) = -transfer_fraction(i_update,3);
        if n > 1
            R_use(n,n) = R_use(n,n) + -1*sum((R_use(1:n-1,n)));
        end
    end
    R_use_inv = inv(R_use);
end

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
    'c. Decay Associated Spectra (DAS)'
    'e. Species Associated Spectra (SAS)'
    'b. Residual'
    'd. Decay'
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
f_Plot(DAS,wave_u,h_DAS,'Legend',lifetimes_str);
%
f_Plot(conc_profile,time_u,h_Conc,'LineStyle','-','YLabel','DAS');
f_Plot(SAS,wave_u,h_SAS);

