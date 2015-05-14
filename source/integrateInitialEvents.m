function [ map, gradients, nextInd] = integrateInitialEvents(events, maxTime, imgSize)

% this function takes all events up to a timestamp of maxTime, integrates
% them and returns the gradients of the integrated image together with the
% first event index that was not used any more
% input:
% events: N*4 matrix [x y pol ts]
% maxTime: the time over that should be integrated
% imgSize: the desired size of the image
% output:
% gradients: the gradients of the integrated image
% nextInd: smallest i so that events(i,4) > maxTime

nextInd = 1;
while events(nextInd, 4) <= maxTime
     nextInd = nextInd + 1;
end

initEvents = events(1:(nextInd-1), :);
initEvents(:,1:2) = initEvents(:,1:2) + 32;

integratedImage = integrateEvents(initEvents);
integratedImage = integratedImage * pixelIntensityThreshold() + 0.5;

maxVal = max(max(integratedImage));
minVal = min(min(integratedImage));

disp(['extreme values in initial integrated image: ' num2str([minVal maxVal])]);
% 
% % scale to stay in range
% integratedImage = (integratedImage ./ (maxVal - minVal));
% integratedImage = integratedImage - min(min(integratedImage));
% 
% maxVal = max(max(integratedImage))
% minVal = min(min(integratedImage))

[camCoords, width, height] = initialWorld2CamBatch(imgSize);

% K = cameraIntrinsicParameterMatrix();
% ulCorner = round(cameraToWorldCoordinates(1, 1, K, [0 0 0], imgSize));
% urCorner = round(cameraToWorldCoordinates(1, 128, K, [0 0 0], imgSize));
% dlCorner = round(cameraToWorldCoordinates(128, 1, K, [0 0 0], imgSize));
% % dlCorner = round(cameraToWorldCoordinates(128, 128, K, [0 0 0], imgSize))
% 
% xDiff = urCorner(1) - ulCorner(1);
% yDiff = dlCorner(2) - ulCorner(2);
% xCoords = linspace(1,128, xDiff);
% yCoords = linspace(1,128,yDiff);
% [X, Y] = meshgrid(xCoords, yCoords);

% vals = interp2(integratedImage, X, Y);
vals = interp2(integratedImage, camCoords(:,1), camCoords(:,2));

% vals = reshape(vals, yDiff, xDiff);
vals = reshape(vals, height, width);
worldImage = 0.5*ones(imgSize);



invKPs = reshape((cameraIntrinsicParameterMatrix() \ [camCoords(:,1)'; camCoords(:,2)'; ones(1,width*height)])', height, width, 3);
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], imgSize));
worldImage(sub2ind(size(worldImage), worldCoords(:,1), worldCoords(:,2))) = vals(:);

map = worldImage;

[FX, FY] = gradient(worldImage);

gradients = zeros([imgSize, 2]);
gradients(:,:,1) = FX;
gradients(:,:,2) = FY;
gradients = permute(gradients, [3 1 2]);