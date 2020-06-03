%%
fit_to_explore = 2;


%% Get Data
working_data = fullSummary.(['k',num2str(fit_to_explore)]);

DAS = working_data.DAS';
Decay = working_data.ExponentialDecay;
time_u = fullSummary.time;
wave_u = fullSummary.wave;

lifetimes = 1./working_data.RateConstants;


dataPredict = Decay*DAS;
res = working_data.ResidualMatrix;
%%
lifetimes_str = arrayfun(@(x) num2strEng(x,3),lifetimes,'UniformOutput',0);
lifetimes_str = strcat(lifetimes_str,'s');

%% Build Surfaces


%% Plot

% Rotation Effects
RowStyles = {
    'LinLog','LinLog','Linear'
    'LinLog','LinLog','LinLog'
    };

axesNumTxt = {
    'a. Data Surface'
    'b. Predicted Surface'
    'd. Decay Associated Spectra (DAS)'
    ''
    'c. Residual Surface'
    'e. Decay'
    };

[h,fh] = f_MultiLinLogAxes(3,1,'RowStyles',RowStyles,'xPadding',150,'lowerNumAxes',0,'axesNumTxt',axesNumTxt);

h_s = h(1:2);
h_dp = h(3:4);
h_r = h(8:9);
h_delete = h(6:7);
h_DAS = h(5);
h_Decay = h(10:11);

f_Plot(Decay,time_u,h_Decay,'LineStyle','-','YLabel','DAS');
f_Plot(DAS,wave_u,h_DAS,'Legend',lifetimes_str);

f_Plot(data,time,wave,h_s,'zLim',zLim,'zLabel','');
f_Plot(dataPredict,time,wave,h_dp,'zLim',zLim,'zLabel','');
f_Plot(res,time,wave,h_r,'zLim',zLim);

delete(h_delete);