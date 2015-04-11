function tracking1D_plotParticles( particles, color )

if nargin < 2
    color = 'red';
end

if tracking1D_useSparseParticles()
    particles = mergeParticles(particles, 0.1);

    bar(particles(:,2), particles(:,1)); %, 0.001);

    N = size(particles,1);
    eff_N = effectiveParticleNumber(particles);
    title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);
else
    plot(particles(:,2), particles(:,1),'-', 'Color', color);
    if max(particles(:,1)) > 0.2
        ylim([0 1]);
    else
        ylim([0 0.2]);
    end
end
    

end

