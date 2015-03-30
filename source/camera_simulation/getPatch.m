function patch = getPatch(img, invKPs, alpha, beta, gamma)

% Extracts a 128*128 pixel patch out of the given image, assuming this is a 360°
% panorama. The FOV depends on the camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (z axis points away from camera)
% invKPs is the matrix of each pixel coordinate multiplied with the inverse
% of K

% origin = zeros([1 1 2]);
origin(1,1,:) = size(img)/2;

% commented part kept to understand the used formula

% pixelCoords = double(zeros(128*128, 2));
% 
% % compute positions in global image
% for u = 1:128
%     for v = 1:128
% %         compute ray angle through pixel
%         invKP = invKPs(v, u, :);
%         deltaAlpha = atan(cos(-gamma)*invKP(2) + sin(-gamma)*invKP(1));
%         deltaBeta = atan(cos(-gamma)*invKP(1) - sin(-gamma)*invKP(2));
%         targetO = [-alpha + deltaAlpha, -beta + deltaBeta]; 
%         
% %         compute coordinates in input image
%         targetCoords = (targetO * size(img, 2)/(2*pi)) + origin(:)';
%         pixelCoords((u-1)*128 + v, :) = targetCoords;
%     end
% end

cosMat = cos(-gamma)*ones(128);
sinMat = sin(-gamma)*ones(128);

deltaAlphas = atan(cosMat .* invKPs(:,:,2) + sinMat .* invKPs(:,:,1));
deltaBetas = atan(cosMat .* invKPs(:,:,1) + sinMat .* invKPs(:,:,2));
targetOs = zeros([128 128 2]);
targetOs(:,:,1) = -alpha*ones(128) + deltaAlphas;
targetOs(:,:,2) = -beta*ones(128) + deltaBetas;
targetCoords = (targetOs * size(img, 2)/(2*pi)) + repmat(origin, [128 128]);
pixelCoords = reshape(targetCoords, 16384, 2);

patch = reshape(interp2(img, pixelCoords(:,2), pixelCoords(:,1)), [128 128]);