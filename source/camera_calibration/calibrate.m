
path = 'camera_calibration/recordings/';
name = 'calibration_'; % 5.5 cm side length

imgcount = 28;

for k = 1:imgcount
    
    disp(['converting image ' num2str(k) ' of ' num2str(imgcount)]);

    recording_raw = loadaerdat([path name num2str(k) '.aedat']);

    [x,y,pol] = extractRetinaEventsFromAddr(recording_raw);

    image = zeros(DVS_PatchSize());

    for i = 1:size(x,1)
        image(y(i)+1, x(i)+1) = image(y(i)+1, x(i)+1) - pol(i);
    end

    % scale image to [0, 1]
    image = image - min(min(image));
    image = image / max(max(image));

    imwrite(image, [path name num2str(k) '.png']);
    
end

% run cameraCalibrator
cameraCalibrator('recordings', 55);