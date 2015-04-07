% test updateOnEvent() for single movement (a few events)
% TODO: This works fairly well for the first update. Subsequent updates
% assume a movement between each event, but intensity change is actually
% from last position the pixel has fired.

if ~exist('tracking_test2_figure', 'var') || ~ishandle(tracking_test2_figure)
    tracking_test2_figure = figure();
else
    figure(tracking_test2_figure);
end

imagepath = 'camera_simulation/testimages/panorama.png';

theta_new = [0.0003 0 0];  % look a tiny bit up

K = cameraIntrinsicParameterMatrix();
invKPs = zeros([128 128 2]);
for u = 1:128
    for v = 1:128      
        invKP = K \ [u v 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

img = double(rgb2gray(imread(imagepath)));

old_patch = getPatch(img, invKPs, [0 0 0]);
%new_patch = getPatch(img, invKPs, [0.01 0 0]); % look a tiny bit up
new_patch = getPatch(img, invKPs, theta_new);

% calculate all events
% (for a more realistic simulation, don't start with state zero, but do a
% 'warmup' step (-> smaller movement needed for event))
events_raw = getSignals(old_patch, new_patch, 0, zeros(size(old_patch)), pixelIntensityThreshold());

% convert events into normal matlab vectors
events = zeros(size(events_raw,1), 4);
for i = 1:size(events_raw,1)
    [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
    events(i,:) = [x y pol 1];
end




% shuffle events
%events = events(randperm(size(events,1)), :);

% update on events
N = 1000;
particles      = initParticles(N);
tracking_state = initTrackingState(N, size(old_patch,1));

% use grid particles from test3 instead of all fixed around origin
% (disable predict() inside updateOnEvents() to get identical image to test3)
range = linspace(-0.01,0.01,100);
[X, Y] = meshgrid(range,range);
particles = [repmat(1/numel(X), numel(X),1) reshape(X, numel(X),1) reshape(Y, numel(Y),1) zeros(numel(X),1)];
% add artifical event to test math
events = [61 43 1 1; events]; % top edge of sphere


% wide initial distribution
% particles(:, 2:end) = particles(:, 2:end) + 0.0004 * randn(size(particles)-[0,1]);
last_timestamp = 0;

for i = 1:size(events,1)
    
    deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);
    
    % actually perform Bayesian update
    [particles, tracking_state] = updateOnEvent(particles, events(i,:), img, tracking_state, deltaT_global);
    disp(['updated on event ' num2str(i) ' = ' num2str(events(i,:)) ' deltaT_global = ' num2str(deltaT_global) ' mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effectiveParticleNumber(particles))]);
    
    plotParticles(particles); drawnow; waitforbuttonpress;
    
    
    % resample distribution if particles become too unevenly distributed
    if effectiveParticleNumber(particles) < size(particles,1)/2; % paper uses 50%
        particles = resample(particles);
        effno = effectiveParticleNumber(particles);
        disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
        
        plotParticles(particles); drawnow; waitforbuttonpress;
    end
end

disp(['final mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effno)]);