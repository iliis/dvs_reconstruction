function patch = getPatch(img, invKPs, theta, cameraSize)

% Extracts a 'cameraSize'x'cameraSize' sized pixel patch out of the given image,
% assuming this is a 360 degree panorama.
% The FOV depends on the camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (x axis points up, z axis points away from camera)
% invKPs is the matrix of each pixel coordinate multiplied with the inverse
% of K
% input:
% img: the input image
% invKPs: matrix with the products of pixel positions and the inverse of K
% theta: the 1x3 vector with angles [alpha, beta, gamma]
% cameraSize: the side length of the square camera (in pixels)

pixelCoords = cameraToWorldCoordinatesBatch(invKPs,theta,size(img));

patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [cameraSize, cameraSize]);

end