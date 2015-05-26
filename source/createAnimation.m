function createAnimation(images, filename)
% function createAnimation(images, filename)

% from a given set of images, create an animated gif and save it as
% 'filename'

% input
% images: a set of N images as images(:,:,1), ... , images(:,:,N)
% filename: a string with the filename for the saved animation

filename = [filename '.gif'];

imwrite(im2uint8(images(:,:,1)), filename, 'gif', 'Loopcount', inf);
% figure(1);
for i = 2:size(images,3)
    imwrite(im2uint8(images(:,:,i)), filename, 'gif', 'WriteMode', 'append');
end