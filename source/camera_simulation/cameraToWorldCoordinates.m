function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size )

assert(all([u > 0, u <= simulationPatchSize(), v > 0, v <= simulationPatchSize()]));

u = u + simulationPatchSize()/2;
v = v + simulationPatchSize()/2;

invKPs = reshape(K \ double([u v 1]'), 1, 1, 3);
world_coordinates = cameraToWorldCoordinatesBatch_mex(invKPs(:,:,1:2), theta, img_size);

end