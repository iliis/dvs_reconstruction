function [ map, gradients, theta_est, imgSeq ] = reconstructSceneFromEventStream(events_raw, TS, theta_gt, imagepath)


%% Initialize


if nargin < 4
%     standard input image
    imagepath = 'camera_simulation/testimages/panorama.png';
end

% read input image, only for map initialization
img = im2double(rgb2gray(imread(imagepath)));

% get global parameters
params = getParameters();

% extract events
[x, y, pol] = extractRetinaEventsFromAddr(events_raw);

% make sure that the camera size of the input data is consistent with the
% current camera size
maxX = max(x);
maxY = max(y);
maxCamIndex = params.simulationPatchSize- 1;

assert(maxX <= maxCamIndex);
assert(maxY <= maxCamIndex);

% collect events in single matrix, shift pixel indives from 0-indexed to
% 1-indexed
events = [double(x+1) double(y+1) double(pol) double(TS)];
disp(['got ' num2str(size(events,1)) ' events']);


% prepare variables for reconstruction

% boundary image for poisson reconstruction
boundary_image = 0.5*ones(params.outputImageSize);

% covariances for Kalman filter
covariances = 1000*repmat(eye(2), [1, 1, params.outputImageSize]);

% timestamp of last event for each pixel
lastSigs = zeros(params.simulationPatchSize);

% position of each pixel at time of last event
lastPos = reshape( ...
    cameraToWorldCoordinatesBatch( ...
        getInvKPsforPatch(), ...
        [0 0 0], ...
        params.outputImageSize)', ...
    [2 params.simulationPatchSize params.simulationPatchSize] ...
    );

% collect some intermediate maps to show progress
imgSeq = zeros([params.outputImageSize, ceil(size(events,1)/10000)]);

% initialize map with initial FOV
[gradients, xInds, yInds] = initializeMap(img, params);

% set very small covariances for initial patch to avoid writing unnecessary
% noise
smallCovariances = repmat(eye(2), [1, 1, params.outputImageSize]);
covariances(:,:,yInds,xInds) = smallCovariances(:,:,yInds,xInds);

% create grayscale image of initial gradient map
pgrads = permute(gradients, [2 3 1]);
map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);

% plot image
if ~exist('initial_map_figure', 'var') || ~ishandle(initial_map_figure)
    initial_map_figure = figure('Name', 'Initial map');
else
    figure(initial_map_figure);
end
imshow(map);
drawnow;


% initialize particles
N = 100;
[particles, tracking_state] = initParticles(N, [params.simulationPatchSize params.simulationPatchSize]);

% prepare array for orientation estimations
theta_est = zeros(size(events, 1), 3);

% set timestamp of last gobal event to zeros
last_timestamp = 0;



%% Iterate over events


% first iteration outside of loop to avoid corner case

% compute time since last global event
deltaT_global = events(1,4) - last_timestamp;
last_timestamp = events(1,4);

% actually perform Bayesian update
particles = predict(particles, deltaT_global);

% [MEX]: recommended: use compiled function here for speedup
%[particles, tracking_state] = updateOnEvent_mex(particles, events(1,:), map, tracking_state, params);
[particles, tracking_state] = updateOnEvent(particles, events(1,:), map, tracking_state, params);

% use low-pass filter to reduce noise in the estimated path
theta_est(1,:) = params.reconstruction.trackingWeight*particleAverage(particles);

% write the event into the gradient map
[gradients, covariances, lastSigs, lastPos] = updateMosaic(events(1,1), events(1,2), events(1,3), events(1,4), theta_est(1,:), gradients, covariances, lastSigs, lastPos);

for i = 2:size(events,1)
    
%     compute time sinc last global event
    deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);

    % actually perform Bayesian update
    particles = predict(particles, deltaT_global);    
    
    % [MEX]: recommended: use compiled function here for speedup
    %[particles, tracking_state] = updateOnEvent_mex(particles, events(i,:), map, tracking_state, params);
    [particles, tracking_state] = updateOnEvent(particles, events(i,:), map, tracking_state, params);
    
%     use low-pass filter to reduce noise in the estimated path
    theta_est(i,:) = params.reconstruction.trackingWeight*particleAverage(particles) ...
                   + (1-params.reconstruction.trackingWeight)*theta_est(i-1,:);    

%     write event into the gradient map
    [gradients, covariances, lastSigs, lastPos] = updateMosaic(events(i,1), events(i,2), events(i,3), events(i,4), theta_est(i,:), gradients, covariances, lastSigs, lastPos);

%     movements between events are very small and computing the grayscale
%     image takes relatively long -> only compute new map every 1000
%     iterations
    if mod(i, 1000) == 0
        pgrads = permute(gradients, [2 3 1]);
        map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);
    end
   
%     give a small information update from time to time
    if mod(i, 1000) == 0
        disp(['updated on event ' num2str(i) ...
            ' (time ' num2str(events(i,4)) ')' ...
            ' = ' num2str(events(i,1:3)) ...
            ' err = ' num2str(norm(theta_gt(i,:) - theta_est(i,:))) ...
            ' deltaT_global = ' num2str(deltaT_global) ...
            ' mean = ' num2str(particleAverage(particles)) ...
            ' eff. no. = ' num2str(effectiveParticleNumber(particles))]);
       
    end
    
%     displaying the image takes very long and is not needed for the
%     algorithm -> only update every 10000 iterations
    if mod(i, 10000) == 0
        if ~exist('intermediate_map_figure', 'var') || ~ishandle(intermediate_map_figure)
            intermediate_map_figure = figure('Name', 'Currently used map');
        else
            figure(intermediate_map_figure);
        end
        plotCameraPositionsInImage(map, theta_est(1:i,:), theta_gt(1:i,:) - repmat(theta_gt(1,:), i,1));
        drawnow;
        
        imgSeq(:,:,round(i/10000)) = map;
    end
            
    
    % resample distribution if particles become too unevenly distributed
    if effectiveParticleNumber(particles) < size(particles,1)/2; % paper uses 50%
        particles = resample(particles);
    end
    
%     keep the plotted images responsive during computation
    drawnow;
end


% end of iterations



%% Display final information

disp(['final mean = ' num2str(particleAverage(particles)) '  eff. no. = ' effectiveParticleNumber(particles)]);

% compute and plot travelled distance and error
travelled_distance = cumsum(sqrt(sum((theta_gt - [0 0 0; theta_gt(1:end-1, :)]).^2, 2)));
% travelled_distance = sqrt(sum(theta_gt.^2, 2))';
err = sqrt(sum((theta_gt - theta_est).^2, 2))';

if ~exist('errorplot_figure', 'var') || ~ishandle(errorplot_figure)
    errorplot_figure = figure();
else
    figure(errorplot_figure);
end
plot(1:size(theta_gt,1), err, 'r', 1:size(theta_gt,1), travelled_distance, 'g');
legend('total error', 'overall movement');

% compute final map
pgrads = permute(gradients, [2 3 1]);
map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);
disp(['map extreme values: [' num2str(min(min(map))) ', ' num2str(max(max(map))) ']']);
disp(['image extreme values: [' num2str(min(min(img))) ', ' num2str(max(max(img))) ']']);

% add final map to image sequence
imgSeq(:,:,end) = map;

% plot final map with travelled paths and final camera positions
if ~exist('intermediate_map_figure', 'var') || ~ishandle(intermediate_map_figure)
    intermediate_map_figure = figure();
else
    figure(intermediate_map_figure);
end
plotCameraPositionsInImage(map, theta_est, theta_gt);
drawnow;
