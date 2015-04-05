% test updateOnEvent() for single movement (a few events)
% TODO: This works fairly well for the first update. Subsequent updates
% assume a movement between each event, but intensity change is actually
% from last position the pixel has fired.

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
events = zeros(size(events_raw,1),3);
for i = 1:size(events_raw,1)
    [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
    events(i,:) = [x y pol];
end

% shuffle events
%events = events(randperm(size(events,1)), :);

% update on events
particles = initParticles(1000);

% wide initial distribution
particles(:, 2:end) = particles(:, 2:end) + 0.0004 * randn(size(particles)-[0,1]);

for i = 1:size(events,1)
    
    % actually perform Bayesian update
    particles = updateOnEvent(particles, events(i,:), img);
    disp(['updated on event ' num2str(i) ' = ' num2str(events(i,:)) ' mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effectiveParticleNumber(particles))]);
    
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