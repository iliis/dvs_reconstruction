function theta_avg = particleAverage( particles )
% calculates weighted average over all particles position

% TODO: use fancy SO(3) space math to handle angle 'overflows'

% weighted average (with normalized weights)
particles = repmat(particles(:,1),1,3) ./ sum(particles(:,1)) .* particles(:,2:end);

% average (not actually necessary, the weights are summed up to one
%theta_avg = mean(particles,1);
theta_avg = sum(particles, 1);

end

