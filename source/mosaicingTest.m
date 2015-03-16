imagepath = 'camera_simulation/testimages/churchtest_cropped.jpg';
thetaStart = [-pi/8, -pi/4, 0];
thetaStop = [pi/8, pi/4, 0];
omega = [0.01, 0.02, 0.01];

outputImageSize = [300, 600];

boundary_image = 0.5*ones(outputImageSize);

[allAddr, allTS, thetas] = flyDiffCam(imagepath, thetaStart, thetaStop, omega);


gradients = zeros([2, outputImageSize]);
covariances = 1000*ones([2,2,outputImageSize]);
lastSigs = zeros(128);
lastPos = zeros(2,128,128);

K = cameraIntrinsicParameterMatrix();

nOfEvents = size(allAddr, 1)

[x, y, pol] = extractRetinaEventsFromAddr(allAddr);

for i = 1:size(x,1)
    
    [gradients, covariances, lastSigs, lastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), K, gradients, covariances, lastSigs, lastPos);
    
    if mod(i, 2000) == 0
        
        pgrads = permute(gradients, [2 3 1]);
        
        if sum(sum(sum(isnan(gradients)))) > 0
            fprintf('gradient is NaN\n')
        end
        
        if sum(sum(sum(isinf(gradients)))) > 0
            fprintf('gradient is Inf\n');
        end
        
        fprintf('event %d / %d\n', i, nOfEvents);
    
        img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
        
        minMaxGrad = [min(min(min(gradients))) max(max(max(gradients)))]
        minMaxImg = [min(min(img)) max(max(img))]
        imshow(img);
        pause(1);
    end
end





