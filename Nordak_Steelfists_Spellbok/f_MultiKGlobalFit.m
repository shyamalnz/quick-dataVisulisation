function [fitSummary, kArray, fullSummary, figure_handles] = f_MultiKGlobalFit( data, time, wave, kArray, kScaler, delta, tzOffset, varargin)
%UNTITLED2 Summary of this function goes here
%   kScaler = the range of the fitted k_values
%   kArray = the start k_values

global kTrial
global xTrial
global resTrial
global deltaTrial2
global tzOffsetTrial2

global h_progress
global h_TzDelta
global h_progresSurf
h_progress = [];
h_TzDelta = [];
h_progresSurf = [];

%% Check input varibales
if max(kScaler) ~= kScaler(1), kScaler = [kScaler(2), kScaler(1)]; end
if size(kScaler,2) ~= 2, kScaler = kScaler'; end
if size(data,1) ~= size(time,1)
    data = data';
end
if kScaler(1) > 30
    kScaler = log10(kScaler);
end

%% Remove data
nan_array = isnan(data);
remove = all(nan_array);
data(:,remove) = [];
nan_array(:,remove) = [];
wave(remove) = [];
remove = all(nan_array,2);
data(remove,:) = [];
nan_array(remove,:) = [];
time(remove) = [];
kArray(isnan(kArray)) = 0;
%% Sets Options
% default options
opt.name = 'UNNAMED';

opt.randKSamples = 20;
opt.interpFactor = 0;
opt.preSignalTime = -0.5E-12;

opt.plotR = 10;
opt.resSqueeze = 5;
opt.FontSize = 10;
% user input
[opt] = f_OptSet(opt, varargin);
%% Variables
numK = size(kArray,1);
%% Adds inital details to full summary
    fullSummary.wave = wave;
    fullSummary.time = time;
    fullSummary.data = data;
    fullSummary.inputK = kArray;
%% Scales data to be between +/- 1
scaleFactor = max(max(abs(data)));
data = data./scaleFactor;
%% Checks wave range
if max(wave) > 1200
    wave_str = 'Wavelength (\mum)';
    wave = wave/1000;
elseif max(wave) < 10
    
    wave_str = 'Energy (eV)';
else
    wave_str = 'Wavelength (nm)';
end
%% Upscales data for better fitting
if opt.interpFactor
    timeI =  interp1q( linspace(1,length(time),length(time))' , time , linspace(1,length(time),length(time)*opt.interpFactor+1)');
    data = interp1q(time, data, timeI);
    data = data';
    time = timeI;
    
    [ data, time, wave] = f_RemoveNaN( data, time, wave);
    
    fullSummary.timeInterp = time;
    fullSummary.dataInterp = data;
