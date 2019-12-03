function [ios]=rModel_notClamped(coef,time,stim,~,varargin)
% function [ios]=rmodel(coef,time,stim,gdark)
% Modified May_2015 Angueyra
% Hopefully final take on model. Decided:
% 1) cur2ca = 0.03 (based on fits to saccade trajectory) and then
% beta = cur2ca * (cgmp2cur * gdark^cgmphill) / cdark; 
% 2) cgmp2cur = 10e-3 for vhmodel but cgmp2cur = 20e-3 for rieke model
% (since in darkness, cslow cuts cdark by half
% 3) sigma = phi (previous fitting didn't show much advantage to make them
% distinct)

if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

% cdark            
% gdark;			% concentration of cGMP in darkness

% hillaffinity = coef(1);		% affinity for Ca2+ (~0.5*dark Calcium)
% sigma = coef(2);			% rhodopsin activity decay rate constant (1/sec) ()
% phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
% eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% % eta/phi~duration of response (50ms) (main determinant of response kinetics)
% gdark= coef(4);
% betaSlow=coef(5);


% rescaling to get parameters into similar ranges
hillaffinity = coef(1)/1000;		% affinity for Ca2+ (~0.5*dark Calcium)
sigma = coef(2)/10;			% rhodopsin activity decay rate constant (1/sec) ()
phi = sigma;              % phosphodiesterase activity decay rate constant (1/sec) ()
eta = coef(3);				% phosphodiesterase activation rate constant (1/sec) ()
% eta/phi~duration of response (50ms) (main determinant of response kinetics)
gdark= coef(4)/10;
betaSlow=coef(5)/100;



% Fixed parameters
hillcoef = 4;			% effective Ca2+ cooperativity to GC (2-4)
cdark=1;%0.5; % dark calcium concentration (in uM) <1uM (~300 -500 nM)
cgmphill=3;


hillslow=3;
slowboost=1;

% cgmp2cur = 20e-3;%8e-3;		% constant relating cGMP to current
cgmp2cur = 10e-3*((slowboost+1).^hillslow);%8e-3;		% constant relating cGMP to current
% gdark and cgmp2cur trade with each other to set dark current
% cur2ca = 0.1716;
% cur2ca = 0.15;%0.03;
% beta = cur2ca * (cgmp2cur * gdark^cgmphill) / cdark; % rate constant for calcium removal in 1/sec (tau>10ms)
beta=9;
cur2ca = beta / ((cgmp2cur * gdark^cgmphill) / cdark); % rate constant for calcium removal in 1/sec (tau>10ms)

smax = eta/phi * gdark * (1 + (cdark / hillaffinity)^hillcoef);		% get smax using steady state


opsin_gain=10; %so stimulus can be in R*/sec (this is rate of increase in opsin activity per R*/sec)
% opsin_gain=1;

clear g s c p r
NumPts=length(time);
TimeStep=time(2)-time(1);

%initializing variables
r = NaN(1,NumPts);
p = NaN(1,NumPts);
c = NaN(1,NumPts);
cslow = NaN(1,NumPts);
s = NaN(1,NumPts);
g = NaN(1,NumPts);

% initial conditions
g(1) = gdark;
s(1) = gdark * eta/phi;		
c(1) = cdark;
p(1) = eta/phi;
r(1) = 0;
cslow(1) = cdark;



% solve difference equations
for pnt = 2:NumPts
	r(pnt) = r(pnt-1) + TimeStep * (-sigma * r(pnt-1));
%     Adding Stim
    r(pnt) = r(pnt) + (stim(pnt)*opsin_gain);
	p(pnt) = p(pnt-1) + TimeStep * (r(pnt-1) + eta - phi * p(pnt-1));
% 	c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill - beta * c(pnt-1));
    c(pnt) = c(pnt-1) + TimeStep * (cur2ca * cgmp2cur * g(pnt-1)^cgmphill /((slowboost+(cslow(pnt-1)/cdark))^hillslow) - beta * c(pnt-1));
    cslow(pnt) = cslow(pnt-1) - TimeStep * (betaSlow * (cslow(pnt-1)-c(pnt-1)));
	s(pnt) = smax / (1 + (c(pnt) / hillaffinity)^hillcoef);
	g(pnt) = g(pnt-1) + TimeStep * (s(pnt-1) - p(pnt-1) * g(pnt-1));
end
% determine current change
% ios = cgmp2cur * g.^cgmphill * 2 ./ (2 + cslow ./ cdark);
ios = -cgmp2cur * g.^cgmphill * 1 ./ (slowboost + (cslow ./ cdark)).^hillslow;




% display all model parameters
if nargin == 5
    verbose=varargin{1};
    if verbose
        fprintf ('Fit paramaters for riekeModel are:\n')
        fprintf('\tsigma\t\t=\t%g\n',sigma)
        fprintf('\tphi\t\t=\t%g\n',phi)
        fprintf('\teta\t\t=\t%g\n',eta)
        fprintf('\tk\t\t=\t%g\n',cgmp2cur)
        fprintf('\th\t\t=\t%g\n',cgmphill)
        fprintf('\tbeta\t\t=\t%g\n',beta)
        fprintf('\tq\t\t=\t%g\n',cur2ca)
        fprintf('\tsmax\t\t=\t%g\n',smax)
        fprintf('\tKgc\t\t=\t%g\n',hillaffinity)
        fprintf('\tm\t\t=\t%g\n',hillcoef)
        fprintf('\tbeta slow\t=\t%g\n',betaSlow)
        fprintf('\thill slow\t=\t%g\n',hillslow)
        fprintf('\tCadark\t\t=\t%g\n',cdark)
        fprintf('\tcGMPdark\t=\t%g\n',gdark)
    end
end

end

