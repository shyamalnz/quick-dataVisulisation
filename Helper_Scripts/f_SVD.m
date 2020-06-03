function [ Kinetics,S,Spectra,diagS,handle_fig] = f_SVD( data, time, wave, varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% Sets Options
opt.fig = 2;
opt.NumS = 20;
opt.NumPlotted = 4;
opt.showPlots = 1;
opt.inverse = 0;
opt.RePositionPlots = 1;
opt.resSqueeze = 10;
opt.name = 'UNNAMED';
opt.FontSize = 11;

% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

%%
FontPixelRatio = 3.6364;


%%
[U,S,V] = svd(data);
diagS = diag(S);

if opt.inverse
    U = U.*-1;
    V = V.*-1;
end
if max(wave) > 1200
    wave = wave/1000;
    wave_str = 'Wavelength (\mum)';
    flip_surf = 0;
elseif max(wave) < 10
    wave_str = 'Photon Energy (eV)';
    wave_str = 'h\nu (eV)';
    flip_surf = 1;
else
    wave_str = 'Wavelength (nm)';
end

uMax = max(U);
uMin = min(U);
sign = ones(size(uMax));
sign(abs(uMin) > uMax) = -1;
U = bsxfun(@times,U,sign);
len = min(size(V,1),length(sign));
V(:,1:len) = bsxfun(@times,V(:,1:len),sign(1:len));
    
%% Scales data for plotting (normalized kinetics - then rescales spectra and multiples by S)
diagSScalled = diagS(1:opt.NumPlotted,1);
UScalled = U(:,1:opt.NumPlotted); %kinetics
VScalled = V(:,1:opt.NumPlotted); %spectra
UMax = max(abs(UScalled));
UScalled = bsxfun(@rdivide,UScalled,UMax);
VScalled = bsxfun(@times,VScalled,UMax.*diagSScalled');
UMax = max(max(UScalled));
UMin = min(min(UScalled));
    
%% Analysis Plots
if opt.showPlots
    %% Makes figure window
    scnsize = get(0,'ScreenSize');
    scatterFh = figure(opt.fig);
    set(scatterFh,'color','w','OuterPosition',[scnsize(3)/2,scnsize(4)/2,scnsize(4)/2*1.618,scnsize(4)/2]);
    clf(scatterFh);
    scatterAx = axes;
    scatter(scatterAx,1:opt.NumPlotted,diagS(1:opt.NumPlotted));
    hold(scatterAx, 'on')
    scatter(scatterAx, opt.NumPlotted+1:opt.NumS,diagS(opt.NumPlotted+1:opt.NumS));
    grid(scatterAx, 'on')
    hold(scatterAx, 'off')
    legend(scatterAx,[{'Analysed'},'Ignored'])
    title(scatterAx,['Weighting of SVD componets from ', opt.name],'FontWeight','bold','FontSize', opt.FontSize)
    xlabel(scatterAx,'Component Number');
    ylabel(scatterAx,'Weighting');
    set(scatterAx,'YScale','Log');
    
    rowStyles = [{'Linear'};'LinLog';'LinLog';'LinLog';'LinLog'];
    if ~isempty(opt.name)
        Title = [opt.name,' - ',num2str(opt.NumPlotted),' Components SVD'];
    else
        Title = [];
    end
    LeftLabel =fliplr({'Residaul',{'Additive','U*(1:n)\timesV*(1:n)'},{'Single','U*(n)\timesV*(n)'},'Kinetics (U*)', 'Spectra (V*)'});
    
    FontUnit = opt.FontSize*FontPixelRatio;
    yTen = FontUnit*0.2;
    yPadding = [FontUnit*1.1+yTen,yTen,yTen,yTen,FontUnit*1.25,FontUnit+yTen/2];
    
    xPadding = FontUnit*0.8;
    xLeftOffset = FontUnit*1.45 + 20;
    xRightOffset = FontUnit*1.55 + 50;
    [h, fh, positions] = f_MultiLinLogAxes( opt.NumPlotted, opt.fig+1,...
        'rowStyles', rowStyles,'title',Title,'yTopOffset',30,'yPadding',yPadding,...
        'xPadding',xPadding,'xLeftOffset',xLeftOffset,'FontSize',opt.FontSize,...
        'LeftLabel',LeftLabel,'yBottomOffset',0,'yTopOffset',0,'external_labels',1,...
        'LeftLabelOffset',FontUnit*0.5,'xRightOffset',xRightOffset);
    
    font_scaled = h(1).FontSize;
    
    handle_fig = [
        scatterFh
        fh
        ];
    %% Plots each components contributions
    residual = zeros(size(data,1),size(data,2),opt.NumPlotted);
    
    
   max_value = max(abs(VScalled(:)));
   SI_Scalar = floor(log10(max_value));
   
   zLim = f_zLim(data)*1.2;
   
   for n = 1 : opt.NumPlotted
        %%
        flip_surf = 0;
       
       %%
        if n == 1
           YLabel1 = 'Signal'; 
           YLabel2 = 'Normalized'; 
           YLabel3 = wave_str;
        else
           YLabel1 = []; 
           YLabel2 = []; 
           YLabel3 = []; 
        end
        
        if n == opt.NumPlotted
            colorbar = 1;
        else
            colorbar = 0;
        end
        
        max_value = max(abs(VScalled(:,n)));
        SI_Scalar_Local = floor(log10(max_value));
        scalar = 10^SI_Scalar_Local;
        if max_value/scalar < 1.4
            scalar = scalar/10;
        end
        SI_string = ['\times10^{',num2str(log10(scalar)),'}'];
        
        
        f_Plot(VScalled(:,n)./scalar, wave, h(n), 'YLabel', YLabel1,'RescaleData',0,'XLabel',wave_str,...
            'MarkerSize',4/11*opt.FontSize,'LineStyle','-','PointStyle','','LineWidth',2/11*opt.FontSize);
        title(h(n),['Component ',num2str(n),' (',SI_string,')'],...
            'FontWeight','bold','FontSize', font_scaled*1.2);
        hIndex = n*2-1 + opt.NumPlotted;
        f_Plot(UScalled(:,n), time, [h(hIndex);h(hIndex+1)], 'title',[],'Ylabel', YLabel2,...
            'YLim', [UMin UMax]*1.1,'removeXTick',1,'Xlabel','','RescaleData',0,'MarkerSize',4/11*opt.FontSize,...
            'LineStyle','-','PointStyle','','LineWidth',2/11*opt.FontSize);
        %% Single
        hIndex = n*2-1 + 3*opt.NumPlotted;
        dataPred = VScalled(:,n)*UScalled(:,n)';
        f_Plot(dataPred, time, wave, [h(hIndex);h(hIndex+1)], 'colorbar', colorbar,'removeXTick',1,'XLabel','','YLabel',YLabel3,...
            'FlipX',flip_surf,'SI_Scalar',SI_Scalar,'ShrinkAxes',0,'zLim',zLim);
        
        %% Additive
        hIndex = n*2-1 + 5*opt.NumPlotted;
        dataPred = U(:,1:n)*S(1:n,1:n)*V(:,1:n)';
        f_Plot(dataPred, time, wave, [h(hIndex);h(hIndex+1)], 'colorbar', colorbar,'removeXTick',1,'XLabel','','YLabel',YLabel3,...
            'FlipX',flip_surf,'SI_Scalar',SI_Scalar,'ShrinkAxes',0,'zLim',zLim);  
        
        %% Residual
        hIndex = n*2-1 + 7*opt.NumPlotted;
        zLabel = ['\DeltaT/T (\times10^{',num2str(SI_Scalar-1),'})'];
        f_Plot((data - dataPred)*10, time, wave, [h(hIndex);h(hIndex+1)], 'colorbar', colorbar,'YLabel',YLabel3,...
            'FlipX',flip_surf,'SI_Scalar',SI_Scalar,'ShrinkAxes',0,'zLim',zLim,'zLabel',zLabel,'updateZLabel',0);  
        
        residual(:,:,n) = data - dataPred;
        pause(0.1)
   end
   
    %% Remove all labels with a dot in them
    h_check = h(opt.NumPlotted+1:end);
    h_check = h_check(1:2:end);
    for n = 1:length(h_check)
        remove = ~cellfun(@isempty,regexp(h_check(n).YTickLabel ,'\d\.\d'));
        h_check(n).YTickLabel(remove) = {''};
    end
    
    %% Add in color bar scale
    
end
Kinetics = UScalled;
Spectra = VScalled';