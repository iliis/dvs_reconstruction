function [ world_coordinates ] = cameraToWorldCoordinates( u, v, K, theta, img_size )
%CAMERATOWORLDCOORDINATES Summary of this function goes here
%
% parameters:
%  u, v: pixel coordinates in camera image ([1,128])
%  K:    Camera intrinsics
%  theta: Camera orientation
%  img_size: [W,H] size of world image (i.e. [size(img,2), size(img,1)])
%
% output:
%  [x, y]: pixel coordinates in world image coordinates ([1,img_size])

% compute ray angle through pixel
% TODO: don't we have to center these coordinates? I.e. u-=64 or something.
invKP = K \ [u v 1]';
deltaAlpha = atan(cos(-theta(3))*invKP(2) + sin(-theta(3))*invKP(1));
deltaBeta  = atan(cos(-theta(3))*invKP(1) - sin(-theta(3))*invKP(2));
targetO    = [-theta(2) + deltaBeta, -theta(1) + deltaAlpha]; 

% compute coordinates in input image
% targetCoords = [targetP(2)*size(img, 2)/(2*pi) + origin(1), targetP(1)*size(img, 2)/(2*pi) + origin(2)];
world_coordinates = (targetO * img_size(2)/(2*pi)) + img_size/2;
% roundedCoords = round(targetCoords);

end

