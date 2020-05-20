function [ expTime ] = f_ConvConcentrations(time, k, delta, concScaler)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


opt.interpNum = 10000;
opt.FWHM = delta;


timeInterp = interp1q(time,time,linspace(time(1),time(end),opt.interpNum-300)');
timeInterp = [timeInterp; [[1:300]*(timeInterp(end)-timeInterp(end-1))+timeInterp(end)]'];


initalFrac = concScaler(1);
ket = k(1);
k1 = k(2); %decay time of donor (without acceptor)
k2 = k(3);

c1 = initalFrac*exp((-k1-ket).*timeInterp);
c2 = (exp(-k2.*timeInterp).*( -(1-initalFrac)*k1 + (1-initalFrac)*k2 - ket + initalFrac*exp(k2.*timeInterp + (-k1-ket).*timeInterp)*ket))...
    /(-k1+k2-ket);

c2(timeInterp<0) = 0;
c1(timeInterp<0) = 0;

IRF = f_Gaussian( timeInterp, opt.FWHM, 0, 1);
IRF = IRF(IRF>0);

c1con = conv(c1,IRF,'same');
c2con = conv(c2,IRF,'same');

c1use = interp1q(timeInterp,c1con,time);
c2use = interp1q(timeInterp,c2con,time);

expTime = [c1use, c2use];
end

