function [ world_coordinates ] = cameraToWorldCoordinatesBatch( invKPs, theta, img_size ) %#codegen
%CAMERATOWORLDCOORDINATES Summary of this function goes here
%
% parameters:
%  invKPs: list 128x128x2 of pixels with applied inverted camera intrinsics (i.e. K \ [u v 1]')
%  theta: Camera orientation
%  img_size: [H,W] size of world image (i.e. size(img))
%  //img_size: [W,H] size of world image (i.e. [size(img,2), size(img,1)])
%
% output:
%  [y, x]: pixel coordinates in world image coordinates ([1,img_size])


% % compute ray angle through pixel
% % TODO: don't we have to center these coordinates? I.e. u-=64 or something.
% % -> No, this is already included in K, the camera intrinsics
% invKP = K \ [u v 1]';
% deltaAlpha = atan(cos(-theta(3))*invKP(2) + sin(-theta(3))*invKP(1));
% deltaBeta  = atan(cos(-theta(3))*invKP(1) - sin(-theta(3))*invKP(2));
% targetO    = [-theta(2) + deltaBeta, -theta(1) + deltaAlpha]; 
% 
% % compute coordinates in input image
% % targetCoords = [targetP(2)*size(img, 2)/(2*pi) + origin(1), targetP(1)*size(img, 2)/(2*pi) + origin(2)];
% world_coordinates = (targetO * img_size(2)/(2*pi)) + img_size/2;
% % roundedCoords = round(targetCoords);


origin = zeros([1 1 2]);
origin(1,1,:) = img_size/2;

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

% this condition could easily be removed by refactoring these calculations
assert(size(invKPs,1) == size(invKPs,2), 'invKPs matrix must be square');

assert(size(invKPs,3) == 2, 'invKPs matrix must contain two values per pixel');


N = size(invKPs,1);

cosMat = cos(-theta(3))*ones(N);
sinMat = sin(-theta(3))*ones(N);

deltaAlphas = atan(cosMat .* invKPs(:,:,2) + sinMat .* invKPs(:,:,1));
deltaBetas  = atan(cosMat .* invKPs(:,:,1) - sinMat .* invKPs(:,:,2));
targetOs = zeros(size(invKPs));
targetOs(:,:,1) = -theta(1)*ones(N) + deltaAlphas;
targetOs(:,:,2) = -theta(2)*ones(N) + deltaBetas;

targetCoords = (targetOs .* (double(img_size(2))/(2*pi))) + repmat(double(origin), [N N 1]);

world_coordinates = reshape(targetCoords, N*N, 2);


end

