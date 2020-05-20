%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%

%% Plotting Options
% colours
% below is the a series shades of red and blue

%spec_c = f_ColorPicker(size(spec_time,1),'type','sequential','hue','blue');
%kin_c = f_ColorPicker(size(kin_eV,1),'type','sequential','hue','red');

% below uses a rainbow of colurs
spec_c = f_ColorPicker(size(spec_time,1),'type','qualitative');
kin_c = f_ColorPicker(size(kin_eV,1),'type','qualitative');


% Plotting Styles
ls_kinetics = '-'; % linestyle for kinetics
ls_spectra = '-'; % linestyle for spectra
colour_patch = false; % make colours match


%% Create Traces
[kinetics, kinLabel] = f_Traces(data, wave, kin_eV);
[spectra, specLabel] = f_Traces(data, time, spec_time);


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

%% Make comparsion plots
RowStyles = {
    'LinLog','Linear','LinLog'
    'Linear','LinLog','Linear'
    'Linear','LinLog','LinLog'
    };
[h_2,fh] = f_MultiLinLogAxes(3,fig_number+1,'RowStyles',RowStyles,'xPadding',200,'xRightOffset',100);

h_s = h_2([3,7,8,11,12]);
h_k = h_2([4,5,9,13,14]);
h_remove = h_2([6,10]);
delete(h_remove);

is_nan = any(isnan(data),1);
% X = A\B is the solution in the least squares sense to the under- or overdetermined system of equations A*X = B

% Spectra
X = spectra(~is_nan,:)\data(:,~is_nan)';
f_Plot(spectra,wave,h_s(1),'zLim',zLim,'LineStyle',ls_spectra,'Legend',specLabel(2,:),'PlotStyles',kin_c);
f_Plot(X',time,h_s(2:3),'PlotStyles',kin_c,'patch',spec_time,'LineStyle',ls_kinetics);

res = data;
res(:,~is_nan) = data(:,~is_nan) - [spectra(~is_nan,:)*X]';
f_Plot(res,time,wave,h_s(4:5),'zLim',zLim);

% Kinetics
X = kinetics\data(:,~is_nan);
f_Plot(kinetics,time,h_k(1:2),'zLim',zLim,'LineStyle',ls_kinetics,'Legend',kinLabel(2,:),'PlotStyles',kin_c);
X_p = nan(size(spectra,1),size(kinetics,2));
X_p(~is_nan,:) = X';
f_Plot(X_p,wave,h_k(3),'LineStyle',ls_spectra,'PlotStyles',kin_c,'patch',kin_eV);

res = data;
res(:,~is_nan) = data(:,~is_nan) - kinetics*X;
f_Plot(res,time,wave,h_k(4:5),'zLim',zLim);

f_Plot(data,time,wave,h_2(1:2),'zLim',zLim);


%%
%clearvars -except data time wave data_loaded_bg kinetics kinLabel spectra specLabel name h fh zLim fig_number
