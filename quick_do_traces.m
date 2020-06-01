%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%


%% Plotting Options

colour_patch = false; % make colours match
use_red_blue = false;

%% Update Command Line
disp_str = 'Making Traces';
dispstat(disp_str);

%% Create Traces
[kinetics, kinLabel] = f_Traces(data, wave, kin_eV(:,1:2));
[spectra, specLabel] = f_Traces(data, time, spec_time(:,1:2));

% Remove all nan traces
i_rem = all(isnan(kinetics));
if any(i_rem)
    disp_str = ['** Could not make kinetic trace at, ', kinLabel{i_rem}];
    dispstat(disp_str,'keepthis');
    
    kinetics(:,i_rem) = [];
    kinLabel(:,i_rem) = [];
    kin_eV(i_rem,:) = [];
end

i_rem = all(isnan(spectra));
if any(i_rem)
    disp_str = ['** Could not make kinetic trace at, ', specLabel{i_rem}];
    dispstat(disp_str,'keepthis');
    
    spectra(:,i_rem) = [];
    specLabel(:,i_rem) = [];
    spec_time(i_rem,:) = [];
end

%% Normalize
kinetics_n = kinetics./kin_eV(:,3)';
spectra_n = spectra./spec_time(:,3)';



%% Update Normalization Trace Labesl
scalar_str = arrayfun(@(x) num2str(x,'%3.2e'),kin_eV(:,3),'uniformoutput',false);
scalar_str = strrep(scalar_str,'e+00','');
scalar_str = regexprep(scalar_str,'(?<=[-\+])0','');
scalar_str = regexprep(scalar_str,'e[\d-]+','\\times10^{$0}');
scalar_str = regexprep(scalar_str,'(e)(?=[\d-])','');
kinLabel_n = kinLabel;
for n = 1 : size(kinLabel_n,2)
    kinLabel_n(:,n) = strcat(kinLabel_n(:,n),{' (\times'},scalar_str{n},')');
end

scalar_str = arrayfun(@(x) num2str(x,'%0.1e'),spec_time(:,3),'uniformoutput',false);
scalar_str = strrep(scalar_str,'e+00','');
scalar_str = regexprep(scalar_str,'(?<=[-\+])0','');
scalar_str = regexprep(scalar_str,'e[\d-]+','\\times10^{$0}');
scalar_str = regexprep(scalar_str,'(e)(?=[\d-])','');
specLabel_n = specLabel;
for n = 1 : size(specLabel_n,2)
    specLabel_n(:,n) = strcat(specLabel_n(:,n),{' ('},scalar_str{n},')');
end

%% Colours
if use_red_blue
    % below is the a series shades of red and blue
    spec_c = f_ColorPicker(size(spec_time,1),'type','sequential','hue','blue');
    kin_c = f_ColorPicker(size(kin_eV,1),'type','sequential','hue','red');
else
    % below uses a rainbow of colurs
    spec_c = f_ColorPicker(size(spec_time,1),'type','qualitative');
    kin_c = f_ColorPicker(size(kin_eV,1),'type','qualitative');
end

% Plotting Styles
ls_kinetics = '-'; % linestyle for kinetics
ls_spectra = '-'; % linestyle for spectra

%% Patch Options
if colour_patch
    spec_patch_c = kin_c;
    spec_patch_c(spec_patch_c>1) = 1;
    
    kin_patch_c = spec_c;
    kin_patch_c(kin_patch_c>1) = 1;
else
    spec_patch_c = [0.8,0.8,0.8];
    kin_patch_c = [0.8,0.8,0.8];
end




