function particles = predict(particles, deltaT_global)

% TODO: also store velocity (maybe also acceleration) in particles and
% predict motion (instead of just adding noise)

% TODO: update this Q'n'A ;)
% Q: what is a good value for sigma?
% A: something proportional to the expected movement between two events
%    if the intensity threshold is at, say, 5 then the simulator produces
%    the first event at movement of around 0.0003, so sigma should be very
%    small (and so should the timesteps of the simulation!)
%    as a rule of thumb: sigma ~ motion_speed * gradient
% sigma = 0.005; % good for first movement
% sigma = 0.00001;

% TODO: find good values for sigma here (dependent on average time between
% events and movement in that period)

% the longer we wait between events, the longer the camera probably moved
% also allow some error even when the camera didn't move at all
% sigma = 0.00001 + 0.0002 * deltaT_global;
sigma = 0.00002 * deltaT_global;
% sigma = 0.000001 + 0.000004 * deltaT_global;

% TODO: implement perturbation in tangent space
%n = randn(1,3) * sigma; % zero mean

% TODO: this would probably work as well, right? (I don't know enough about
% Lie algebra and exponential maps)
particles(:, 2:end) = particles(:, 2:end) + double(sigma) * randn(size(particles)-[0,1]);

% disp(['predict: deltaT = ' num2str(deltaT_global)]);

end