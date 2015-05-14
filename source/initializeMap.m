function [map, gradients] = initializeMap(image, mapSize)

K = cameraIntrinsicParameterMatrix();
imgSize = size(image);

lt = round(cameraToWorldCoordinates(1, 1, K, [0 0 0], mapSize));
% rt = round(cameraToWorldCoordinates(64, 1, K, [0 0 0], imgSize));
% lb = round(cameraToWorldCoordinates(1, 64, K, [0 0 0], imgSize));

[camCoords, width, height] = initialWorld2CamBatch(mapSize);

invKPs = reshape((cameraIntrinsicParameterMatrix() \ [camCoords(:,1)'; camCoords(:,2)'; ones(1,width*height)])', height, width, 3);
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], imgSize));
% worldImage(sub2ind(size(worldImage), worldCoords(:,1), worldCoords(:,2))) = vals(:);

map = 0.5*ones(mapSize);
% 
% height
% width
% lt
% mapSize
% lt(1) + height-1
% lt(2) + width - 1
% size(worldCoords)
% size(image(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))))
% size(map(lt(1) + (0:(height-1)), lt(2) + (0:(width-1))))
% map(lt(1) + (0:(height-1)), lt(2) + (0:(width-1))) = reshape(image(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))), height, width)';

% map(lt(1):lb(1), lt(2):rt(2)) = image(lt(1):lb(1), lt(2):rt(2));

[FX, FY] = gradient(image);

gradients = zeros([mapSize, 2]);
gradients(lt(1) + (0:(height-1)), lt(2) + (0:(width-1)),1) = reshape(FX(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))), height, width)';
gradients(lt(1) + (0:(height-1)), lt(2) + (0:(width-1)),2) = reshape(FY(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))), height, width)';
gradients = permute(gradients, [3 1 2]);
