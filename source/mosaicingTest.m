imagepath = 'camera_simulation/testimages/panorama.png';

% thetaCheckpoints = ...
%     [pi/8, pi/8, 0; ...
%     -pi/8, -pi/8, 0];
% omegas = ...
%     [-0.01, -0.01, 0];

thetaCheckpoints = ...
   [pi/4, pi/4, 0 ; ...
   -pi/4, -pi/4, -pi; ...
   pi/4, -pi/4, 0; ...
   -pi/4, pi/4, 2*pi];
omegas = ...
    5*[-0.001, -0.001, -0.002; ...
    0.001, 0, 0.002; ...
    -0.001, 0.001, 0.004];

% thetaCheckpoints = ...
%     [pi/4, pi/4, 0; ...
%     pi/4, -pi/4, 0; ...
%     0, -pi/4, 0; ...
%     0, pi/4, 0; ...
%     -pi/4, pi/4, 0; ...
%     -pi/4, -pi/4, 0; ...
%     pi/4, -pi/4, 0; ...
%     pi/4, 0, 0; ...
%     -pi/4, 0, 0; ...
%     -pi/4, pi/4, 0; ...
%     pi/4, pi/4, 0];
% omegas = ...
%     0.001 * ...
%     [0, -1, 0; ...
%     -1, 0, 0; ...
%     0, 1, 0; ...
%     -1, 0, 0; ...
%     0, -1, 0; ...
%     1, 0, 0; ...
%     0, 1, 0; ...
%     -1, 0, 0; ...
%     0, 1, 0; ...
%     1, 0, 0];

if size(thetaCheckpoints, 1) ~= size(omegas, 1) + 1
    error('number of checkpoints and velocities inconsistent');
end

allAddr = [];
allTS = 0; %set first number 0 to have reference for first bunch of stamps
allThetas = [];
intermediateState = zeros(128, 128);

for i = 1:size(thetaCheckpoints, 1) - 1
    
    fprintf('simulating subpath %d/%d\n', i, size(omegas, 1));
    
    [addr, ts, thetas, intermediateState] = flyDiffCam2(imagepath, thetaCheckpoints(i, :), thetaCheckpoints(i+1, :), omegas(i, :), intermediateState);
    
    allAddr = [allAddr; addr];
    allTS = [allTS; ts + allTS(end)];
    allThetas = [allThetas; thetas];    
end
% [allAddr, allTS, thetas] = flyDiffCam2(imagepath, thetaStart, thetaStop, omega);

allTS = allTS(2:end); %remove pending 0;

outputImageSize = [500, 1000];
boundary_image = 0.5*ones(outputImageSize);

[img, gradients] = reconstructMosaic(allAddr, allTS, allThetas);


% gradients = zeros([2, outputImageSize]);
% % covariances = ones([2,2,outputImageSize]);
% % covariances = 10*repmat([1, 2; 2 1], [1, 1, outputImageSize]);
% covariances = repmat(eye(2), [1, 1, outputImageSize]);
% lastSigs = zeros(128);
% lastPos = zeros(2,128,128);
% 
% K = cameraIntrinsicParameterMatrix();
% 
% nOfEvents = size(allAddr, 1)
% 
% [x, y, pol] = extractRetinaEventsFromAddr(allAddr);
% 
% for i = 1:size(x,1)
%     
%     [gradients, covariances, lastSigs, lastPos] = updateMosaic(x(i)+1, y(i)+1, pol(i), allTS(i), thetas(i, :), K, gradients, covariances, lastSigs, lastPos);
%     
%     if mod(i, 5000) == 0
%         
%         pgrads = permute(gradients, [2 3 1]);
%         
%         if sum(sum(sum(isnan(gradients)))) > 0
%             fprintf('gradient is NaN\n')
%         end
%         
%         if sum(sum(sum(isinf(gradients)))) > 0
%             fprintf('gradient is Inf\n');
%         end
%         
%         fprintf('event %d / %d\n', i, nOfEvents);
% %     	imagesc(pgrads(:,:,2));
%         img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
%         
% %         minMaxGrad = [min(min(min(gradients))) max(max(max(gradients)))]
% %         minMaxImg = [min(min(img)) max(max(img))]
%         imagesc(img);
%         pause(0.01);
%     end
% end
% 
% pgrads = permute(gradients, [2 3 1]);
% img = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
% % minMaxGrad = [min(min(min(gradients))) max(max(max(gradients)))]
% % minMaxImg = [min(min(img)) max(max(img))]
% imagesc(img);
% pause(0.01);
% fprintf('done\n');




