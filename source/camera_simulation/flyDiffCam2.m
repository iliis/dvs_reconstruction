function [allAddr, allTS, thetas] = flyDiffCam2(imagepath, thetaStart, thetaStop, omega)

% Simulates a camera rotation of the event camera in the scene given by 'imagepath'
% 
% Arguments:
% imagepath: the path to the scene image as string
% thetaStart: the initial camera orientation (angles)
% thetaStop: the stopping orientation
% omega: the rotation speed (orientation change in one timestep)

running = @(theta) sum(abs(theta(1:2) - thetaStop(1:2))) > sum(abs(omega(1:2)));

theta = thetaStart;
state = zeros(128);

img = rgb2gray(imread(imagepath));
time = 1;

allAddr = [];
allTS = [];
thetas = [];

threshold = pixelIntensityThreshold();
K = cameraIntrinsicParameterMatrix();

lastPatch = getPatch(img, K, thetaStart(1), thetaStart(2), thetaStart(3));

while running(theta)
%     [addr, ts, newTheta, newState] = moveCam(img, theta, omega, time, state);
	theta = [theta(1) + omega(1), theta(2) + omega(2), theta(3) + omega(3)];
	
	patch = getPatch(img, K, theta(1), theta(2), theta(3));
	
	[addr, ts, state] = getSignals(lastPatch, patch, time, state, threshold);

    allAddr = [allAddr; addr];
    allTS = [allTS; ts];
    thetas = [thetas; repmat(theta, size(addr,1), 1)];

    time = time + 1;
	lastPatch = patch;
    pause(0.001);
end