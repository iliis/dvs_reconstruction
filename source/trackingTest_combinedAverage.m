function [ map, gradients, theta_est, imgSeq ] = trackingTest_combinedAverage(events_raw, TS, theta_gt, imagepath)

if nargin < 4
    imagepath = 'camera_simulation/testimages/panorama.png';
end

img = im2double(rgb2gray(imread(imagepath)));


[x, y, pol] = extractRetinaEventsFromAddr(events_raw);

events = [double(x+1) double(y+1) double(pol) double(TS)];

for i = 1:10
    disp(['event ' num2str(i) ' at ' num2str([events(i,1) events(i,2)]) ' pol = ' num2str(events(i,3)) '(' num2str(events(i,:)) ')']);
end

disp(['got ' num2str(size(events,1)) ' events']);

% prepare variables for reconstruction
outputImageSize = [1000 2000];
boundary_image = 0.5*ones(outputImageSize);
covariances = 1000*repmat(eye(2), [1, 1, outputImageSize]);
lastSigs = zeros(simulationPatchSize());

imgSeq = zeros([outputImageSize, ceil(size(events,1)/10000)]);
lastPos = reshape(cameraToWorldCoordinatesBatch(getInvKPsforPatch(cameraIntrinsicParameterMatrix()), [0 0 0], outputImageSize)', [2 simulationPatchSize() simulationPatchSize()]);

[gradients, xInds, yInds] = initializeMap(img, outputImageSize);

smallCovariances = repmat(eye(2), [1, 1, outputImageSize]);
covariances(:,:,yInds,xInds) = smallCovariances(:,:,yInds,xInds);

pgrads = permute(gradients, [2 3 1]);
map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);
if ~exist('initial_map_figure', 'var') || ~ishandle(initial_map_figure)
    initial_map_figure = figure('Name', 'Initial map');
else
    figure(initial_map_figure);
end
imshow(map);
drawnow;


% update on events
N = 100;
[particles, tracking_state] = initParticlesAverage(N, [simulationPatchSize() simulationPatchSize()]);

theta_est = zeros(size(events, 1), 3);
last_timestamp = 0;

% first iteration outside of loop to avoid corner case
deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);
    
    % actually perform Bayesian update
    particles = predict(particles, deltaT_global);
    
    [particles, tracking_state] = updateOnEventAverage_mex(particles, events(i,:), map, tracking_state);
    theta_est(i,:) = 0.3*particleAverage(particles);   
    
    [gradients, covariances, lastSigs, lastPos] = updateMosaic(events(i,1), events(i,2), events(i,3), events(i,4), theta_est(i,:), gradients, covariances, lastSigs, lastPos);

for i = 2:size(events,1)
    deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);

    % actually perform Bayesian update
    particles = predict(particles, deltaT_global);
    
%         [particles, tracking_state] = updateOnEventAverage_mex(particles, events(i,:), map, tracking_state);
    [particles, tracking_state] = updateOnEventAverage(particles, events(i,:), img, tracking_state);
    
    theta_est(i,:) = 0.3*particleAverage(particles) + 0.7*theta_est(i-1,:);    

    [gradients, covariances, lastSigs, lastPos] = updateMosaic(events(i,1), events(i,2), events(i,3), events(i,4), theta_est(i,:), gradients, covariances, lastSigs, lastPos);

    if mod(i, 5000) == 0
        pgrads = permute(gradients, [2 3 1]);
        map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);
    end
   
    if mod(i, 1000) == 0
        disp(['updated on event ' num2str(i) ...
            ' (time ' num2str(events(i,4)) ')' ...
            ' = ' num2str(events(i,1:3)) ...
            ' err = ' num2str(norm(theta_gt(i,:) - theta_est(i,:))) ...
            ' deltaT_global = ' num2str(deltaT_global) ...
            ' mean = ' num2str(particleAverage(particles)) ...
            ' eff. no. = ' num2str(effectiveParticleNumber(particles))]);
       
    end
    
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
        effno = effectiveParticleNumber(particles);
%         disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
    end
    drawnow;
end

disp(['final mean = ' num2str(particleAverage(particles)) '  eff. no. = ' effectiveParticleNumber(particles)]);

travelled_distance = sqrt(sum(theta_gt.^2, 2))';
err = sqrt(sum((theta_gt - theta_est).^2, 2))';

if ~exist('errorplot_figure', 'var') || ~ishandle(errorplot_figure)
    errorplot_figure = figure();
else
    figure(errorplot_figure);
end
plot(1:size(theta_gt,1), err, 'r', 1:size(theta_gt,1), travelled_distance, 'g');
legend('total error', 'overall movement');


pgrads = permute(gradients, [2 3 1]);
map = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);
disp(['map extreme values: [' num2str(min(min(map))) ', ' num2str(max(max(map))) ']']);
disp(['image extreme values: [' num2str(min(min(img))) ', ' num2str(max(max(img))) ']']);

imgSeq(:,:,end) = map;

if ~exist('intermediate_map_figure', 'var') || ~ishandle(intermediate_map_figure)
    intermediate_map_figure = figure();
else
    figure(intermediate_map_figure);
end
plotCameraPositionsInImage(map, theta_est, theta_gt);
drawnow;
