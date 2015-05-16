function [ invKPs ] = getInvKPforPixels( K, UV )
% Input: Kamera Intrinsic matrix, Nx2 pixel coordinates [u, v]
% output Nx1x2 matrix of inverted projected pixels

invKPs = zeros([size(UV,1) 1 2]);
for i = 1:size(UV,1)
    invKP = K \ [UV(i,1) UV(i,2) 1]';
    invKPs(i, 1, :) = invKP(1:2);
end

end

