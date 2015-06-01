function particles = normalizeParticles( particles )
% normalizes particle weights so that they sum up to one

particles(:,1) = particles(:,1)/sum(particles(:,1));

end

