function [allAddr, allTS, thetas, endState] = flyDiffCam(imagepath, thetaStart, thetaStop, omega, startState)

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

params = getParameters();

if nargin < 5 || (size(startState, 1) ~= params.simulationPatchSize || size(startState, 2) ~= params.simulationPatchSize)
    state = zeros(params.simulationPatchSize);
else
    state = startState;
end

img = im2double(rgb2gray(imread(imagepath)));
% time = 1;

allAddr = zeros(100000,1);
allTS = zeros(100000,1);
thetas = zeros(100000,3);
lastOccupied = 0;

threshold = params.pixelIntensityThreshold;

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

invKPs = getInvKPsforPatch();

% [MEX]: recommended: use compiled function here for speedup
%lastPatch = getPatch_mex(img, invKPs, thetaStart, params.simulationPatchSize);
lastPatch = getPatch(img, invKPs, thetaStart, params.simulationPatchSize);

for i = 1:max(steps)
    
    theta = thetaStart + i*omega;
    
    % [MEX]: recommended: use compiled function here for speedup
    %patch = getPatch_mex(img, invKPs, theta, params.simulationPatchSize);
    patch = getPatch(img, invKPs, theta, params.simulationPatchSize);

	[addr, ts, state] = getSignals(lastPatch, patch, i, state, threshold);
    
    newEvents = size(addr,1);
    
    if lastOccupied + newEvents > size(allAddr,1)
        %does not fit into array -> resize
        disp('resize');
        oldSize = size(allAddr,1);
        newSize = oldSize + 100000;
        newAllAddr = zeros(newSize,1);
        newAllTS = zeros(newSize,1);
        newThetas = zeros(newSize,3);
        
        newAllAddr(1:lastOccupied) = allAddr(1:lastOccupied);
        newAllTS(1:lastOccupied) = allTS(1:lastOccupied);
        newThetas(1:lastOccupied,:) = thetas(1:lastOccupied,:);
        
        allAddr = newAllAddr;
        allTS = newAllTS;
        thetas = newThetas;
    end
    
    

    allAddr((lastOccupied+1):(lastOccupied+newEvents)) = addr;
    allTS((lastOccupied+1):(lastOccupied+newEvents)) = ts;
    thetas((lastOccupied+1):(lastOccupied+newEvents),:) = repmat(theta, newEvents, 1);
    
    lastOccupied = lastOccupied+newEvents;

	lastPatch = patch; 
    
    if mod(i, 1000) == 0
        fprintf('timestep %d/%d\n', i, max(steps));
        state(isnan(state)) = 0; %reset nan values
    end
end

% remove leftover space
allAddr = allAddr(1:lastOccupied);
allTS = allTS(1:lastOccupied);
thetas = thetas(1:lastOccupied,:);

endState = state;

return;
