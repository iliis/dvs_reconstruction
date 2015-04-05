% test updateOnEvent() for single movement (a few 1000 events)

imagepath = 'camera_simulation/testimages/panorama.png';

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
new_patch = getPatch(img, invKPs, [0.0003 0 0]); % look a tiny bit up

% calculate all events
events_raw = getSignals(old_patch, new_patch, 0, zeros(size(old_patch)), pixelIntensityThreshold());

% convert events into normal matlab vectors
events = zeros(size(events_raw,1),3);
for i = 1:size(events_raw,1)
    [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
    events(i,:) = [x y pol];
end

% shuffle events
events = events(randperm(size(events,1)), :);

% update on events
particles = initParticles(100);
for i = 1:size(events,1)
    effno = effectiveParticleNumber(particles);
    disp(['updating on event ' num2str(i) ' = ' num2str(events(i,:)) ' mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effno)]);
    if effno < size(particles,1)/4 % paper uses 50%
        particles = resample(particles);
        effno = effectiveParticleNumber(particles);
        disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
    end
    
    particles = updateOnEvent(particles, events(i,:), img);
end

disp(['final mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effno)]);