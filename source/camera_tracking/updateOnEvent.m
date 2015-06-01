function [particles, state_prior] = updateOnEvent(particles_prior, event, intensities, state_prior, params)
% updates particles weight according to their likelihood to match an event
% input:
%  4xN list of particles [weight, 3x rotation]
%  1 event [u,v,sign,timestamp]
%  state: position of camera for every pixel at the time of its last event [128x128x3]

assert(~any(any(isnan(intensities))), 'NaN in intensities');
assert(max(size(state_prior)) == params.simulationPatchSize);

u = event(1); v = event(2);

if event(3) > 0
    s = 1;
else
    s = -1;
end

invKPs = reshape(params.cameraIntrinsicParameterMatrix \ double([u+((params.dvsPatchSize - params.simulationPatchSize)/2) v+((params.dvsPatchSize - params.simulationPatchSize)/2) 1]'), 1, 1, 3); invKPs = invKPs(:,:,1:2);

particles = particles_prior;
new_points_w = zeros(size(particles,1),2);
particle_prior_this_pixel = permute(state_prior(:,v,u), [2 1 3]);

% get pixel coordinates in world map
% WARNING: cameraToWorldCoordinates returns [y,x] !
old_point_w = cameraToWorldCoordinatesBatch(invKPs, particle_prior_this_pixel, size(intensities));

for i = 1:size(particles,1)
    
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(intensities));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
old_intensity = interp2(intensities, old_point_w(2), old_point_w(1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));

measurements = new_intensities - old_intensity;
assert(~any(isnan(measurements)))

sigma = params.tracking.intensity_likelihood_variance;
c = params.pixelIntensityThreshold * s;
likelihoods = max(exp(-(measurements - c).^2/(2*sigma^2)), params.tracking.intensity_likelihood_min);
particles(:,1) = likelihoods;

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);
assert(~any(any(isnan(particles))));

% normalize weights
particles = normalizeParticles(particles);

% update state
state_prior(:,v,u) = permute(particleAverage(particles), [1 3 2]);

end
