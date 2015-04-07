function [ particles ] = tracking1D_initParticles( N, map_width )

particles = zeros(N, 2); % [weight, xpos]
particles(:,1) = 1/N;
particles(:,2) = map_width/2;

end

