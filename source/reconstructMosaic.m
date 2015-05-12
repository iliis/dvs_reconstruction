function [img, gradients] = reconstructMosaic(allAddr, allTS, thetas) %#codegen

% reconstruct the mosaic from a given set of events with corresponding
% orientations (without simulating the camera first)

outputImageSize = [2000, 4000];

boundary_image = 0.5*ones(outputImageSize);
origin = outputImageSize ./ 2;
gradients = zeros([2, outputImageSize]);
covariances = 10*repmat(eye(2), [1, 1, outputImageSize]);
lastSigs = zeros(128);
% lastPos = 1000000000* ones(2,128,128);
% lastPos = reshape(cameraToWorldCoordinatesBatch(getInvKPsforPatch(cameraIntrinsicParameterMatrix()), [0 0 0], outputImageSize)', [2 128 128]);
lastPos = reshape(cameraToWorldCoordinatesBatch(getInvKPsforPatch(cameraIntrinsicParameterMatrix()), thetas(1,:), outputImageSize)', [2 128 128]);
secToLastSigs = lastSigs;
secToLastPos = lastPos;

nOfEvents = size(allAddr, 1);
fprintf('number of events: %d\n', nOfEvents);

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);

% pgrads = permute(gradients, [2 3 1]);
% img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
% imagesc(img);
% colormap(gray);

for i = 1:size(x,1)
    
    [gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos);
    
    
    if mod(i, 1000) == 0; fprintf('%d / %d\n', i, size(x,1)); end;
    if mod(i, 50000) == 0
        
%         pgrads = permute(gradients, [2 3 1]);
        
        if any(isnan(gradients))
            fprintf('gradient is NaN\n')
        end
        
        if sum(sum(sum(isinf(gradients)))) > 0
            fprintf('gradient is Inf\n');
        end
        
    end
end

pgrads = permute(gradients, [2 3 1]);
img = poisson_solver_function(pgrads(:,:,2), pgrads(:,:,1), boundary_image);




