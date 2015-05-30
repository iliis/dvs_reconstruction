% track longer path over known image

% this is one of the better visualizations of the tracking subsystem (using
% a known map, i.e. no reconstruction at all)

% deprecated:
% Warning: we don't explicitely generate timestamps for the events and just use
% norm(theta) which works out nicely, as we're monotonically moving away
% from the start point as flyDiffCamFine only walks in positive direction.

clear all;
close all;

hold on;

%imagepath = 'camera_simulation/testimages/toy_example1.png';
%imagepath = 'camera_simulation/testimages/churchtest_downscaled.jpg';
%imagepath = 'camera_simulation/testimages/checkerboard_small.jpg';
imagepath = 'camera_simulation/testimages/panorama.png';

% load image and normalize to [0,1]
img = im2double(rgb2gray(imread(imagepath)));


[particles, tracking_state] = initParticles(1000, [simulationPatchSize() simulationPatchSize()]);

% generate a path


last_pos  = [0 0 0]; % initial position
last_time = 0;
[~,~,flydiff_state] = flyDiffCamFine(img,0,last_time,last_pos); % use flyDiffCamFine to initialize state

events = [];
ground_truth = last_pos;

tracked_path = particleAverage(particles);
%plotCameraGroundTruth(last_pos, size(img), 'green');
%plotParticlesInWorld(particles, size(img));


%figure; image(img); hold on; plotParticlesInWorld([1000 0 0 0], size(img), [34 33]); hold on; plotCameraRect([0 0 0], size(img));
%patch = double(getPatch(img, getInvKPsforPatch(cameraIntrinsicParameterMatrix()), [0 0 0])); figure; imagesc(patch);

%path = [ 1     2     1     2     1     2     1     2     2     2];

for i = 1:20
    
    dir_sign = 1; %(randi(2)-1)*2-1;
    dir_dim  = randi(2); % only translation, no rotation
    direction = dir_sign * dir_dim;
    
    [events_new, ground_truth_new, flydiff_state] = flyDiffCamFine(img, ...
            50,          ... % generate at least so many events
            last_time,   ... % timestamp of last event (i.e. timestamp of flydiff_state)
            last_pos,    ... % start where we left off on last iteration
            dir_dim,    ... % go into some direction (1 = alpha, 2 = beta, 3 = gamma)
            0.000002*dir_sign, ... % default sweep step size (and direction)
            flydiff_state);          % state of camera sensor
    
    % plot ground truth and frames
    plotCameraGroundTruth([last_pos; ground_truth_new], size(img), 'green');
    
    [particles, tracking_state, intermediate_positions] = trackMovement( particles, tracking_state, events_new, img, last_time);
    tracked_path = [tracked_path; intermediate_positions];
    
    
    
    %plotParticlesInWorld(particles, size(img));
    %plotCameraGroundTruth(tracked_path(end-1:end,:), size(img), 'blue');
    
    if size(tracked_path,1) > 10
        plotCameraGroundTruth(movingAvg(tracked_path, 10), size(img), 'red');
    end
    
    title({'tracking with perfect image','green: ground truth','blue: tracking','red: running average over tracking'});
    legend('ground truth','tracking','running average of tracking');
    drawnow;
    
    events = [events; events_new];
    ground_truth = [ground_truth; ground_truth_new];
    
    last_pos  = ground_truth(end,:);
    last_time = events(end,4);
end

err = sum((ground_truth - tracked_path).^2, 2);
figure;
plot(err);
title('error of tracking vs. ground truth');

%function [particles, tracking_state] = trackMovement( particles, tracking_state, events, img, last_timestamp)
%[particles, tracking_state] = trackMovement( particles, tracking_state, events, img, 0);

%plotCameraGroundTruth(ground_truth, size(img));
%hold on;
%plotParticlesInWorld(particles, size(img));