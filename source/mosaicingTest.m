imagepath = 'camera_simulation/testimages/panorama.png';
thetaStart = [0, -pi/4, 0];
thetaStop = [0, pi/4, 0];
omega = [0, 0.02, 0];

boundary_image = 0.5*ones(500, 1000);

[allAddr, allTS, thetas] = flyDiffCam(imagepath, thetaStart, thetaStop, omega);


gradients = zeros(2,500,1000);
covariances = 1*ones(2,2,500,1000);
lastSigs = zeros(500,1000);
lastPos = zeros(2,500,1000);

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
        [min(min(img)) max(max(img))]
        imshow(img);
        pause(0.1);
    end
end





