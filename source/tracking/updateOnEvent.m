function particles = updateOnEvent(particles_prior, event, intensities)
% input: 4xN list of particles [weight, 3x rotation], 1 event [u,v,sign]

% TODO: these values were chosen arbitrariliy!
LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 5; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;

particles = predict(particles_prior);

u = event(1); v = event(2);
K = cameraIntrinsicParameterMatrix();
invKPs = reshape(K \ [u v 1]', 1, 1, 3); invKPs = invKPs(:,:,1:2);

old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);

for i = 1:size(particles_prior,1)
    % get pixel coordinates in world map
    old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior(i,2:end), size(intensities));
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(intensities));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));
measurements = interp2(intensities,new_points_w(:,2),new_points_w(:,1)) - interp2(intensities,old_points_w(:,2),old_points_w(:,1));

% TODO: handle isnan(measurement)
assert(sum(isnan(measurements)) == 0);

if event(3) > 0
    s = 1;
else
    s = -1;
end

matching_sign = (measurements * s) > 0;

% event sign matches the predicted one of current particle
% TODO: parameters for gaussian are quite arbitrary...
particles( matching_sign, 1) = 2*LOW_LIKELIHOOD + gaussmf(measurements(matching_sign), [INTENSITY_VARIANCE INTENSITY_THRESHOLD]);

% event sign doesn't match -> these particles are bad
particles(~matching_sign, 1) = LOW_LIKELIHOOD; % some fixed low likelihood

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles(:,1) = particles(:,1) / sum(particles(:,1));

end