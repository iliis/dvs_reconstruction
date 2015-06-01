function particles = predict(particles, deltaT_global)

% TODO: also store velocity (maybe also acceleration) in particles and
% predict motion (instead of just adding noise)

params = getParameters();

sigma = params.tracking.predictSigma * deltaT_global;

particles(:, 2:end) = particles(:, 2:end) + double(sigma) * randn(size(particles)-[0,1]);

disp(['predict: deltaT = ' num2str(deltaT_global)]);

end