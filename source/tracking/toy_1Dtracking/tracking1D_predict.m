function [ particles ] = tracking1D_predict( particles, deltaT_global )

sigma = 0.0001 + 0.1*deltaT_global; 
if tracking1D_useSparseParticles()
    particles(:, 2:end) = particles(:, 2:end) + sigma * randn(size(particles)-[0,1]);
else
    particles_old = particles;
    % convolute with gaussian kernel
    for i = 1:size(particles,1)
        particles(i,1) = particles_old(:,1)' * gaussmf(particles_old(:,2), [sigma particles_old(i,2)]);
    end
    
    particles = normalizeParticles(particles);
end

end

