function [ gradients, image, nextInd ] = createInitialImage(events, imageSize)

% INFO DEPRECATED
% % This function computes an initial image of the events of the first 2 ms.
% % It is assumed that the camera does not move during this time.
% % Input:
% % events: N*4 array with events(i,:) = [x y pol ts]
% % imageSize: an 1*2 vector indicating the desired image size [height width]
% % Output:
% % gradients: the calculated gradient map
% % image: the image computed from 'gradients'
% % nextInd: the smallest i where events(i,4) > 2000 or 1 if no such i can be
% % found

nextInd = 1;
while events(nextInd, 4) <= 1000000
     nextInd = nextInd + 1;
end

initEvents = events(1:(nextInd-1), :);

integratedImage = integrateEvents(initEvents);
[FX, FY] = gradient(integratedImage);

assert(false, 'TODO: simulationPatchSize() or DVS_patchSize() here? I.e. is this funtion used for real data?');
gradients = zeros([simulationPatchSize(), simulationPatchSize(), 2]);
gradients(:,:,1) = FY;
gradients(:,:,2) = FX;
gradients = permute(gradients, [3 1 2]);
image = integratedImage;

% boundary_image = 0.5*ones(imageSize);
% gradients = zeros([2, imageSize]);
% covariances = repmat(eye(2), [1, 1, imageSize]);
% lastSigs = zeros(128);
% 
% lastPos = repmat([1000000000 1000000000]', [1, imageSize]);
% 
% secToLastSigs = lastSigs;
% secToLastPos = lastPos;
% 
% assert(all(events(:,3) ~= 0));
% 
% nextInd = 1;
% while events(nextInd, 4) <= 1000000
%      [gradients, covariances, lastSigs, lastPos, secToLastSigs, secToLastPos] = ...
%          updateMosaic(events(nextInd,1), ...
%          events(nextInd,2), ...
%          events(nextInd,3), ...
%          events(nextInd,4), ...
%          [0 0 0], ...
%          gradients, ...
%          covariances, ...
%          lastSigs, ...
%          lastPos, ...
%          secToLastSigs, ...
%          secToLastPos);
%      nextInd = nextInd + 1;
% end
% 
% pgrads = permute(gradients, [2 3 1]);
% image = poisson_solver_function(pgrads(:,:,1), pgrads(:,:,2), boundary_image);
% 
% end