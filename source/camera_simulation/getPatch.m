function patch = getPatch(img, invKPs, alpha, beta, gamma)

% Extracts a 128*128 pixel patch out of the given image, assuming this is a 360°
% panorama. The FOV depends on the given camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (z axis points away from camera)

origin = size(img)/2;

pixelCoords = double(zeros(128*128, 2));

% compute positions in global image
for u = 1:128
    for v = 1:128
%         compute ray angle through pixel
        invKP = invKPs(:, v, u);
        deltaAlpha = atan(cos(-gamma)*invKP(2) + sin(-gamma)*invKP(1));
        deltaBeta = atan(cos(-gamma)*invKP(1) - sin(-gamma)*invKP(2));
        targetO = [-alpha + deltaAlpha, -beta + deltaBeta]; 
        
%         compute coordinates in input image
        targetCoords = (targetO * size(img, 2)/(2*pi)) + origin;
        pixelCoords((u-1)*128 + v, :) = targetCoords;
    end
end

patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [128 128]);