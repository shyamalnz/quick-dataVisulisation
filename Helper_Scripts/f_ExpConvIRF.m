function [ result ] = f_ExpConvIRF( time, k, tzOffset, Delta,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

opt.replaceNaN = 1;
opt.BiMol = [0];

% user input (after autodetection to allow user options)
[opt] = f_OptSet(opt, varargin);

if length(opt.BiMol) < length(k)
    opt.BiMol = repmat(opt.BiMol,ceil(length(k)/length(opt.BiMol)),1);
end

DeltaT = Delta/(2*((2*log(2)))^.5);


biK = find(opt.BiMol==1);
moK = find(opt.BiMol==0);
biK(biK > length(k)) = [];
moK(moK > length(k)) = [];
result = zeros(length(time),length(k),length(Delta),length(tzOffset));

if ~isempty(biK)
    if length(tzOffset) == 1 && length(Delta) == 1
        result(:,biK,:,:) = BIMoConIRFMu( time, k(biK), tzOffset, Delta);
    else
        parfor n = 1 : length(tzOffset)
            A = arrayfun(@(x) BIMoConIRFMu(time,k(biK),tzOffset(n),x),Delta,'UniformOutput',0);
            result(:,biK,:,n) = cat(3,A{:});
        end
    end
end

if ~isempty(moK)
    if length(tzOffset) == 1 && length(Delta) == 1
        result(:,moK,:,:) = EXPconIRFMu( time, k(moK), tzOffset, DeltaT);
    else
        parfor n = 1 : length(tzOffset)
            A = arrayfun(@(x) EXPconIRFMu(time,k(moK),tzOffset(n),x),DeltaT,'UniformOutput',0);
            result(:,moK,:,n) = cat(3,A{:});
        end
    end
end

if any(size(result) == 1)
    result = squeeze(result);
end

if opt.replaceNaN
    result(isnan(result)) = 0;
end

end

function [ y ] = EXPconIRFMu( t, kInput, tzOffset, DeltaT)


y = ones(length(t),length(kInput));
if length(kInput) > 1
    parfor n = 1 : length(kInput)
        k = kInput(n);
        y(:,n) = ((0.5.*exp(-k.*(t-tzOffset)))).*((exp(k*(0+((k*DeltaT^2)/2))))*(1 + erf(((t-tzOffset)-(0+(k*DeltaT^2)))/(1.41421356237*DeltaT))));
        %y(:,n) = ((0.5.*exp(-k.*(tzOffset-t)))).*((exp(k*(0+((k*DeltaT^2)/2))))*(1 + erf(((tzOffset-t)-(0+(k*DeltaT^2)))/(1.41421356237*DeltaT))));
    end
else
    k = kInput;
    y = ((0.5.*exp(-k.*(t-tzOffset)))).*((exp(k*(0+((k*DeltaT^2)/2))))*(1 + erf(((t-tzOffset)-(0+(k*DeltaT^2)))/(1.41421356237*DeltaT))));
    %y = ((0.5.*exp(-k.*(tzOffset-t)))).*((exp(k*(0+((k*DeltaT^2)/2))))*(1 + erf(((tzOffset-t)-(0+(k*DeltaT^2)))/(1.41421356237*DeltaT))));
end

end

function [ y ] = BIMoConIRFMu( t, kInput, tzOffset, FWHM)
t = t-tzOffset;

[~,tIndex] = min(abs(t - FWHM*10));
tShort = [linspace(-1*t(tIndex),t(tIndex),200)]';
gau = f_Gaussian( tShort, FWHM, 0, 1);
gau(gau<1E-10) = [];
gau = gau./sum(gau);
tShort2 =tShort(length(gau):end-length(gau));
tIndex = find(t < tShort2(end),1,'last');
tLong = t(tIndex:end);
yLong = ones(length(tLong),length(kInput));
yShort = ones(length(tShort),length(kInput));
zeroIndex = find(tShort<=0);
zeroIndex = zeroIndex(end);

if length(kInput) > 1
    parfor n = 1 : length(kInput)
        k = kInput(n);
        yLong(:,n) = 1./(1+k.*tLong);
        yLong(:,n) = 1./(1+k.*tLong)./max(yLong(:,n));
        yShort(:,n) = 1./(1+k.*tShort);
    end
else
    n = 1;
    k = kInput(n);
    yLong(:,n) = 1./(1+k.*tLong);
    yLong(:,n) = 1./(1+k.*tLong)./max(yLong(:,n));
    yShort(:,n) = 1./(1+k.*tShort);
end

yShort(1:zeroIndex,:) = 0;
yShort = bsxfun(@rdivide,yShort,max(yShort));
yShort = conv2(gau,1,yShort,'same');
yShort = yShort(length(gau):end-length(gau),:);
yShort = interp1(tShort2,yShort,t(1:tIndex));
yShort(isnan(yShort)) = 0;
yLong = bsxfun(@times,yShort(end,:),yLong);

y = [yShort; yLong(2:end,:)];
end

function [ y ] = EXPconIRFMu2( t, kInput, tzOffset, FWHM)
t = t-tzOffset;

[~,tIndex] = min(abs(t - FWHM*10));
tShort = [linspace(-1*t(tIndex),t(tIndex),200)]';
gau = f_Gaussian( tShort, FWHM, 0, 1);
gau(gau<1E-10) = [];
gau = gau./sum(gau);
tShort2 =tShort(length(gau):end-length(gau));
tIndex = find(t < tShort2(end),1,'last');
tLong = t(tIndex:end);
yLong = ones(length(tLong),length(kInput));
yShort = ones(length(tShort),length(kInput));
zeroIndex = find(tShort<=0);
zeroIndex = zeroIndex(end);

if length(kInput) > 1
    parfor n = 1 : length(kInput)
        k = kInput(n);
        yLong(:,n) = exp(-k*tLong);
        yLong(:,n) = yLong(:,n)./max(yLong(:,n));
        yShort(:,n) = exp(-k*tShort);
    end
else
    n = 1;
    k = kInput(n);
    yLong(:,n) = exp(-k*tLong);
    yLong(:,n) = yLong(:,n)./max(yLong(:,n));
    yShort(:,n) = exp(-k*tShort);
end

yShort(1:zeroIndex,:) = 0;
yShort = bsxfun(@rdivide,yShort,max(yShort));
yShort = conv2(gau,1,yShort,'same');
yShort = yShort(length(gau):end-length(gau),:);
yShort = interp1(tShort2,yShort,t(1:tIndex));
yShort(isnan(yShort)) = 0;
yLong = bsxfun(@times,yShort(end,:),yLong);

y = [yShort; yLong(2:end,:)];
end