function plotGradient( gradient )
%PLOTGRADIENT plots color coded gradients according to direction and amplitude
%
% INPUT:
%   gradient: 2 * H * W

angles  = permute(atan2(gradient(2,:,:), gradient(1,:,:)), [2 3 1]);
lengths = permute((gradient(2,:,:).^2 + gradient(1,:,:).^2).^0.2, [2 3 1]);
imgsize = size(angles);


% normalize
angles  = angles / (2*pi) + 0.5;
lengths = lengths ./ max(max(lengths));

HSV = [reshape(angles,  numel(angles), 1), ...
       reshape(lengths, numel(angles), 1), ...
       ones(numel(angles),1)];

% convert to RGB values
RGB = hsv2rgb(HSV);

% back into something image shaped
RGB = reshape(RGB, imgsize(1), imgsize(2), 3);

% cut out interesting region
RGB = RGB(800:1300, 1100:2900, :);

imshow(RGB);

% imwrite(RGB, 'gradient.png');

end

