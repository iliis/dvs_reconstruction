function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size )

invKPs = reshape(K \ double([u v 1]'), 1, 1, 3);
world_coordinates = cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), theta, img_size);

end