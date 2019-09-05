function response = cModelBi_Ky_clamped(coeffs,time,stim,dt,varargin)

% % normal one
% tauy = coeffs(1);
% tauz = coeffs(2);
% ny = coeffs(3);
% nz = coeffs(4);
% gamma = coeffs(5);
% tauR = coeffs(6);
% alpha = coeffs(7);
% beta = coeffs(8);
% gamma2 = coeffs(9);
% tauzslow = coeffs(10);
% nzslow = coeffs(11);

% best fit to dim-flash response without feedback
%     tauy = 29 / 10000;
%     ny = 367 / 100;
%     tauR = 275 / 10000;
% obtained from full model fit to stj, which looks like fast dim-flash response without weird hump
    tauy = 45 / 10000;
    ny = 433 / 100;
    tauR = 48 / 10000;
    

% trying to bring coefficients to similar units (1-1000)
    tauz = coeffs(1) / 1000;
    nz = coeffs(2) / 100;
    gamma = coeffs(3) / 1000;
    alpha = coeffs(4) / 10;
    beta = coeffs(5) / 1000;
    gamma2 = coeffs(6) / 1000;
    tauzslow = coeffs(7) / 1000;
    nzslow = coeffs(8) / 100;
    
if size(time)~=size(stim)
    error('Time and stimulus have to be the same size');
end

    FiltY = (time/tauy).^ny .*...
        exp(-time/tauy);
    FiltZ = gamma * FiltY +...
        (1-gamma-gamma2) * (time/tauz).^nz .* exp(-time/tauz) +...
        gamma2 * (time/tauzslow).^nzslow .* exp(-time/tauzslow);
%    FiltZ = gamma * FiltY + (1-gamma) * (time/tauz).^nz .* exp(-time/tauz);
    
    r = zeros(1, length(stim));
    y = real(ifft(fft(stim) .* fft(FiltY)))*dt;
    z = real(ifft(fft(stim) .* fft(FiltZ)))*dt;

    for t = 1:length(time)-1
        r(t+1) = r(t) + (dt / tauR)*(alpha*y(t) - (1 + beta*z(t))*r(t));
    end
    response = r;
    

% print model parameters to command
if nargin == 5
    verbose=varargin{1};
    if verbose
        fprintf('\n')
        fprintf ('ccoeffs =[...\n')
        fprintf('\t%02.3f ... \ttauy\n',tauy)
        fprintf('\t%02.3f ... \ttauz\n',tauz)
        fprintf('\t%02.3f ... \tny\n',ny)
        fprintf('\t%02.3f ... \tnz\n',nz)
        fprintf('\t%02.3f ... \tgamma\n',gamma)
        fprintf('\t%02.3f ... \ttauR\n',tauR)
        fprintf('\t%02.3f ... \talpha\n',alpha)
        fprintf('\t%02.3f ... \tbeta\n',beta)
        fprintf('\t%02.3f ... \tgamma2\n',gamma2)
        fprintf('\t%02.3f ... \ttauz_slow\n',tauzslow)
        fprintf('\t%02.3f ... \tnz_slow\n',nzslow)
        fprintf('];\n')
        fprintf('\n')
    end
end
    
    
