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

lastPatch = getPatch(img, K, thetaStart(1), thetaStart(2), thetaStart(3));

steps = round((thetaStop - thetaStart) ./ omega);

steps((thetaStop - thetaStart) == 0 & omega == 0) = 0;

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

for i = 1:max(steps)
    
    theta = thetaStart + i*omega;
    
    patch = getPatch(img, K, theta(1), theta(2), theta(3));
	
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

% while sum(abs(theta(1:2) - thetaStop(1:2))) > sum(abs(omega(1:2)))
% %     [addr, ts, newTheta, newState] = moveCam(img, theta, omega, time, state);
% 	theta = [theta(1) + omega(1), theta(2) + omega(2), theta(3) + omega(3)];
% 	
% 	patch = getPatch(img, K, theta(1), theta(2), theta(3));
% 	
% 	[addr, ts, state] = getSignals(lastPatch, patch, time, state, threshold);
% 
%     allAddr = [allAddr; addr];
%     allTS = [allTS; ts];
%     thetas = [thetas; repmat(theta, size(addr,1), 1)];
% 
%     time = time + 1;
% 	lastPatch = patch;
%     pause(0.001);
% end