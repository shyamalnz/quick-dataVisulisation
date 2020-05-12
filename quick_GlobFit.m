%%
[~,i_pre_sig] = min(abs(time - -1.5E-9));
sd = std(data(1:i_pre_sig,:));


i_nan = [177:250,800:829 ];
data(:,i_nan) = NaN;
f_Plot(data,time,wave,11);
%%

kArray = [
    1E-8,      0,      0,    0;
    1E-8, 8.5E-5,      0,    0;
    1E-8, 8.5E-5, 6.7E-5,    0;
    1E-8, 8.5E-5, 6.7E-5, 1E-2;
    ];

tzOffset = [-1E-9,1E-9];
delta = [100E-12,3E-9];
kScaler = [10E-12,1E-1];

kArray = 1./kArray;
kArray(kArray==inf) = 0;
kScaler = 1./kScaler;

%tzOffset = 0;
%delta = 100E-15;

% Do GF
[fitSummary, kArray, fullSummary, figure_handles] = f_MultiKGlobalFit( data,...
    time, wave, kArray, kScaler, delta, tzOffset,'name',name);