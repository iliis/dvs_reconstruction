function patch = getPatch(img, K, theta)

% Extracts a 128*128 pixel patch out of the given image, assuming this is a 360�
% panorama. The FOV depends on the given camera intrinsic parameter matrix
% K and the camera orientation in angles alpha, beta, gamma around x-, y-
% and z-axis in image space (z axis points away from camera)

origin = size(img)/2;

pixelCoords = double(zeros(128*128, 2));

% compute positions in global image
for u = 1:128
    for v = 1:128
        
        pixelCoords((u-1)*128 + v, :) = cameraToWorldCoordinates(u,v,K,theta,[size(img,2),size(img,1)]);
        
%         values = img(roundedCoords(1)-1:roundedCoords(1)+1, roundedCoords(2)-1:roundedCoords(2)+1);
%         coordOffset = targetCoords - roundedCoords + 2;
        
%         interpolate to obtain exact values
%         patch(v, u) = interp2(values, coordOffset(1), coordOffset(2));
        
%         patch(v, u) = img(round(targetP(2)*size(img, 2)/(2*pi)) + origin(1), round(targetP(1)*size(img, 2)/(2*pi)) + origin(2));
    end
end

patch = reshape(interp2(img, pixelCoords(:,1), pixelCoords(:,2)), [128 128]);