function [ map, gradients, theta_est ] = trackingTest2(steps)

% imagepath = 'camera_simulation/testimages/panorama.png';
imagepath = 'camera_simulation/testimages/checkerboard_small.jpg';
% imagepath = 'camera_simulation/testimages/churchtest_cropped.jpg';

omega = [0.00001 0.00001 0];

[events_raw, TS, theta_gt, ~] = flyDiffCam2(imagepath, [0 0 0], steps*omega, omega, zeros(64));

disp([ num2str(size(events_raw)) ' events generated']);

[map, gradients, theta_est ] = trackingTest_combined(events_raw, TS, theta_gt, imagepath);
