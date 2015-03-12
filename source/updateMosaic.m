function [gradients, covariances, lastSigs, lastPos] = updateMosaic(u, v, pol, timestamp, theta, K, gradients, covariances, lastSigs, lastPos)

% This function an event and updates the mosaic, gradients, covariances and
% history with an EKF

C = pixelIntensityThreshold(); %DUMMY - log intensity change that causes an event
R = 1; %DUMMY - measurement noise

% debug output
% u
% v
% theta
% timestamp

% compute tau and update last signal matrix
tau = timestamp - lastSigs(v, u);
lastSigs(v, u) = timestamp;

%compute pixel in global image space
invKP = K \ [u v 1]';
deltaAlpha = atan(cos(-theta(3))*invKP(2) + sin(-theta(3))*invKP(1));
deltaBeta = -atan(cos(-theta(3))*invKP(1) - sin(-theta(3))*invKP(2));
p = [(theta(2) + deltaBeta)*size(gradients, 3)/(2*pi) , (theta(1) + deltaAlpha) * size(gradients, 3)/(2*pi)];
pmt = round(p + ([size(gradients, 3), size(gradients, 2)] ./ 2))';
pmTau = lastPos(:, v, u);

% compute speed
velocity = (pmt - pmTau) ./ tau;

% get global pixel gradient from matrix
gTau = gradients(:, pmt(2), pmt(1));

z = 1/tau;

h = (gTau' * velocity) / C;

% compute innovation
nu = z - h;

% compute dh/dg - formula 15
dhdg = [velocity(2) velocity(1)] ./ C;

% get covariances from matrix
PgTau = covariances(:,:,pmt(2),pmt(1));

% compute innovation covariance
S = dhdg * PgTau * dhdg' + R;

% compute Kalman gain
W = PgTau * dhdg' / S;

% compute updated covariance
Pgt = PgTau - W * S * W';

% compute updated gradient
gt = gTau + W * nu;

if sum(isnan(gt)) > 0
    fprintf('gradient is NaN\n');
    return;
end

% update matrices
covariances(:,:,pmt(2),pmt(1)) = Pgt;
gradients(:,pmt(2),pmt(1)) = gt;

% fprintf('updating gradients(%d, %d) = [%f, %f]\n', pmt(2), pmt(1), gt(1), gt(2));
% pause(1)

return;