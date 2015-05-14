function [particles, state_prior] = updateOnEvent(particles_prior, event, intensities, state_prior)
% input:
%  4xN list of particles [weight, 3x rotation]
%  1 event [u,v,sign,timestamp]
%  state: position of camera for every pixel at the time of its last event [128x128x3]

assert(~any(any(isnan(intensities))), 'NaN in intensities');

% TODO: these values were chosen arbitrariliy!
% LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 0.08; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;

u = event(1); v = event(2);

if event(3) > 0
    event_sign = 1;
else
    event_sign = -1;
end

K = double(cameraIntrinsicParameterMatrix());
invKPs = reshape(K \ double([u v 1]'), 1, 1, 3); invKPs = invKPs(:,:,1:2);

particles = particles_prior;

%old_points_w = zeros(size(particles,1),2);
%new_points_w = zeros(size(particles,1),2);

particles_prior_this_pixel = state_prior(:,:,v,u); %permute(state_prior(v,u,:,:), [3 4 1 2]);

% get pixel coordinates in world map
old_points_w = cameraToWorldCoordinatesThetaBatch(invKPs, particles_prior_this_pixel(:,2:end), size(intensities));
new_points_w = cameraToWorldCoordinatesThetaBatch(invKPs, particles(:,2:end),                  size(intensities));

    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));

old_intensities = interp2(intensities, old_points_w(:,2), old_points_w(:,1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));


for p = 1:size(particles,1)
    
    % compare current pixel's intensity with all possible previous ones
    measurements = new_intensities(p) - old_intensities;
    
    assert(~any(isnan(measurements)));
    
    % center gaussian around positive or negative threshold
    % likelihoods = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s]) + LOW_LIKELIHOOD;
    %     copied from gaussmf
    params = [INTENSITY_VARIANCE INTENSITY_THRESHOLD*event_sign];
    sigma = params(1);
    c = params(2);
    likelihoods = max(exp(-(measurements - c).^2/(2*sigma^2)), 0.01);
    
    %likelihoods = likelihoods/sum(likelihoods);
    
    % sum up likelihood over all possible positions at time of previous
    % event at that pixel
    particles(p,1) = likelihoods' * particles_prior_this_pixel(:,1); %permute(state_prior(v,u,:,1), [3 1 2 4]);
end

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles = normalizeParticles(particles);

% update state
state_prior(:,:,v,u) = particles; %particleAverage(particles);

end