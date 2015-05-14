%recording_raw = loadaerdat('camera_recordings/scene_reveal_H57.aedat');
% gut: 6, 9

path = 'camera_calibration/recordings/';
name = 'checkerboard_12';

recording_raw = loadaerdat([path name '.aedat']);

[x,y,pol] = extractRetinaEventsFromAddr(recording_raw);

image = zeros(DVS_PatchSize());

%pol(pol < 0) = 0;

for i = 1:size(x,1)
    image(y(i)+1, x(i)+1) = image(y(i)+1, x(i)+1) - pol(i);
end

%image = flipud(image)*0.22;

%imshow(image);
imagesc(image);
colormap 'gray';