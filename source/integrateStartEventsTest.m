function integrateStartEventsTest()

[allAddr, allTs] = loadaerdat('../../CamLog_shaking_long_PCLab.aedat');

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);
events = [double(x+1) double(y+1) double(pol) double(allTs - allTs(1) + 1)];

nextInd = 1;
while events(nextInd, 4) <= 1000
     nextInd = nextInd + 1;
end
nextInd
initEvents = events(1:(nextInd-1), :);

integratedImage = integrateEvents(initEvents);
[FX, FY] = gradient(integratedImage);

gradients = zeros([128, 128, 2]);
gradients(:,:,1) = FY;
gradients(:,:,2) = FX;
gradients = permute(gradients, [3 1 2]);
image = integratedImage;
% imagesc(flipud(image))


K = cameraIntrinsicParameterMatrix();
img_size = [500 1000];
ulCorner = round(cameraToWorldCoordinates(1, 1, K, [0 0 0], img_size))
urCorner = round(cameraToWorldCoordinates(1, 128, K, [0 0 0], img_size))
dlCorner = round(cameraToWorldCoordinates(128, 1, K, [0 0 0], img_size))
% dlCorner = round(cameraToWorldCoordinates(128, 128, K, [0 0 0], img_size))

xDiff = urCorner(1) - ulCorner(1);
yDiff = dlCorner(2) - ulCorner(2);
xCoords = linspace(1,128, xDiff);
yCoords = linspace(1,128,yDiff);
[X Y] = meshgrid(xCoords, yCoords);

vals = interp2(image, X, Y);
size(vals)

vals = reshape(vals, yDiff, xDiff);
worldImage = zeros(img_size);
invKPs = cameraIntrinsicParameterMatrix() \ [X(:)'; Y(:)'; ones(1,xDiff*yDiff)];

invKPs = reshape((cameraIntrinsicParameterMatrix() \ [X(:)'; Y(:)'; ones(1,xDiff*yDiff)])', yDiff, xDiff, 3);
size(invKPs)
invKPs(1,1,:)
invKPs(100,100,:)
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], img_size));
worldCoordsize = size(worldCoords)
worldImage(sub2ind(size(worldImage), worldCoords(:,1), worldCoords(:,2))) = vals(:);
% imagesc(poisson_solver_function(flipud(worldImage)))

[FX, FY] = gradient(worldImage);

gradients = zeros([500, 1000, 2]);
gradients(:,:,1) = FX;
gradients(:,:,2) = FY;
gradients = permute(gradients, [3 1 2]);
pgrads = permute(gradients, [2 3 1]);
boundary_image = 0.5*ones(500,1000);
subplot(1,2,1);
imagesc(pgrads(:,:,1))
colorbar;
subplot(1,2,2)
imagesc(pgrads(:,:,2))
colorbar;
map = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
figure;
imagesc(map);

% 