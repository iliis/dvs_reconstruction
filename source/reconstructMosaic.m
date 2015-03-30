function [img, gradients] = reconstructMosaic(allAddr, allTS, thetas)

% reconstruct the mosaic from a given set of events with corresponding
% orientations (without simulating the camera first)

outputImageSize = [500, 1000];

boundary_image = 0.5*ones(outputImageSize);

gradients = zeros([2, outputImageSize]);
covariances = 10*repmat(eye(2), [1, 1, outputImageSize]);
lastSigs = zeros(128);
lastPos = zeros(2,128,128);

K = cameraIntrinsicParameterMatrix();

nOfEvents = size(allAddr, 1);
fprintf('number of events: %d\n', nOfEvents);

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);

pgrads = permute(gradients, [2 3 1]);
img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
imagesc(img);
colormap(gray);

invKPs = zeros([2 128 128]);

for u = 1:128
    for v = 1:128        
        invKP = K \ [u v 1]';  
        invKPs(:, v, u) = invKP(1:2);     
    end
end

for i = 1:size(x,1)
    
    [gradients, covariances, lastSigs, lastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), invKPs, gradients, covariances, lastSigs, lastPos);
    
    if mod(i, 50000) == 0
        
        pgrads = permute(gradients, [2 3 1]);
        
        if sum(sum(sum(isnan(gradients)))) > 0
            fprintf('gradient is NaN\n')
        end
        
        if sum(sum(sum(isinf(gradients)))) > 0
            fprintf('gradient is Inf\n');
        end
        
        fprintf('event %d / %d\n', i, nOfEvents);
        
        img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
        
        imagesc(img);
        pause(0.001);
    end
end

pgrads = permute(gradients, [2 3 1]);
img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);

imagesc(img);
pause(0.01);
fprintf('done\n');




