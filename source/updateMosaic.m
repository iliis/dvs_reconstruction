function [gradients, covariances, lastSigs, lastPos] = updateMosaic(u, v, pol, timestamp, theta, gradients, covariances, lastSigs, lastPos)
% function [gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos] = updateMosaic(u, v, pol, timestamp, theta, gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos)

% This function an event and updates the mosaic, gradients, covariances and
% history with an EKF

% get global parameters - TODO: maybe put this as inut argument?
params = getParameters();

assert(pol == 1 || pol == -1, sprintf('polarity signal error: pol = %d', pol));

C = params.pixelIntensityThreshold;
R = params.measurementNoise;

% compute tau
tau = double(timestamp - lastSigs(v, u));

% get last position of this pixel
pmTau = lastPos(:, v, u);

pmt = cameraToWorldCoordinates(u,v,params.cameraIntrinsicParameterMatrix,theta,params.outputImageSize);
idx = round(pmt);
pmt = pmt';

% compute speed
velocity = (pmt - pmTau) ./ tau;

% get global pixel gradient from matrix
gTau = gradients(:, idx(1), idx(2));

z = 1/tau;

h = (gTau' * velocity) / (pol*C);

% compute innovation
nu = z - h;

% compute dh/dg - formula 15
% dhdg = [velocity(2) velocity(1)] ./ C;
dhdg = pol * velocity' ./ C;

% get covariances from matrix
PgTau = covariances(:,:,idx(1),idx(2));

% compute innovation covariance
S = dhdg * PgTau * dhdg' + R;

% compute Kalman gain
W = PgTau * dhdg' / S;

% compute updated covariance
Pgt = PgTau - (W * S * W');
% Pgt = PgTau - (PgTau * dhdg' * W'); % try to avoid numerical errors

% compute updated gradient
gt = gTau + (W * nu);

if sum(isnan(gt)) > 0
    warning('gradient is NaN (updateMosaic)');
    u
    v
    pol
    tau
    timestamp
    return;
end

% disp(['gradient old: ' num2str(gradients(:,idx(1),idx(2))') ' new: ' num2str(gt')]);

% update matrices
covariances(:,:,idx(1),idx(2)) = Pgt;
gradients(:,idx(1),idx(2)) = gt;
lastSigs(v, u) = timestamp;
lastPos(:,v,u) = pmt;

return;