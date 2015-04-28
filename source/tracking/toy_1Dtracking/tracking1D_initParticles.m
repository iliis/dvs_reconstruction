function [ particles, state ] = tracking1D_initParticles( N, map_size )

particles = zeros(N, 2); % [weight, xpos]
state = zeros(map_size(1), N, 2); % pixel_x * N * [weight, xpos]

if tracking1D_useSparseParticles()
    % normal particle filter (init N particles at center of map)
    particles(:,1) = 1/N;
    particles(:,2) = map_size(2)/2;
else
    particles(:,2) = linspace(1,map_size(2),N);
    particles(:,1) = gaussmf(particles(:,2), [0.001 map_size(2)/2]);
    particles = normalizeParticles(particles);
end

for i = 1:size(state,1)
    state(i,:,:) = particles;
end

end

