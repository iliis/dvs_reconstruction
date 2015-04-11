function [particles, state] = updateOnEvent(particles_prior, event, intensities, state_prior, deltaT_global)
% input:
%  4xN list of particles [weight, 3x rotation]
%  1 event [u,v,sign,timestamp]
%  state: position of camera for every pixel at the time of its last event [128x128x3]

% TODO: these values were chosen arbitrariliy!
LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 5; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;
u = event(1); v = event(2);

if event(3) > 0
    s = 1;
else
    s = -1;
end

particles = predict(particles_prior, deltaT_global);
%particles = particles_prior;

K = cameraIntrinsicParameterMatrix();
invKPs = reshape(K \ [u v 1]', 1, 1, 3); invKPs = invKPs(:,:,1:2);

old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);

particles_prior_this_pixel = permute(state_prior(v,u,:,:), [3 4 1 2]);

for i = 1:size(particles_prior,1)
    % get pixel coordinates in world map
    old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior_this_pixel(i,2:end), size(intensities));
    
    %old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior(i,2:end), size(intensities));
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(intensities));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));

likelihoods = zeros(size(particles,1),1);
old_intensities = interp2(intensities, old_points_w(:,2), old_points_w(:,1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));
for i = 1:size(new_points_w,1)
    measurements = new_intensities(i) - old_intensities;
    matching_sign = (measurements * s) > 0;
    
    tmp_likelihoods = gaussmf(abs(measurements), [INTENSITY_VARIANCE INTENSITY_THRESHOLD]) .* particles_prior_this_pixel(:,1);
    likelihoods(i) = sum(tmp_likelihoods(matching_sign)) + LOW_LIKELIHOOD;
    
end

%old_point_w = cameraToWorldCoordinates(u,v,K, reshape(state_prior(v,u,:),3,1), size(intensities));
%old_intensity = interp2(intensities, old_point_w(2), old_point_w(1));
%measurements = interp2(intensities,new_points_w(:,2),new_points_w(:,1)) - old_intensity; %interp2(intensities,old_points_w(:,2),old_points_w(:,1));

% TODO: handle isnan(measurement)
%assert(sum(isnan(measurements)) == 0);

%matching_sign = (measurements * s) > 0;

% event sign matches the predicted one of current particle
% TODO: parameters for gaussian are quite arbitrary...
%particles( matching_sign, 1) = 2*LOW_LIKELIHOOD + gaussmf(measurements(matching_sign), [INTENSITY_VARIANCE INTENSITY_THRESHOLD]);

% event sign doesn't match -> these particles are bad
%particles(~matching_sign, 1) = LOW_LIKELIHOOD; % some fixed low likelihood

%particles( :, 1) = 2*LOW_LIKELIHOOD + gaussmf(measurements(:), [INTENSITY_VARIANCE INTENSITY_THRESHOLD]);

particles(:,1) = likelihoods;


% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles(:,1) = particles(:,1) / sum(particles(:,1));

% update state
state = state_prior;
state(v,u,:,:) = particles; %particleAverage(particles);

end