function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size )

params = getParameters();

assert(all([u > 0, u <= params.simulationPatchSize, v > 0, v <= params.simulationPatchSize]));

indexOffset = (params.dvsPatchSize - params.simulationPatchSize)/2;
u = u + indexOffset;
v = v + indexOffset;

invKPs = reshape(K \ double([u v 1]'), 1, 1, 3);
%world_coordinates = cameraToWorldCoordinatesBatch_mex(invKPs(:,:,1:2), theta, img_size);
world_coordinates = cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), theta, img_size);

end