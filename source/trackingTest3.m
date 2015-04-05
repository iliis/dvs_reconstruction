% test updateOnEvent() for single movement and a single event

% look a tiny bit up; this gives a max delta of about 7.8, with 5.3 at 61,43
theta_new = [0.0003 0 0];

imagepath = 'camera_simulation/testimages/panorama.png';

K = cameraIntrinsicParameterMatrix();
invKPs = zeros([128 128 2]);
for u = 1:128
    for v = 1:128      
        invKP = K \ [u v 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

img = double(rgb2gray(imread(imagepath)));

old_patch = getPatch(img, invKPs, [0 0 0]);
new_patch = getPatch(img, invKPs, theta_new);

u = 61; v = 43; % top edge of sphere

diff = new_patch(v,u) - old_patch(v,u);
%imagesc(new_patch-old_patch);

disp(['diff at ' num2str([u v]) ' = ' num2str(diff) '. Max. diff = ' num2str(max(max(sum(new_patch-old_patch))))]);


% plot change in likelihood over small alpha/beta movement range

range = linspace(-0.01,0.01);
[X, Y] = meshgrid(range,range);
particles = [repmat(1/numel(X), numel(X),1) reshape(X, numel(X),1) reshape(Y, numel(Y),1) zeros(numel(X),1)];
particles_prior = initParticles(numel(X));

LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 1; % 0.08
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;


K = cameraIntrinsicParameterMatrix();
invKPs = reshape(K \ [u v 1]', 1, 1, 3); invKPs = invKPs(:,:,1:2);

old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);



p1 = cameraToWorldCoordinatesBatch(invKPs, [0 0 0],   size(img));
p2 = cameraToWorldCoordinatesBatch(invKPs, theta_new, size(img));

disp(['p1 is at ' num2str(p1) ' (' num2str(p1-size(img)/2) ' from center) with img(p1) = ' num2str(interp2(img, p1(1),p1(2)))]);
disp(['p2 is at ' num2str(p2) ' (' num2str(p2-size(img)/2) ' from center) with img(p2) = ' num2str(interp2(img, p2(1),p2(2)))]);


for i = 1:size(particles_prior,1)
    % get pixel coordinates in world map
    old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior(i,2:end), size(img));
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(img));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
measurements = interp2(img,new_points_w(:,1),new_points_w(:,2)) - interp2(img,old_points_w(:,1),old_points_w(:,2));

% TODO: handle isnan(measurement)
assert(sum(isnan(measurements)) == 0);

particles(:, 1) = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD]);

%imagesc(particles(:,2), particles(:,3), particles(:,1));
surf(X, Y, reshape(particles(:,1), numel(range), numel(range)));
%figure;
%imagesc(reshape(measurements, numel(range), numel(range)));

%imagesc(img);
%hold on;
%plot(old_points_w(:,2), old_points_w(:,1), 'or');