function [ particles ] = mergeParticles( particles, width )

if nargin == 1
    width = 0.5;
end

sortrows(particles,2);
%for i = 2:size(particles,1)
i = 2;
while i <= size(particles,1) && size(particles,1) > 1
    if particles(i,2) >= particles(i-1,2) && particles(i,2) < particles(i-1,2)+width
        % merge row into previous one
        particles(i-1,1) = particles(i-1,1) + particles(i,1); % add weights
        particles(i,:)   = []; % delete row
    else
        i = i+1;
    end
end

end

