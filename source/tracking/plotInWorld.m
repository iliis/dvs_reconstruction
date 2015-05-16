function plotInWorld( thetas, img_size, uv, varargin )
% plots N*2 points into world frame

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), uv);
points_w = cameraToWorldCoordinatesThetaBatch(invKP_uv, thetas, img_size);
plot(points_w(:,2), points_w(:,1), varargin{:});

end

