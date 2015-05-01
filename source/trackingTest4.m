% test flyDiffCamFine
% -> extract realistic events by sweeping over image in very small steps

clear all;
close all;

imagepath = 'camera_simulation/testimages/toy_example1.png';


invKPs = getInvKPsforPatch(cameraIntrinsicParameterMatrix());
img = double(rgb2gray(imread(imagepath)));

[events, ground_truth] = flyDiffCamFine(img, 10);

patch = getPatch(img, invKPs, [0 0 0]);

events_pos = events(events(:,3) > 0, :);
events_neg = events(events(:,3) < 0, :);

figure;
imshow(patch);
hold on;
plot(events_pos(:,1), events_pos(:,2), 'og');
plot(events_neg(:,1), events_neg(:,2), 'or');
hold off;