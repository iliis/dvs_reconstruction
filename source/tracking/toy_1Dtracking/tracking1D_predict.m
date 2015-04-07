function [ particles ] = tracking1D_predict( particles, deltaT_global )

sigma = 0.0001 + 0.1*deltaT_global;
particles(:, 2:end) = particles(:, 2:end) + sigma * randn(size(particles)-[0,1]);

end

