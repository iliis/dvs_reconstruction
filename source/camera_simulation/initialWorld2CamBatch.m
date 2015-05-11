function camCoords = initialWorld2CamBatch(imgSize)

K = cameraIntrinsicParameterMatrix();

lt = round(cameraToWorldCoordinates(1, 1, K, [0 0 0], imgSize));
rt = round(cameraToWorldCoordinates(128, 1, K, [0 0 0], imgSize));
lb = round(cameraToWorldCoordinates(1, 128, K, [0 0 0], imgSize));
% rb = cameraToWorldCoordinates(128, 128, K, [0 0 0], imgSize);

camCoords = zeros([2, (lb(1)-lt(1)), (rt(2)-lt(2))]);
origin = imgSize/2;

xRange = (lt(2)+1):(rt(2)-1);
yRange = (lt(1)+1):(lb(1)-1);

for x = xRange
    for y = yRange
        p = K * [tan(([y x] - origin)*(2*pi)/imgSize(2)), 1]';
        camCoords(:, y-yRange(1)+1, x-xRange(1)+1) = p(1:2);
    end
end
camCoords = permute(camCoords, [2 3 1]);
camCoords = reshape(camCoords, [], 2);
end