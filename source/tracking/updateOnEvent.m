function [particles, state] = updateOnEvent(particles_prior, event, intensities, state_prior) %#codegen
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
    s = 1;
else
    s = -1;
end

K = double(cameraIntrinsicParameterMatrix());
invKPs = reshape(K \ double([u v 1]'), 1, 1, 3); invKPs = invKPs(:,:,1:2);

particles = particles_prior;
old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);
particles_prior_this_pixel = permute(state_prior(v,u,:,:), [3 4 1 2]);

for i = 1:size(particles_prior,1)
    % get pixel coordinates in world map
    old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior_this_pixel(i,2:end), size(intensities));
    
    %old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior(i,2:end), size(intensities));
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(intensities));
%     assert(~any(any(isnan(new_points_w))))%, sprintf('NaN in new_points_w (particle %d)', i));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));

% likelihoods = zeros(size(particles,1),1);
old_intensities = interp2(intensities, old_points_w(:,2), old_points_w(:,1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));


for p = 1:size(particles,1)
    
    % compare current pixel's intensity with all possible previous ones
    measurements = new_intensities(p) - old_intensities;
    
    assert(~any(isnan(measurements)));
    
    % no need for LOW_LIKELIHOOD, just center gaussian around positive or negative threshold
    %     copied from gaussmf
    params = [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s];
    sigma = params(1);
    c = params(2);
    likelihoods = max(exp(-(measurements - c).^2/(2*sigma^2)), 0.01);
    %     likelihoods = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s]);
    %likelihoods = likelihoods/sum(likelihoods);
    
    % sum up likelihood over all possible positions at time of previous
    % event at that pixel
    particles(p,1) = likelihoods' * permute(state_prior(v,u,:,1), [3 1 2 4]);
end

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles = normalizeParticles(particles);

% update state
state = state_prior;
state(v,u,:,:) = particles; %particleAverage(particles);

end