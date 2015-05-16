function plotCameraGroundTruth( path, img_size, color )

if nargin < 3
    color = 'green';
end

% plot at center of camera image
invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [simulationPatchSize() simulationPatchSize()]/2);

w = zeros(size(path,1),2);
for i = 1:size(path,1);
    w(i,:) = cameraToWorldCoordinatesBatch(invKP_uv, path(i,:), img_size);
end

plot(w(:,2), w(:,1), '.-', 'Color', color);

end

