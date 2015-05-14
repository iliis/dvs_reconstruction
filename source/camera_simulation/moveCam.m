function [addr, ts, newTheta, newState] = moveCam(img, theta, omega, ts, state)

% simulates the camera movementand returns the changed pixels in the same
% format as the camera would.
% Arguments:
% img the image (grayscale)
% theta the current camera orientation [alpha, beta, gamma]
% omega the camera speed [thetaAlpha, thetaBeta, thetaGamma] (movement
% between two timesteps)
% ts the new timestamp (scalar)
% state the old integrated pixel difference
% Return arguments:
% [addr, ts] as from the camera
% theta the new camera orientation [alpha, beta, gamma]
% state the new integrated pixel difference

if nargin < 3
    error('image, camera orientation and camera speed needed');
    
elseif nargin < 5
    state = zeros(simulationPatchSize());
    
    if nargin < 4
        ts = 0;
    end
end

threshold = pixelIntensityThreshold();
K = cameraIntrinsicParameterMatrix();

newTheta = [theta(1) + omega(1), theta(2) + omega(2), theta(3) + omega(3)];

oldPatch = getPatch(img, K, theta(1), theta(2), theta(3));
newPatch = getPatch(img, K, newTheta(1), newTheta(2), newTheta(3));

diff = double(newPatch) - double(oldPatch);

newState = state + diff;

pIdx = newState > threshold;
nIdx = newState < -threshold;

visDiffs = 0.5*ones(simulationPatchSize());
visDiffs(pIdx) = 1;
visDiffs(nIdx) = 0;

imshow(visDiffs);

[vp, up] = find(pIdx);
[vn, un] = find(nIdx);

newState([vp; vn], [up; un]) = 0;

addr = getTmpdiff128Addr([up; un]-1,  [vp; vn]-1,  [ones(size(vp)); zeros(size(vn))]);
ts = ts*ones(size(addr));