% track longer path over known image

% Warning: we don't explicitely generate timestamps for the events and just use
% norm(theta) which works out nicely, as we're monotonically moving away
% from the start point as flyDiffCamFine only walks in positive direction.

clear all;
close all;

hold on;

imagepath = 'camera_simulation/testimages/toy_example1.png';
img = double(rgb2gray(imread(imagepath)));


[particles, tracking_state] = initParticles(1000, [simulationPatchSize() simulationPatchSize()]);

% total: 214.22s
% update: 137.544 self, 197.251 total

% generate a path

events = [];
ground_truth = [];

last_pos  = [0 0 0]; % initial position
last_time = 0;
[~,~,flydiff_state] = flyDiffCamFine(img,0,last_pos);

tracked_path = particleAverage(particles);

path = [ 1     2     1     2     1     2     1     2     2     2];

for i = 1:10
    
    [events_new, ground_truth_new, flydiff_state] = flyDiffCamFine(img, ...
            20,          ... % generate at least so many events
            last_pos,    ... % start where we left off on last iteration
            path(i), ... %randi(2),    ... % go into some direction (1 = alpha, 2 = beta, 3 = gamma)
            0.00001,     ... % default sweep step size
            flydiff_state);          % state of camera sensor
        
    [particles, tracking_state] = trackMovement( particles, tracking_state, events_new, img, last_time);
    
    tracked_path = [tracked_path; particleAverage(particles)];
    plotCameraGroundTruth([last_pos; ground_truth_new], size(img), 'green');
    plotParticlesInWorld(particles, size(img));
    plotCameraGroundTruth(tracked_path(end-1:end,:), size(img), 'blue');
    drawnow;
    
    events = [events; events_new];
    ground_truth = [ground_truth; ground_truth_new];
    
    last_pos  = ground_truth(end,:);
    last_time = events(end,4);
end


%function [particles, tracking_state] = trackMovement( particles, tracking_state, events, img, last_timestamp)
%[particles, tracking_state] = trackMovement( particles, tracking_state, events, img, 0);

%plotCameraGroundTruth(ground_truth, size(img));
%hold on;
%plotParticlesInWorld(particles, size(img));