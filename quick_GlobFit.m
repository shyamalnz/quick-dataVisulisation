
%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%

%%
kArray = 1./kArray;
kArray(kArray==inf) = 0;
kScaler = 1./kScaler;

%tzOffset = 0;
%delta = 100E-15;

% Do GF
[fitSummary, kArray, fullSummary, figure_handles] = f_MultiKGlobalFit( data,...
    time, wave, kArray, kScaler, delta, tzOffset,'name',name,'PlotR',fig_number+2);