function particles = predict(particles, deltaT_global)
% predict new camera position based on current position and time since last update
%
% This is simply a constant position motion model + gaussian noise
%
% TODO: also store velocity (maybe also acceleration) in particles and
% predict motion (instead of just adding noise)

params = getParameters();

sigma = params.tracking.predictSigma * deltaT_global;

particles(:, 2:end) = particles(:, 2:end) + double(sigma) * randn(size(particles)-[0,1]);

disp(['predict: deltaT = ' num2str(deltaT_global)]);

end