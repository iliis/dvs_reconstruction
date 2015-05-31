function patch = getPatch(img, invKPs, theta)

% Extracts a 128*128 pixel patch out of the given image, assuming this is a 360�
% panorama. The FOV depends on the camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (x axis points up, z axis points away from camera)
% invKPs is the matrix of each pixel coordinate multiplied with the inverse
% of K

pixelCoords = cameraToWorldCoordinatesBatch(invKPs,theta,size(img));

% patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [simulationPatchSize() simulationPatchSize()]);

% this is a relatively ugly fix, but necessary to make the compiled version
% work with changing patch sizes without recompiling -> refactor to make
% patch size explicit input argument?
patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [size(invKPs,1) size(invKPs,2)]);

end