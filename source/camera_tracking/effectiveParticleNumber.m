function Neff = effectiveParticleNumber(particles)
% 'effective number' of particles, used to determine if resampling is necessary
% input 4xN or 1xN vector of particles (with data or just weights)

weights = particles(:,1);
Neff = 1 / sum(weights.^2);

end