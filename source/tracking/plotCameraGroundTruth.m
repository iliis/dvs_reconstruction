function plotCameraGroundTruth( path, img_size )

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [64 64]);

w = zeros(size(path,1),2);
for i = 1:size(path,1);
    w(i,:) = cameraToWorldCoordinatesBatch(invKP_uv, path(i,:), img_size);
end

plot(w(:,2), w(:,1), '.-g');

end

