
%% %%%%%%%%%%%%%%%%%%% %%
%% Script Below Here   %%
%% %%%%%%%%%%%%%%%%%%%%%%

%% Update Command Line
disp_str = ['Figures ',num2str(fig_c),' to ',num2str(fig_c+1),' - Global fitting'];
dispstat(disp_str,'keepthis');

%%
lifetimes_cell = cellfun(@str2numEng,start_lifetimes,'UniformOutput',false);
lifetimes = zeros(size(lifetimes_cell));
for n = 1 : size(lifetimes,1)
    lt_temp = [lifetimes_cell{n,:}];
    lifetimes(n,1:length(lt_temp)) = lt_temp;
end

kArray = 1./lifetimes;
kArray(kArray==inf) = 0;
kScaler = 1./kScaler;

%tzOffset = 0;
%delta = 100E-15;

% Do GF
[fitSummary, kArray, fullSummary, figure_handles] = f_MultiKGlobalFit( data_no_nan,...
    time, wave, kArray, kScaler, delta, tzOffset,'name',name,'PlotR',fig_c);