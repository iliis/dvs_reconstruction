% track longer path over known image

% Warning: we don't generate any timestamps for the events and just use
% norm(theta) which works out nicely, as we're monotonically moving away
% from the start point as flyDiffCamFine only walks in positive direction.

clear all;
close all;

imagepath = 'camera_simulation/testimages/toy_example1.png';
img = double(rgb2gray(imread(imagepath)));

% generate a path
[events, ground_truth, state] = flyDiffCamFine(img, 50);

[particles, tracking_state] = initParticles(1000, [128 128]);

for i = 1:10
    [events_new, ground_truth_new, state] = flyDiffCamFine(img, ...
            10,                     ... % generate at least so many events
            ground_truth(end,:),    ... % start where we left off on last iteration
            randi(2),               ... % go into some direction (1 = alpha, 2 = beta, 3 = gamma)
            0.00001,                ... % default sweep step size
            state);                     % state of camera sensor
    
    events = [events; events_new];
    ground_truth = [ground_truth; ground_truth_new];
end


%function [particles, tracking_state] = trackMovement( particles, tracking_state, events, img, last_timestamp)
[particles, tracking_state] = trackMovement( particles, tracking_state, events, img, 0);

imagesc(img);
hold on;
plotCameraGroundTruth(ground_truth, size(img));
plotParticlesInWorld(particles, size(img));