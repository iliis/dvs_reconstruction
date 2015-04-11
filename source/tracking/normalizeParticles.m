function particles = normalizeParticles( particles )

particles(:,1) = particles(:,1)/sum(particles(:,1));

end

