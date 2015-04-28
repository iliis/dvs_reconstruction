function tracking1D_plotParticles( particles, color )

if nargin < 2
    color = 'red';
end

sigma = 0.01;

if tracking1D_useSparseParticles()
%     particles_m = mergeParticles(particles, 0.1);
% 
%     bar(particles_m(:,2), particles_m(:,1)); %, 0.001);
% 
%     N = size(particles_m,1);
%     eff_N = effectiveParticleNumber(particles_m);
%     title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);
%     
    
    xvalues = linspace(min(particles(:,2))-2, max(particles(:,2))+2, size(particles,1));
    yvalues = zeros(size(xvalues));
    
    for p = 1:size(particles,1)
        yvalues = yvalues + gaussmf(xvalues, [sigma particles(p,2)]) * particles(p,1);
    end
    
    hold on;
    plot(xvalues, yvalues, '-', 'Color', color);
    hold off;
    
else
    plot(particles(:,2), particles(:,1),'-', 'Color', color);
    if max(particles(:,1)) > 0.2
        ylim([0 1]);
    else
        ylim([0 0.2]);
    end
end
    

end

