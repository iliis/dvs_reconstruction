function [ map, nextInd] = integrateInitialEvents(events, maxTime, imgSize)

% this function takes all events up to a timestamp of maxTime, integrates
% them and returns the integrated image together with the
% first event index that was not used any more
% input:
% events: N*4 matrix [x y pol ts]
% maxTime: the time over that should be integrated
% imgSize: the desired size of the image
% output:
% map: the integrated image
% nextInd: smallest i so that events(i,4) > maxTime

nextInd = 1;
while events(nextInd, 4) <= maxTime
     nextInd = nextInd + 1;
end

initEvents = events(1:(nextInd-1), :);

integratedImage = integrateEvents(initEvents);
integratedImage = integratedImage * pixelIntensityThreshold() + 0.5;

maxVal = max(max(integratedImage))
minVal = min(min(integratedImage))
% 
% % scale to stay in range
% integratedImage = (integratedImage ./ (maxVal - minVal));
% integratedImage = integratedImage - min(min(integratedImage));
% 
% maxVal = max(max(integratedImage))
% minVal = min(min(integratedImage))

K = cameraIntrinsicParameterMatrix();
ulCorner = round(cameraToWorldCoordinates(1, 1, K, [0 0 0], imgSize));
urCorner = round(cameraToWorldCoordinates(1, 128, K, [0 0 0], imgSize));
dlCorner = round(cameraToWorldCoordinates(128, 1, K, [0 0 0], imgSize));
% dlCorner = round(cameraToWorldCoordinates(128, 128, K, [0 0 0], imgSize))

xDiff = urCorner(1) - ulCorner(1);
yDiff = dlCorner(2) - ulCorner(2);
xCoords = linspace(1,128, xDiff);
yCoords = linspace(1,128,yDiff);
[X, Y] = meshgrid(xCoords, yCoords);

vals = interp2(integratedImage, X, Y);

vals = reshape(vals, yDiff, xDiff);
worldImage = 0.5*ones(imgSize);

invKPs = reshape((cameraIntrinsicParameterMatrix() \ [X(:)'; Y(:)'; ones(1,xDiff*yDiff)])', yDiff, xDiff, 3);
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], imgSize));
worldImage(sub2ind(size(worldImage), worldCoords(:,1), worldCoords(:,2))) = vals(:);

map = worldImage;

% [FX, FY] = gradient(worldImage);
% 
% gradients = zeros([500, 1000, 2]);
% gradients(:,:,1) = FX;
% gradients(:,:,2) = FY;
% gradients = permute(gradients, [3 1 2]);