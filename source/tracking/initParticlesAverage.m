function [ particles, state ] = initParticlesAverage( N, sensor_size )
%INITPARTICLES creates N particles at origin
% particle: [weight, alpha beta gamma]

particles = zeros(N, 4);

% normal particle filter (init N particles at center of map)
particles(:,1) = 1/N;
%particles(:,2:4) = [0 0 0];

% full particle filter for each pixel
%state = zeros(sensor_size(1), sensor_size(2), N, 4); % sensor_y * sensor_x * N * [weight, alpha beta gamma]

state = repmat([0 0 0]', [1 sensor_size(1) sensor_size(2)]);

end

