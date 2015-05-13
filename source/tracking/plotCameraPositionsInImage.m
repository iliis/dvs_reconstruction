function plotCameraPositionsInImage( image, thetaCheckpoints, theta_gt )
% Plots a camera rotation of the event camera in the scene given by image
% 
% Arguments:
% imagepath: the path to the scene image as string
% thetaCheckpoints: keyframes for the camera orientation (angles)
% omegaCheckpoints: keyframes for the rotation speed (orientation change in one timestep)

if nargin < 3
    plotGroundTruth = false;
else
    plotGroundTruth = true;
end

img = image;
K   = cameraIntrinsicParameterMatrix();

img_size = size(img); %[size(img,2), size(img,1)];

imshow(img);
hold on;
points = zeros(size(thetaCheckpoints,1),2);
% iterate over all keyframes
for i = 1:size(thetaCheckpoints)
    points(i,:) = cameraToWorldCoordinates(1,1,K,thetaCheckpoints(i,:),img_size);
end

plot(points(:,2), points(:,1), '.');
plot(points(1,2), points(1,1), 'or');
%fprintf('keyframe %d is at %6.2d %6.2d\n', k, round(points(1,2)), round(points(1,1)));

if plotGroundTruth
    points = zeros(size(theta_gt,1),2);
    for i = 1:size(theta_gt)
        points(i,:) = cameraToWorldCoordinates(1,1,K,theta_gt(i,:),img_size);
    end
    
    plot(points(:,2), points(:,1), '.');
    plot(points(1,2), points(1,1), 'or');
    
    points(1,:) = cameraToWorldCoordinates(1,1,K,theta_gt(end,:),img_size);
    points(2,:) = cameraToWorldCoordinates(1,128,K,theta_gt(end,:),img_size);
    points(3,:) = cameraToWorldCoordinates(128,1,K,theta_gt(end,:),img_size);
    points(4,:) = cameraToWorldCoordinates(128,128,K,theta_gt(end,:),img_size);
    
    plot(points(:,2), points(:,1), 'ob');
end

points = zeros(4,2);

points(1,:) = cameraToWorldCoordinates(1,1,K,thetaCheckpoints(end,:),img_size);
points(2,:) = cameraToWorldCoordinates(1,128,K,thetaCheckpoints(end,:),img_size);
points(3,:) = cameraToWorldCoordinates(128,1,K,thetaCheckpoints(end,:),img_size);
points(4,:) = cameraToWorldCoordinates(128,128,K,thetaCheckpoints(end,:),img_size);

plot(points(:,2), points(:,1), 'og');

hold off;

end

