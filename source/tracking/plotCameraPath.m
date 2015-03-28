function plotCameraPath( imagepath, thetaCheckpoints, omegaCheckpoints, plotPatchesAtKeyframes )
% Plots a camera rotation of the event camera in the scene given by 'imagepath'
% 
% Arguments:
% imagepath: the path to the scene image as string
% thetaCheckpoints: keyframes for the camera orientation (angles)
% omegaCheckpoints: keyframes for the rotation speed (orientation change in one timestep)

img = rgb2gray(imread(imagepath));
K   = cameraIntrinsicParameterMatrix();

img_size = [size(img,2), size(img,1)];

imshow(img);
hold on;

% iterate over all keyframes
for k = 1:size(omegaCheckpoints)
    thetaStart = thetaCheckpoints(k,:);
    thetaStop  = thetaCheckpoints(k+1,:);
    omega      = omegaCheckpoints(k,:);
    
    steps = round((thetaStop - thetaStart) ./ omega);
    steps((thetaStop - thetaStart) == 0 & omega == 0) = 0;
    %fprintf('starting simulation with %d timesteps\n', max(steps));
    
    % interpolate between keyframes
    points = zeros(max(steps),2);
    for i = 1:max(steps)
        theta = thetaStart + i*omega;
        points(i,:) = cameraToWorldCoordinates(1,1,K,theta,img_size);
    end
    
    plot(points(:,1), points(:,2), '.');
    plot(points(1,1), points(1,2), 'or');
    %fprintf('keyframe %d is at %6.2d %6.2d\n', k, round(points(1,2)), round(points(1,1)));
    
    if (plotPatchesAtKeyframes)
        % plot patch boundaries
        xy = [0 0; 1 0; 1 1; 0 1; 0 0];
        patch_coords = [];
        for i = 1:(size(xy,1)-1)
            for j = 1:16:128
                patch_coords = [patch_coords; cameraToWorldCoordinates( ...
                    xy(i,1)*128 + (xy(i+1,1)-xy(i,1))*j,...
                    xy(i,2)*128 + (xy(i+1,2)-xy(i,2))*j,...
                    K,thetaStart,img_size)];
            end
        end
        plot(patch_coords(:,1), patch_coords(:,2), ':r');
    end
end

hold off;

end

