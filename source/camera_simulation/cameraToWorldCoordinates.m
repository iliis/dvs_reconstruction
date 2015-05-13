function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size )

assert(all([u > 0, u <= 64, v > 0, v <= 64]));

u = u + 32;
v = v + 32;

invKPs = reshape(K \ double([u v 1]'), 1, 1, 3);
world_coordinates = cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), theta, img_size);

end