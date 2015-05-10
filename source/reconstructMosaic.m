function [img, gradients] = reconstructMosaic(allAddr, allTS, thetas) %#codegen

% reconstruct the mosaic from a given set of events with corresponding
% orientations (without simulating the camera first)

outputImageSize = [3000, 6000];

boundary_image = 0.5*ones(outputImageSize);
origin = outputImageSize ./ 2;
gradients = zeros([2, outputImageSize]);
covariances = 0.5*repmat(eye(2), [1, 1, outputImageSize]);
lastSigs = zeros(128);
% lastPos = zeros(2,128,128);
lastPos = 1000000000* ones(2,128,128);
secToLastSigs = lastSigs;
secToLastPos = lastPos;
% lastPos = repmat(origin', [1, outputImageSize]);
% lastPos = round(reshape(cameraToWorldCoordinatesBatch(getInvKPsforPatch(cameraIntrinsicParameterMatrix()), [0 0 0], outputImageSize)', [2 128 128]));

% lastPos = pixelCoords;
% lastPos(:, 1:64, 1:64) = lastPos(:, 1:64, 1:64) + repmat([1 1]', [1 64 64]);
% lastPos(:, 65:end, 1:64) = lastPos(:, 65:end, 1:64) + repmat([-1 1]', [1 64 64]);
% lastPos(:, 1:64, 65:end) = lastPos(:, 1:64, 65:end) + repmat([1 -1]', [1 64 64]);
% lastPos(:, 65:end, 65:end) = lastPos(:, 65:end, 65:end) + repmat([-1 -1]', [1 64 64]);
% lastPos(:,1:5,1:5)

% K = cameraIntrinsicParameterMatrix();

nOfEvents = size(allAddr, 1);
fprintf('number of events: %d\n', nOfEvents);

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);

% pgrads = permute(gradients, [2 3 1]);
% img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
% imagesc(img);
% colormap(gray);

% invKPs = zeros([2 128 128]);
% 
% for u = 1:128
%     for v = 1:128        
%         invKP = K \ [u v 1]';  
%         invKPs(:, v, u) = invKP(1:2);     
%     end
% end

for i = 1:size(x,1)
    
    [gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos);
    
    
    if mod(i, 1000) == 0; fprintf('%d / %d\n', i, size(x,1)); end;
    if mod(i, 50000) == 0
        
%         pgrads = permute(gradients, [2 3 1]);
        
        if sum(sum(sum(isnan(gradients)))) > 0
            fprintf('gradient is NaN\n')
        end
        
        if sum(sum(sum(isinf(gradients)))) > 0
            fprintf('gradient is Inf\n');
        end
        
    end
end

pgrads = permute(gradients, [2 3 1]);
img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);




