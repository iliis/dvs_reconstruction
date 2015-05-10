function [direction, offset] = findMovementDirection(firstImage, secondImage)

% tries to find the best fitting movement direction in 45 degree steps between the two images
% (only small movements are detected)
% input: firstImage, secondImage: two quadratic images with integrated events
% (see integrateEvents())
% output:
% direction: a number 1 - 8 representing the movement direction, starting with
% movement to the top left (1) and then increasing clockwise
% offset: the pixel offset to move from SECOND TO FIRST image

% assert(round(size(firstImage, 1)) == round(size(firstImage,2)));
% assert(all(size(firstImage) == size(secondImage)));
% assert(size(firstImage,1) > 5);

firstOffsets = [ ...
    -1 -1; ...
    -1 0; ...
    -1 1; ...
    0 1; ...
    1 1; ...
    1 0; ...
    1 -1; ...
    0 -1];

secondSmall = secondImage(2:end-1,2:end-1);
corrs = zeros(8,1);

for i = 1:8
    firstSmall = firstImage((2+firstOffsets(i,1)):(end-1+firstOffsets(i,1)), (2+firstOffsets(i,2)):(end-1+firstOffsets(i,2)));
%     size(firstSmall)
%     size(secondSmall)
    corrs(i) = corr2(firstSmall, secondSmall);
end
% corrs
[best, direction] = max(corrs);
disp(['best direction: ' num2str(direction) ' (value ' num2str(best) ')']);
offset = firstOffsets(direction,:);

end