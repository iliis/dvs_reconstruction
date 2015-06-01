function [ particles, state ] = initParticles( N, sensor_size )
%INITPARTICLES creates N particles at origin
% particle: [weight, alpha beta gamma]

% normal particle filter (init N particles at center of map)
particles = zeros(N, 4);
particles(:,1) = 1/N;

% [alpha beta gamma] * H * W
state = repmat([0 0 0]', [1 sensor_size(1) sensor_size(2)]);

end

