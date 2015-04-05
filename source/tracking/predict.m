function particles = predict(particles)

% TODO: also store velocity (maybe also acceleration) in particles and
% predict motion (instead of just adding noise)

% TODO: linearly increase sigma with time
% TODO: what is a good value for sigma?
sigma = 0.00001;

% TODO: implement perturbation in tangent space
%n = randn(1,3) * sigma; % zero mean

% TODO: this would probably work as well, right? (I don't know enough about
% Lie algebra and exponential maps)
particles(:, 2:end) = particles(:, 2:end) + sigma * randn(size(particles)-[0,1]);

end