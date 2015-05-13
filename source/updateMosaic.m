function [gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos] = updateMosaic(u, v, pol, timestamp, theta, gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos)

% This function an event and updates the mosaic, gradients, covariances and
% history with an EKF

assert(pol == 1 || pol == -1, sprintf('polarity signal error: pol = %d', pol));

C = pixelIntensityThreshold(); %0.22 - log intensity change that causes an event
R = measurementNoise(); %DUMMY - measurement noise

% compute tau
tau = double(timestamp - lastSigs(v, u));

% get last position of this pixel
pmTau = lastPos(:, v, u);

% handle strong changes (-> multiple signals)
if tau == 0
    warning('doubled event with same timestamp');
    tau = double(timestamp - secToLastSigs(v, u));
    if tau == 0
        return;
    end
    pmTau = secToLastPos(:, v, u);
else
    secToLastSigs(v, u) = lastSigs(v, u);
    secToLastPos(:, v, u) = lastPos(:, v, u);
end

pmt = cameraToWorldCoordinates(u,v,cameraIntrinsicParameterMatrix(),theta,[size(gradients,2),size(gradients,3)]);
idx = round(pmt);
pmt = pmt';
% pmt = [pmt(2); pmt(1)]

% compute speed
velocity = (pmt - pmTau) ./ tau;

if sum(abs(pmt-pmTau)) < 0.1
%     if all(round(pmt) == round(pmTau))
        warning('abort - double signal');
        return;
%     end
%     warning('small movement detected between events');
%     disp(['movement: ' num2str((pmt-pmTau)')]);
%     return;
end

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

% update matrices
covariances(:,:,idx(1),idx(2)) = Pgt;
gradients(:,idx(1),idx(2)) = gt;
lastSigs(v, u) = timestamp;
lastPos(:,v,u) = pmt;

return;