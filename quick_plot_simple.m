


%% Make Simple Style comparsion plots
%%
RowStyles = {
    'LinLog','Linear','LinLog'
    'Linear','Linear','LinLog'
    };
axesNumTxtAppend = {
    'Surface'
    'Spectra Slices'
    'Kinetic Slices'
    'DELETED'
    'Normalized Spectra'
    'Normalized Kinetics'
    };

%% Update Command Line
disp_str = ['Figures ',num2str(fig_c),' - Simple traces'];
dispstat(disp_str,'keepthis');

%%
[ h, fh, positions,titleH,fontSize,tbh] = f_MultiLinLogAxes(3,fig_c,'RowStyles',RowStyles,...
    'xPadding',120,'xRightOffset',20,'axesNumTxtAppend',axesNumTxtAppend);
h_surface = h(1:2);

h_s = h(3);
h_s_n = h(7);

h_k = h(4:5);
h_k_n = h(8:9);

h_remove = h(6);

%%
delete(h_remove);
delete(tbh(4));
%% Plot Data
f_Plot(data,time,wave,h_surface,'zLim',zLim,'zLabel','');

%% Plot Spectra
f_Plot(spectra,wave,h_s,'zLim',zLim,'LineStyle',ls_spectra,'Legend',specLabel(2,:),...
    'PlotStyles',spec_c,'Patch',kin_eV(:,1:2),'YLabel',y_units);

spec_keep = spec_time(:,4) == 1;
f_Plot(spectra_n(:,spec_keep),wave,h_s_n,'zLim',zLim_norm,'LineStyle',ls_spectra,'Legend',specLabel_n(2,spec_keep),...
    'PlotStyles',spec_c(spec_keep,:),'YLabel',['Norm. ',y_units]);

%% Plot Kinetics
f_Plot(kinetics,time,h_k,'zLim',zLim,'LineStyle',ls_kinetics,'Legend',kinLabel(2,:),...
    'PlotStyles',kin_c,'Patch',spec_time(:,1:2),'YLabel',y_units);

kin_keep = kin_eV(:,4) == 1;
f_Plot(kinetics_n(:,kin_keep),time,h_k_n,'zLim',zLim_norm,'LineStyle',ls_kinetics,'Legend',kinLabel_n(2,kin_keep),...
    'PlotStyles',kin_c(kin_keep,:),'YLabel',['Norm. ',y_units]);
