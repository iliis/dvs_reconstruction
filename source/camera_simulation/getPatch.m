function patch = getPatch(img, invKPs, theta)

% Extracts a 128*128 pixel patch out of the given image, assuming this is a 360�
% panorama. The FOV depends on the camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (z axis points away from camera)
% invKPs is the matrix of each pixel coordinate multiplied with the inverse
% of K

pixelCoords = cameraToWorldCoordinatesBatch(invKPs,theta,size(img));

patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [128 128]);

end