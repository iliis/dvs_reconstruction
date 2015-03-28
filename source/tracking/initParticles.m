function [ particles ] = initParticles( N )
%INITPARTICLES creates N particles at origin

particles = zeroes(N, 4);
particles(1, :) = 1/N;

end

