function plotInWorld( points, img_size, varargin )
% plots N*2 points into world frame

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [simulationPatchSize() simulationPatchSize()]);
points_w = cameraToWorldCoordinatesThetaBatch(invKP_uv, points, img_size);
plot(points_w(:,2), points_w(:,1), varargin{:});

end

