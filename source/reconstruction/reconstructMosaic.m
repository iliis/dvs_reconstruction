function [img, gradients] = reconstructMosaic(allAddr, allTS, thetas) %#codegen

% reconstruct the mosaic from a given set of events with corresponding
% orientations (without simulating the camera first)

% get global parameters
params = getParameters();

boundary_image = 0.5*ones(params.outputImageSize);
gradients = zeros([2, params.outputImageSize]);
covariances = 10*repmat(eye(2), [1, 1, params.outputImageSize]);
lastSigs = zeros(params.simulationPatchSize);
lastPos = reshape(cameraToWorldCoordinatesBatch(getInvKPsforPatch(), thetas(1,:), params.outputImageSize)', [2 params.simulationPatchSize params.simulationPatchSize]);

nOfEvents = size(allAddr, 1);
fprintf('number of events: %d\n', nOfEvents);

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);

for i = 1:size(x,1)
    
    [gradients, covariances, lastSigs, lastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), gradients, covariances, lastSigs, lastPos);
    
    
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




