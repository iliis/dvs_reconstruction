function [ world_coordinates ] = cameraToWorldCoordinatesThetaBatch( invKP, thetas, img_size )
%CAMERATOWORLDCOORDINATESTHETABATCH projects pixel coordinates into world
%
% parameters:
%  invKPs: single 2D column vector (pixel) with applied inverted camera intrinsics (i.e. K \ [u v 1]')
%  theta: N*3, Camera orientation
%  img_size: [H,W] size of world image (i.e. size(img))
%
% output:
%  N*[y, x]: pixel coordinates in world image coordinates (in range [1,img_size])


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

%assert(size(invKP,1) == 2, 'invKPs matrix must contain two values per pixel');
%assert(size(invKP,2) == 1, 'invKPs matrix must contain single row');


cosMat = cos(-thetas(:,3));
sinMat = sin(-thetas(:,3));

deltaAlphas = atan(cosMat .* invKP(2) + sinMat .* invKP(1));
deltaBetas  = atan(cosMat .* invKP(1) - sinMat .* invKP(2));

worldY = (deltaAlphas - thetas(:,1)) .* img_size(2)/(2*pi) + img_size(1)/2;
worldX = (deltaBetas  - thetas(:,2)) .* img_size(2)/(2*pi) + img_size(2)/2;

world_coordinates = [worldY worldX];

end

