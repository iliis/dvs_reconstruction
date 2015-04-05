function particles = predict(particles)

% TODO: also store velocity (maybe also acceleration) in particles and
% predict motion (instead of just adding noise)

% TODO: linearly increase sigma with time

% Q: what is a good value for sigma?
% A: something proportional to the expected movement between two events
%    if the intensity threshold is at, say, 5 then the simulator produces
%    the first event at movement of around 0.0003, so sigma should be very
%    small (and so should the timesteps of the simulation!)
% sigma = 0.005; % good for first movement
sigma = 0.00001;

% TODO: implement perturbation in tangent space
%n = randn(1,3) * sigma; % zero mean

% TODO: this would probably work as well, right? (I don't know enough about
% Lie algebra and exponential maps)
particles(:, 2:end) = particles(:, 2:end) + sigma * randn(size(particles)-[0,1]);

end