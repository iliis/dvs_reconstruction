function tracking1D_plotParticles( particles )

particles = mergeParticles(particles, 0.1);

bar(particles(:,2), particles(:,1)); %, 0.001);

N = size(particles,1);
eff_N = effectiveParticleNumber(particles);
title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);

end