end
%% Splits data into presingal and data regions
[preSignalData] = f_CropData(data, wave, time, 'f', 'f', 'f', opt.preSignalTime );
%[data, wave, time] = f_CropData(data, wave, time, 'f', 'f', opt.preSignalTime , 'f');
% data = data';
%% Calulates Weighting Matrix
preSignalWeights = std(abs(preSignalData),1);
preSignalWeights = sqrt(abs(1./preSignalWeights));
preSignalWeights = smooth(preSignalWeights,15);
preSignalWeights(isinf(preSignalWeights)) = 0;
preSignalWeights = preSignalWeights./max(preSignalWeights);
preSignalWeights(preSignalWeights==0) = 1;
%weighting = sqrt(abs(data)); %square as the residules are returned to funciton no the square of residuals
%weighting = weighting./max(max(weighting));
weighting = ones(size(data));
weighting = bsxfun(@times, weighting, preSignalWeights');
weighting = weighting./max(max(weighting));
%% Sets up axis for plotting
if opt.plotR
    scnsize = get(0,'ScreenSize');
    if ishandle(opt.plotR)
        clf(opt.plotR);
        fh = opt.plotR;
    else
        fh = figure(opt.plotR);
    end
    set(fh,'OuterPosition',[0,0,scnsize(3)/2,scnsize(4)]);
    figSize = get(fh,'position');
    rowStyles = [{'Linear'};'LinLog';'LinLog';'LinLog';'LinLog'];
    
    
    LeftLabel =fliplr({'Residaul','Predicted','Difference','Decays', 'Decay Spectra'});
    if length(opt.name) > 30
       Title = opt.name;
    else
    Title = ['Global Fit of ',opt.name,' Showing ',num2str(numK),' Different Fits'];
    end
    
    [h, figure_handles(1), positions] = f_MultiLinLogAxes( numK, fh,'rowStyles', rowStyles,...
        'title',Title,'yTopOffset',30,'yPadding',[50,10,10,10,50],'xPadding',50, 'xLeftOffset', 40,...
        'figureSize','fillleft', 'LeftLabel',LeftLabel,'FontSize',opt.FontSize);
    pause(0.1);
else
   figure_handles = []; 
end
%% Generates random K to start from (computationaly expensive ~2mins)
if kArray(1) < 8
    kArray(1) = ceil(kArray(1)); %round k to whole number
    [ kArray, ~, ~] = f_RandSampleGlobalFit( kArray, opt.randKSamples, data, time, wave, weighting);
    kArray = kArray(:,1:end-1);
end

fullSummary.weighting = weighting;
fitSummary = zeros(size(kArray,1),size(kArray,2)+3);
fullSummary.k1.DAS = [];
%% Fits data to each k=
for j = 1: numK
    % Reset global variables
    kTrial = [];
    xTrial = [];
    resTrial = [];
    deltaTrial2 = [];
    tzOffsetTrial2 = [];
    
    k = kArray(j,:);
    k(k == 0) = [];
    k = log10(k);
    k = f_FittingScaler(k, kScaler, 1);
    
    LB = ones(length(k),1)*-0.5;
    UB = ones(length(k),1)*0.5;
    
    [k,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(@f_GlobalFit, k, LB, UB,...
        optimset('Algorithm', 'trust-region-reflective', 'Display', 'off', 'FinDiffType', 'central', 'TolFun', 1E-12),...
        data, time, wave, kScaler, delta,  tzOffset, weighting);
    
    %[Q,R] = qr(jacobian,0);
    %mse = sum(abs(residual).^2)/(size(jacobian,1)-size(jacobian,2));
    %Rinv = inv(R);
    %Sigma = Rinv*Rinv'*mse;
    %se = sqrt(diag(Sigma));
    
    
    
    
    [ resMatrix,  DAS, expTime, dataPred, deltaFitted, tzOffsetFitted, k_outFitted] = f_GlobalFit( k, data, time, wave, kScaler, delta, tzOffset, weighting);
    
    DAS = DAS*scaleFactor;
    dataPred = dataPred*scaleFactor;
    resMatrix = resMatrix*scaleFactor;
    
    kOutput = k;
    k = f_FittingScaler(k, kScaler, 0);
    k = 10.^k;
    k = sort(k,'descend');
    %
    
    [~,i_sort] = sort(k_outFitted,'descend');
    expTime = expTime(:,i_sort);
    DAS = DAS(:,i_sort);
    k_outFitted = k_outFitted(i_sort);
    
    %
    res = sum(sum((dataPred-data*scaleFactor).^2));
    fitSummary(j, 1:length(k)) = k_outFitted;
    fitSummary(j, end-2:end) = [deltaFitted, tzOffsetFitted, res];
    
    fullSummary.(['k',num2str(j)]).RateConstants = k_outFitted;
    fullSummary.(['k',num2str(j)]).PredictedData = dataPred;
    fullSummary.(['k',num2str(j)]).ResidualMatrix = resMatrix;
    fullSummary.(['k',num2str(j)]).DAS = DAS;
    fullSummary.(['k',num2str(j)]).ExponentialDecay = expTime;
    fullSummary.(['k',num2str(j)]).Delta = deltaFitted;
    fullSummary.(['k',num2str(j)]).TzOffset = tzOffsetFitted;
    fullSummary.(['k',num2str(j)]).Residual = res;
    fullSummary.(['k',num2str(j)]).ResidualNorm = res./sum(sum(data*scaleFactor.^2));
    fullSummary.(['k',num2str(j)]).kOutput = kOutput;
    fullSummary.(['k',num2str(j)]).kScaler = kScaler;
    
    if opt.plotR
        if j == 1 
            residualMatrix = zeros(size(resMatrix,1),size(resMatrix,2),numK); 
            previousDataPred = zeros(size(dataPred));
        
            YLabel1 = 'Signal';
            YLabel2 = 'Normalized';
            YLabel3 = wave_str;
        else
            YLabel1 = [];
            YLabel2 = [];
            YLabel3 = [];
        end
        plot_color = f_ColorPicker(size(DAS,2),'type','qualitative');
        
        DAS_p = f_AveTrace(DAS,5);
        wave_p = f_AveTrace(wave,5);
        f_Plot(DAS_p, wave_p, h(j), 'Ylabel', YLabel1,...
            'RescaleData',0,'XLabel',wave_str,'PlotStyles',plot_color,'LineStyle','-','PointStyle','');
        title(h(j),['Fit ',num2str(j)],'FontWeight','bold','FontSize', 11);
        f_Plot(expTime, time, [h(2*j-1 + numK), h(2*j + numK)], 'Ylabel',...
            YLabel2,'removeXTick',1,'PlotStyles',plot_color,...
            'Xlabel','','RescaleData',0,'PointStyle','','LineStyle','-');
        
        f_Plot(dataPred-previousDataPred, time, wave, [h(2*j-1 + numK*3), h(2*j + numK*3)],...
            'colorbar',0, 'JetBar', 0,'removeXTick',1,'XLabel','','YLabel',YLabel3,'RescaleData',0,'FlipX',0);
        f_Plot(dataPred, time, wave, [h(2*j-1 + numK*5), h(2*j + numK*5)],'colorbar',0,...
            'JetBar', 0,'removeXTick',1,'XLabel','','RescaleData',0,'YLabel',YLabel3,'FlipX',0);
        residualMatrix(:,:,j) = resMatrix;
        previousDataPred = dataPred;
        pause(0.5);
    end
    
end
%% Adds fitsummary  to full summary
fullSummary.fitSummary = fitSummary;

%% Plots result of fitting
if opt.plotR
    %% Running Plots
    f_JetBar( 'allAxes', h(3*numK + 1: 7*numK),'commonClim',1); % recolor all surfaces to same scale
    %% Plots surface and residuals from combininh multiple components
    cLimits = get(h(3*numK+1 ), 'cLim');
    resMin = min(min(min(residualMatrix)));
    resMax = max(max(max(residualMatrix)));
    
    residualMatrix(residualMatrix < 0) = residualMatrix(residualMatrix < 0).*cLimits(1)./resMin;
    residualMatrix(residualMatrix > 0) = residualMatrix(residualMatrix > 0).*cLimits(2)./resMax;
    cLimits = cLimits./opt.resSqueeze;
    for n = 1 : numK
        if n == 1
            YLabel = wave_str;
        else
            YLabel = [];
        end
        hIndex = n*2-1 + 7*numK;
        f_Plot(residualMatrix(:,:,n), time, wave, [h(hIndex);h(hIndex+1)], 'colorbar', 0,...
            'ZLim', cLimits,'RescaleData',0,'YLabel',YLabel,'FlipX',0);
    end
    
    %% Results of fit
    % Plotting Variables
    colorPicker = hsv(numK);
    traceLabel = [{'fit one'},'fit two', 'fit three', 'fit four', 'fit five', 'fit six', 'fit seven'];
    
    if ishandle(opt.plotR+1), clf(opt.plotR+1); end
    scnsize = get(0,'ScreenSize');
    rH = figure(opt.plotR+1);
    set(rH,'color','w','OuterPosition',[scnsize(3)/2,scnsize(4)/2,scnsize(4)/2*1.618,scnsize(4)/2]);
    
    if length(tzOffset) > 1 || length(delta) > 1
        rowStyles = [{'Linear'};'Linear'];
    else
        rowStyles = {'Linear'};
    end
    
    [ h, figure_handles(2) ] = f_MultiLinLogAxes( 2, rH, 'rowStyles', rowStyles,...
        'title',['Global Fit Results for ',opt.name,' with ',num2str(numK),' Fits'],...
        'yPadding',80,'yBottomOffset',-30,'yTopOffset',30,...
        'xPadding',70);
    
    
    % unique colours for each fit attemp, x and y axis will be a bit random
    ps = f_ColorPicker(size(fitSummary,1));
    
    numK = fitSummary(:,1:end-3) > 0;
    numK = sum(numK,2);
    xLim = [min(numK)-1, max(numK)+1];
    xTick =  [min(xLim):max(xLim)];
    % Plot of Residuals at each k
    for jp = 1 : size(ps,1)
        if jp == 1
            hold(h(1),'off');
        else
            hold(h(1),'on');
        end
        
        sh = scatter(h(1), numK(jp), fitSummary(jp,end), 100,'filled', 'CData', ps(jp,:));
    end
    
    set(h(1), 'xlim', xLim, 'xtick',xTick);
    ylabel(h(1), 'sum square residual');
    xlabel(h(1), 'number of lifetimes fitted');
    title(h(1), 'Sum of residuals squared','FontWeight','bold','FontSize', 11);
    grid(h(1), 'on');
    
    % Plot of time constants at each k
    size_mark = [5:1.5/size(ps,1):16];
    size_mark = fliplr(size_mark(1:size(ps,1)))./2;
    size_mark = size_mark.^2;
    
    for n = 1 : size(ps,1)
        if n == 1
            hold(h(2), 'off'),
        else
            hold(h(2), 'on'),
        end
        
        if mod(n,2) == 1
            makers_u = 'o';
        else
            makers_u = '^';
        end
        
        
        ph_h = plot(h(2), 1:numK(n), 1./fitSummary(n,1:numK(n)),'LineWidth',2.5,...
            'LineStyle','none', 'MarkerSize', size_mark(n),'Marker', makers_u, 'color', ps(n,:));
        
    end
    
    set(h(2), 'YScale', 'log', 'xlim', [0,max(numK)+1], 'xtick', [0:max(numK)+1]);
    ylabel(h(2), 'time constant (s)');
    xlabel(h(2), 'time constant');
    legend(h(2), traceLabel(1:size(ps,1)), 'Location', 'SouthEast');
    title(h(2), 'Lifetimes for multiple fits','FontWeight','bold','FontSize', 11)
    grid(h(2), 'on');
    
    if length(tzOffset) > 1 || length(delta) > 1
        
        % Plot of time offsets at each k
        tz = fitSummary(:,end-1);
        if max(abs(tz)) < 1E-11
            ylab = 'time (fs)';
            tz = tz.*1E15;
        elseif max(abs(tz)) < 1E-10
            ylab = 'time (ps)';
            tz = tz.*1E12;
        else
            ylab = 'time (ns)';
            tz = tz.*1E9;
        end
        
        for n = 1 : size(ps,1)
            if n == 1
                hold(h(3), 'off'),
            else
                hold(h(3), 'on'),
            end
            sh = scatter(h(3), numK(n), tz(n), 100,'filled', 'CData', ps(n,:));
        end
    
        
        set(h(3), 'xlim', xLim, 'xtick', xTick);
        ylabel(h(3), 'time (s)');
        xlabel(h(3), 'number of lifetimes fitted');
        title(h(3), 'Time offset','FontWeight','bold','FontSize', 11)
        grid(h(3), 'on');
        ylabel(h(3), ylab);
        
        % Plot of IRF at each k
        IRF = fitSummary(:,end-2);
        if max(IRF) < 1E-11
            ylab = 'time (fs)';
            IRF = IRF.*1E15;
        elseif max(IRF) < 1E-10
            ylab = 'time (ps)';
            IRF = IRF.*1E12;
        else
            ylab = 'time (ns)';
            IRF = IRF.*1E9;
        end
            
        
        for n = 1 : size(ps,1)
            if n == 1
                hold(h(4), 'off'),
            else
                hold(h(4), 'on'),
            end
            sh = scatter(h(4), numK(n), IRF(n), 100,'filled', 'CData', ps(n,:));
        end
        
        set(h(4), 'xlim', xLim, 'xtick', xTick);
        xlabel(h(4), 'number of lifetimes fitted');
        title(h(4), 'IRF','FontWeight','bold','FontSize', 11)
        grid(h(4), 'on');
        ylabel(h(4), ylab);
    end
end
end






