% This script batch converts recordings from jAER into PNG images by simply
% integrating events. Use in conjunction with the calibration tool or the
% shutter removeal technique described in the report.
%
% Usage:
%   record a few calibration patterns with the calibration tool and jAER
%   (more documentation on the former in calibration_tool.cpp), then
%   calibrate camera by running cameraCalibrator (or any other standard
%   camera calibration toolbox really).


%recording_raw = loadaerdat('camera_recordings/scene_reveal_H57.aedat');
% gut: 6, 9
% 5.5 mm side length

% update these to fir your needs
path = 'camera_calibration/recordings/';
name = 'calibration_';
imgcount = 28;

for k = 1:imgcount
    
    disp(['converting image ' num2str(k) ' of ' num2str(imgcount)]);

    recording_raw = loadaerdat([path name num2str(k) '.aedat']);

    [x,y,pol] = extractRetinaEventsFromAddr(recording_raw);

    image = zeros(DVS_PatchSize());

    % remove negative (!) events
    % this is actually not necessary for calibration images as positive
    % events far outweight the negative ones. But uncommenting this line
    % will not hurt either.
    %pol(pol > 0) = 0;

    for i = 1:size(x,1)
        image(y(i)+1, x(i)+1) = image(y(i)+1, x(i)+1) - pol(i);
    end


    %imagesc(image);
    %colormap 'gray';

    % scale image to [0, 1]
    image = image - min(min(image));
    image = image / max(max(image));

    imwrite(image, [path name num2str(k) '.png']);
    
end