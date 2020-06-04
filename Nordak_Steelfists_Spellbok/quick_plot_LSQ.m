%% Make LSQ Style comparsion plots
RowStyles = {
    'LinLog','Linear','LinLog'
    'Linear','LinLog','Linear'
    'Linear','LinLog','LinLog'
    };
axesNumTxtAppend = {
    '1. Surface'
    'a. Spectra Slices'
    'D. Kinetic Slices'
    'DELETED'
    'b. Spectra - LSQ Kinetics'
    'E. Kinetics - LSQ Spectra'
    'DELETED'
    'c. Spectra - Residuals'
    'F. Kinetics - Residuals'
    };

%% Update Command Line
disp_str = ['Figures ',num2str(fig_c),' - LSQ with traces'];
dispstat(disp_str,'keepthis');

%%

[h_2,fh, positions,titleH,fontSize,tbh] = f_MultiLinLogAxes(3,fig_c,...
    'RowStyles',RowStyles,'xPadding',200,'xRightOffset',100,...
    'axesNumTxt',axesNumTxtAppend,'lowerNumAxes',0);

h_s = h_2([3,7,8,11,12]);
h_k = h_2([4,5,9,13,14]);
h_remove = h_2([6,10]);

%%
delete(h_remove);
delete(tbh([4,7]));

%%
is_nan = any(isnan(data),1);
% X = A\B is the solution in the least squares sense to the under- or overdetermined system of equations A*X = B

%% Spectra
decay_LSQ = spectra(~is_nan,:)\data(:,~is_nan)';
f_Plot(spectra,wave,h_s(1),'zLim',zLim,'LineStyle',ls_spectra,'Legend',specLabel(4,:),'PlotStyles',spec_c);
f_Plot(decay_LSQ',time,h_s(2:3),'PlotStyles',spec_c,'patch',spec_time(:,1:2),'LineStyle',ls_kinetics);

res = data;
res(:,~is_nan) = data(:,~is_nan) - [spectra(~is_nan,:)*decay_LSQ]';
f_Plot(res,time,wave,h_s(4:5),'zLim',zLim/10);

%% Kinetics
X = kinetics\data(:,~is_nan);

f_Plot(kinetics,time,h_k(1:2),'zLim',zLim,'LineStyle',ls_kinetics,'Legend',kinLabel(4,:),'PlotStyles',kin_c);

X_p = nan(size(spectra,1),size(kinetics,2));
X_p(~is_nan,:) = X';
f_Plot(X_p,wave,h_k(3),'LineStyle',ls_spectra,'PlotStyles',kin_c,'patch',kin_eV(:,1:2));

%%
res = data;
res(:,~is_nan) = data(:,~is_nan) - kinetics*X;
f_Plot(res,time,wave,h_k(4:5),'zLim',zLim/10);
f_Plot(data,time,wave,h_2(1:2),'zLim',zLim);