function [particles, state_prior] = updateOnEventAverage(particles_prior, event, intensities, state_prior)
% input:
%  4xN list of particles [weight, 3x rotation]
%  1 event [u,v,sign,timestamp]
%  state: position of camera for every pixel at the time of its last event [128x128x3]

assert(~any(any(isnan(intensities))), 'NaN in intensities');

% right now it causes problems if the function was compiled with a
% different simulationPatchSize(). Make sure we abort directly instead of
% wondering why it does not work as expected
% TODO: FIX!!
assert(max(size(state_prior)) == simulationPatchSize());

% TODO: these values were chosen arbitrariliy!
LOW_LIKELIHOOD = 0.02;
INTENSITY_VARIANCE  = 0.08; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;
u = event(1); v = event(2);

if event(3) > 0
    s = 1;
else
    s = -1;
end

K = double(cameraIntrinsicParameterMatrix());

% TODO: could this be replaced with getInvKPsforPatch()? if not -> refactor
% since sinulationPatchSize() seems to become a constant when compiled
invKPs = reshape(K \ double([u+simulationPatchSize()/2 v+simulationPatchSize()/2 1]'), 1, 1, 3); invKPs = invKPs(:,:,1:2);

particles = particles_prior;
% old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);
particle_prior_this_pixel = permute(state_prior(:,v,u), [2 1 3]);

% get pixel coordinates in world map
% WARNING: cameraToWorldCoordinates returns [y,x] !
old_point_w = cameraToWorldCoordinatesBatch(invKPs, particle_prior_this_pixel, size(intensities));

for i = 1:size(particles,1)
    
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(intensities));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));

% likelihoods = zeros(size(particles,1),1);
old_intensity = interp2(intensities, old_point_w(2), old_point_w(1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));

measurements = new_intensities - old_intensity;

assert(~any(isnan(measurements)))

sigma = INTENSITY_VARIANCE;
c = INTENSITY_THRESHOLD * s;
likelihoods = max(exp(-(measurements - c).^2/(2*sigma^2)), LOW_LIKELIHOOD);
% likelihoods(sign(measurements) ~= sign(s)) = LOW_LIKELIHOOD;
particles(:,1) = likelihoods;

% for p = 1:size(particles,1)
%     
%     % compare current pixel's intensity with all possible previous ones
%     measurements = new_intensities(p) - old_intensity;
%     
%     assert(~any(isnan(measurements)));
%     
%     % no need for LOW_LIKELIHOOD, just center gaussian around positive or negative threshold
%     %     copied from gaussmf
%     params = [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s];
%     sigma = params(1);
%     c = params(2);
%     likelihood = max(exp(-(measurements - c).^2/(2*sigma^2)), 0.01);
%     %     likelihoods = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s]);
%     %likelihoods = likelihoods/sum(likelihoods);
%     
%     % sum up likelihood over all possible positions at time of previous
%     % event at that pixel
% %     particles(p,1) = likelihoods' * state_prior(v,u,1);
%     particles(p,1) = likelihood;
% end

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);
assert(~any(any(isnan(particles))));

% % actually update prior probability
% particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles = normalizeParticles(particles);

% update state
state_prior(:,v,u) = permute(particleAverage(particles), [1 3 2]);
