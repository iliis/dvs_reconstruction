function [gradients, xInds, yInds] = initializeMap(image, params)

% K = params.cameraIntrinsicParameterMatrix;
imgSize = size(image);

lt = round(cameraToWorldCoordinates(1, 1, params.cameraIntrinsicParameterMatrix, [0 0 0], params.outputImageSize));

[camCoords, width, height] = initialWorld2CamBatch(params.outputImageSize);

invKPs = reshape((params.cameraIntrinsicParameterMatrix \ [camCoords(:,1)'; camCoords(:,2)'; ones(1,width*height)])', height, width, 3);
worldCoords = round(cameraToWorldCoordinatesBatch(invKPs(:,:,1:2), [0 0 0], imgSize));

[FX, FY] = gradient(image);

xInds = lt(2) + (0:(width-1));
yInds = lt(1) + (0:(height-1));

gradients = zeros([params.outputImageSize, 2]);
gradients(yInds,xInds,2) = reshape(FX(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))), height, width)';
gradients(yInds,xInds,1) = reshape(FY(sub2ind(size(image), worldCoords(:,1), worldCoords(:,2))), height, width)';
gradients = permute(gradients, [3 1 2]);
