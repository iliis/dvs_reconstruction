function plotCameraRect( theta, img_size )
%PLOTCAMERARECT plots a rectangle of what the camera sees in world

K = cameraIntrinsicParameterMatrix();

% pixel coordinates: 1 to patchSize
xy = [ ...
    0 0; 1 0; 1 1; 0 1; 0 0; ... % rectangle
    0.4 0; 0.5 -0.1; 0.6 0]; % up-arrow
xy = xy*(simulationPatchSize()-1)+1;

patch_coords = zeros((size(xy,1)-1)*16, 2);
for i = 1:(size(xy,1)-1)
    
    us = interp1([xy(i,1) xy(i+1,1)], linspace(1,2,16));
    vs = interp1([xy(i,2) xy(i+1,2)], linspace(1,2,16));
    
    for j = 1:numel(us)
        world_point = cameraToWorldCoordinates( ...
            us(j),vs(j),K,theta,img_size, true);
        
        %[us(j) vs(j) world_point]
        
        patch_coords((i-1)*16+j,:) = world_point;
    end
end
plot(patch_coords(:,2), patch_coords(:,1), '-r');

end

