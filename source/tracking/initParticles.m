function [ particles, state ] = initParticles( N, sensor_size )
%INITPARTICLES creates N particles at origin
% particle: [weight, alpha beta gamma]

% normal particle filter (init N particles at center of map)
particles = zeros(N, 4);
particles(:,1) = 1/N;

% state: full particle filter for each pixel
% N * [weight, alpha beta gamma] * H * W
state = repmat(particles, [1 1 sensor_size(1) sensor_size(2)]);

end

