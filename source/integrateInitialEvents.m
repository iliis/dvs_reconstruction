function [ gradients, nextInd] = integrateInitialEvents(events, maxTime, imgSize)

% this function takes all events up to a timestamp of maxTime, integrates
% them and returns a gradient of the integrated image together with the
% first event index that was not used any more
% input:
% events: N*4 matrix [x y pol ts]
% maxTime: the time over that should be integrated
% output:
% gradients: the gradient map of the integrated image
% nextInd: smallest i so that events(i,4) > maxTime
% imgSize: the desired size of the image

nextInd = 1;
while events(nextInd, 4) <= maxTime
     nextInd = nextInd + 1;
end

initEvents = events(1:(nextInd-1), :);

integratedImage = integrateEvents(initEvents);

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
worldImage = zeros(imgSize);

invKPs = reshape((cameraIntrinsicParameterMatrix() \ [X(:)'; Y(:)'; ones(1,xDiff*yDiff)])', yDiff, xDiff, 3);
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], imgSize));
worldImage(sub2ind(size(worldImage), worldCoords(:,1), worldCoords(:,2))) = vals(:);

[FX, FY] = gradient(worldImage);

gradients = zeros([500, 1000, 2]);
gradients(:,:,1) = FX;
gradients(:,:,2) = FY;
gradients = permute(gradients, [3 1 2]);