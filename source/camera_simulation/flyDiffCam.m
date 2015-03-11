function [allAddr, allTS] = flyDiffCam(imagepath, thetaStart, thetaStop, omega)

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
time = 0;

allAddr = [];
allTS = [];

while running(theta)
    
    [addr, ts, newTheta, newState] = moveCam(img, theta, omega, time, state);
    
    allAddr = [allAddr; addr];
    allTS = [allTS; ts];
    
    theta = newTheta;
    state = newState;
    time = time + 1;
    pause(0.001);
end