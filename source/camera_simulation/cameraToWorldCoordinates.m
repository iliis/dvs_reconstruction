function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size, allow_outside )

<<<<<<< HEAD
params = getParameters();

assert(all([u > 0, u <= params.simulationPatchSize, v > 0, v <= params.simulationPatchSize]));

indexOffset = (params.dvsPatchSize - params.simulationPatchSize)/2;
u = u + indexOffset;
v = v + indexOffset;
=======
if (nargin < 6)
    % usually, we shouldn't get coordinates outside the patch region, but
    % for debugging purposes (e.g. plotCameraRect()) it can be useful
    allow_outside = false;
end

if ~allow_outside
    assert(all([u > 0, u <= simulationPatchSize(), v > 0, v <= simulationPatchSize()]));
end
>>>>>>> tracking

invKPs = reshape(K \ double([u v 1]'), 1, 1, 3);
%world_coordinates = cameraToWorldCoordinatesBatch_mex(invKPs(:,:,1:2), theta, img_size);
world_coordinates = cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), theta, img_size);

end