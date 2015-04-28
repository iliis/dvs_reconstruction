function [particles, state] = tracking1D_updateOnEvent(particles_prior, event, map, state_prior, deltaT_global)
% update likelihood according to event

% event: [ydim sign timestamp real_xpos]
% state: (map_dimy) * (particle_count) * [particle_weight particle_xpos]

% don't do prediction here

LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 0.1; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = tracking1D_pixelIntensityThreshold(); %0.22;

if event(2) > 0
    s = 1;
else
    s = -1;
end

d = event(1);

assert(sum(sum(isnan(particles_prior))) == 0);

previous_intensities = tracking1D_getMapValue(map, state_prior(d,:,2));
current_intensities  = tracking1D_getMapValue(map, particles_prior(:,2));

% we're only interested in current map row
previous_intensities = previous_intensities(d,:);
current_intensities  = current_intensities(d,:);

particles = particles_prior;
for p = 1:size(particles_prior,1)
    
    % compare current pixel's intensity with all possible previous ones
    measurements = current_intensities(p) - previous_intensities;
    
    % no need for LOW_LIKELIHOOD, just center gaussian around positive or negative threshold
    likelihoods = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD*s]);
    %likelihoods = likelihoods/sum(likelihoods);
    
    % sum up likelihood over all possible positions at time of previous
    % event at that pixel
    particles(p,1) = likelihoods * state_prior(d,:,1)';
end

% actual bayesian update
particles(:,1) = particles(:,1) .* particles_prior(:,1);

particles = normalizeParticles(particles);

if tracking1D_useSparseParticles()
    eff_N = effectiveParticleNumber(particles);
    disp(['effective Number = ' num2str(eff_N)]);
    if eff_N < size(particles,1)/2
        particles = resample(particles);
        eff_N = effectiveParticleNumber(particles);
        disp([' -> resample: effective Number = ' num2str(eff_N)]);
    end
end

state = state_prior;
state(d,:,:) = particles;

assert(~any(isnan(particles(:))));

end

