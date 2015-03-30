function [allAddr, allTS, thetas, endState] = flyDiffCam2(imagepath, thetaStart, thetaStop, omega, startState)

% Simulates a camera rotation of the event camera in the scene given by 'imagepath'
% 
% Arguments:
% imagepath: the path to the scene image as string
% thetaStart: the initial camera orientation (angles)
% thetaStop: the stopping orientation
% omega: the rotation speed (orientation change in one timestep)
% startState: the state of each pixel at the beginning (in case of several
% concatenated paths)

% theta = thetaStart;

if nargin < 5 || (size(startState, 1) ~= 128 || size(startState, 2) ~= 128)
    state = zeros(128);
else
    state = startState;
end

img = double(rgb2gray(imread(imagepath)));
% time = 1;

allAddr = [];
allTS = [];
thetas = [];

threshold = pixelIntensityThreshold();
K = cameraIntrinsicParameterMatrix();

steps = round((thetaStop - thetaStart) ./ omega);

steps((thetaStop - thetaStart) == 0 & omega == 0) = 0; %avoid invalid values due to division by 0

if (steps(1) ~= steps(2) && steps(1) ~= 0 && steps(2) ~= 0) || ...
        (steps(1) ~= steps(3) && steps(1) ~= 0 && steps(3) ~= 0) || ...
        (steps(2) ~= steps(3) && steps(2) ~= 0 && steps(3) ~= 0) || ...
        steps(1) < 0 || ...
        steps(2) < 0 || ...
        steps(3) < 0;
    
    fprintf('steps(1): %d\n', steps(1));
    fprintf('steps(2): %d\n', steps(2));
    fprintf('steps(3): %d\n', steps(3));
    error('movement in alpha/beta dimension not consisten with start/endpoints');
end

fprintf('starting simulation with %d timesteps\n', max(steps));

invKPs = zeros([128 128 2]);

for u = 1:128
    for v = 1:128      
        invKP = K \ [u v 1]';  
        invKPs(v, u, :) = invKP(1:2);    
    end
end

lastPatch = getPatch(img, invKPs, thetaStart(1), thetaStart(2), thetaStart(3));

for i = 1:max(steps)
    
    theta = thetaStart + i*omega;
    
    patch = getPatch(img, invKPs, theta(1), theta(2), theta(3));
	
	[addr, ts, state] = getSignals(lastPatch, patch, i, state, threshold);

    allAddr = [allAddr; addr];
    allTS = [allTS; ts];
    thetas = [thetas; repmat(theta, size(addr,1), 1)];

	lastPatch = patch;
    pause(0.0001);    
    
    if mod(i, 100) == 0
        fprintf('timestep %d/%d\n', i, max(steps));
    end
end

endState = state;

return;