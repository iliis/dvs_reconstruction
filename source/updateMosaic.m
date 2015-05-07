function [gradients, covariances, lastSigs, lastPos] = updateMosaic(u, v, pol, timestamp, theta, gradients, covariances, lastSigs, lastPos)

% This function an event and updates the mosaic, gradients, covariances and
% history with an EKF

assert(pol == 1 || pol == -1, 'polarity signal error');

C = pixelIntensityThreshold(); %0.22 - log intensity change that causes an event
R = measurementNoise(); %DUMMY - measurement noise

% compute tau
tau = double(timestamp - lastSigs(v, u));

%compute pixel in global image space
% invKP = invKPs(:, v, u); 
% deltaAlpha = atan(cos(-theta(3))*invKP(2) + sin(-theta(3))*invKP(1));
% deltaBeta  = atan(cos(-theta(3))*invKP(1) - sin(-theta(3))*invKP(2));

% targetP = [-theta(2) + deltaBeta, -theta(1) + deltaAlpha]; 

%         compute coordinates in gradient map
% p = targetP * size(gradients, 3)/(2*pi);


% p = [-(theta(2) + deltaBeta)*size(gradients, 3)/(2*pi) , (theta(1) + deltaAlpha) * size(gradients, 3)/(2*pi)];
% pmt = round(p + ([size(gradients, 3), size(gradients, 2)] ./ 2))';

pmt = round(cameraToWorldCoordinates(u,v,cameraIntrinsicParameterMatrix(),theta,[size(gradients,2),size(gradients,3)]));
pmt = [pmt(2); pmt(1)];

% get last position of this pixel
pmTau = lastPos(:, v, u);

% compute speed
velocity = (pmt - pmTau) ./ tau;

% get global pixel gradient from matrix
gTau = gradients(:, pmt(2), pmt(1));

z = 1/tau;

h = (gTau' * velocity) / (pol*C); %different from paper - possible bugfix??

% compute innovation
nu = z - h;

% compute dh/dg - formula 15
% dhdg = [velocity(2) velocity(1)] ./ C;
dhdg = pol * velocity' ./ C;

% get covariances from matrix
PgTau = covariances(:,:,pmt(2),pmt(1));

% compute innovation covariance
S = dhdg * PgTau * dhdg' + R;

% compute Kalman gain
W = PgTau * dhdg' ./ S;

% compute updated covariance
% Pgt = PgTau - (W * S * W');
Pgt = PgTau - (PgTau * dhdg' * W'); % try to avoid numerical errors

% compute updated gradient
gt = gTau + (W * nu);

if sum(isnan(gt)) > 0
    fprintf('gradient is NaN (updateMosaic)\n');
    u
    v
    pol
%     theta
    tau
    timestamp
%     lastSigs(v, u)
%     pmt
%     pmTau
%     velocity
%     gTau
%     z
%     h
%     nu
%     dhdg
%     PgTau
%     S
%     W
%     Pgt
%     gt
%     pause(0.1);
    return;
end

% update matrices
covariances(:,:,pmt(2),pmt(1)) = Pgt;
gradients(:,pmt(2),pmt(1)) = gt;
lastSigs(v, u) = timestamp;
lastPos(:,v,u) = pmt;

return;