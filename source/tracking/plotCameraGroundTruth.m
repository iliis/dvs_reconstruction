function plotCameraGroundTruth( path, img_size, color )

if nargin < 3
    color = 'green';
end

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [64 64]);

w = zeros(size(path,1),2);
for i = 1:size(path,1);
    w(i,:) = cameraToWorldCoordinatesBatch(invKP_uv, path(i,:), img_size);
end

plot(w(:,2), w(:,1), '.-', 'Color', color);

end

