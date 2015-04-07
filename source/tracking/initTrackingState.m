function state = initTrackingState(particle_count, patch_size)
%INITTRACKINGSTATE store position of camera for every pixel

if nargin < 2
    patch_size = 128;
end

state = zeros(patch_size, patch_size, particle_count, 3);

end

