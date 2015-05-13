function [ particles, state ] = initParticles( N, sensor_size )
%INITPARTICLES creates N particles at origin
% particle: [weight, alpha beta gamma]

particles = zeros(N, 4);

% normal particle filter (init N particles at center of map)
particles(:,1) = 1/N;
%particles(:,2:4) = [0 0 0];



% state: full particle filter for each pixel
% N * [weight, alpha beta gamma] * H * W
state = repmat(particles, [1 1 sensor_size(1) sensor_size(2)]);

%state = repmat(permute(particles, [3 4 1 2]), [sensor_size(1) sensor_size(2)]);
%%state = zeros(sensor_size(1), sensor_size(2), N, 4); % sensor_y * sensor_x * N * [weight, alpha beta gamma]

end

