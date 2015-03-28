function particles = resample(old_particles)
% input:  4xN list of particles [normalized weight, 3xrot]
% output: 4xN resampled list of particles

% TODO: there are exacter ways to implement resampling

% trivial resampling algorithm
% copy particle with probability according to its weight
particles = zeros(size(old_particles));
for i = 1:size(particles,2)
    
    % choose a particle
    u = rand(1);
    
    % actually find chosen particle
    tmp_sum = 0;
    for k = 1:size(old_particles,2)
        if (u >= tmp_sun) && (u < tmp_sun+old_particles(1,k))
            break;
        end
        tmp_sum = tmp_sum + old_particles(1,k);
    end
    
    % copy
    particles(2:end,i) = old_particles(2:end,k);
    
    % assign new weight
    particles(1,i) = 1/size(particles,2);
end

assert(sum(particles(1,:)) == 1, 'New weights must sum to 1.');
assert(sum(particles(1,:)<0) == 0, 'New weights must be >= 0.');

end