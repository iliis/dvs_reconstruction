% test updateOnEvent() for single movement and a single event
% plot likelihood for different alpha and beta's

if ~exist('tracking_test3_figure', 'var') || ~ishandle(tracking_test3_figure)
    tracking_test3_figure = figure();
else
    figure(tracking_test3_figure);
end

% look a tiny bit up; this gives a max delta of about 7.8, with 5.3 at 61,43
theta_new = [0.0003 0 0];

range = linspace(-0.01,0.01,100);

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

% just checking if the coordinate transforrmations are correct
disp(['diff at ' num2str([u v]) ' = ' num2str(diff) '. Max. diff = ' num2str(max(max(sum(new_patch-old_patch))))]);


% plot change in likelihood over small alpha/beta movement range

[X, Y] = meshgrid(range,range);
particles = [repmat(1/numel(X), numel(X),1) reshape(X, numel(X),1) reshape(Y, numel(Y),1) zeros(numel(X),1)];
particles_prior = initParticles(numel(X));

LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 5; % 0.08
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.22;


% if this threshold is off from the 'real' one, the actual movement doesn't
% correspond to the (local) maximum likelihood!
% INTENSITY_THRESHOLD = diff;


K = cameraIntrinsicParameterMatrix();
invKPs = reshape(K \ [u v 1]', 1, 1, 3); invKPs = invKPs(:,:,1:2);

old_points_w = zeros(size(particles,1),2);
new_points_w = zeros(size(particles,1),2);



p1 = cameraToWorldCoordinatesBatch(invKPs, [0 0 0],   size(img));
p2 = cameraToWorldCoordinatesBatch(invKPs, theta_new, size(img));

I1 = interp2(img, p1(2), p1(1));
I2 = interp2(img, p2(2), p2(1));

disp(['p1 is at ' num2str(p1) ' (' num2str(p1-size(img)/2) ' from center) with img(p1) = ' num2str(I1)]);
disp(['p2 is at ' num2str(p2) ' (' num2str(p2-size(img)/2) ' from center) with img(p2) = ' num2str(I2)]);
disp([' --> diff = ' num2str(I2-I1) ' should equal ' num2str(diff)]);


for i = 1:size(particles_prior,1)
    % get pixel coordinates in world map
    % old_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles_prior(i,2:end), size(img));
    new_points_w(i,:) = cameraToWorldCoordinatesBatch(invKPs, particles(i,2:end),       size(img));
end
    
% get pixel-intensity difference of prior and proposed posterior particle
old_point_w = cameraToWorldCoordinates(u,v,K, [0 0 0], size(img));
old_intensity = interp2(img, old_point_w(2), old_point_w(1));
%measurements = interp2(img,new_points_w(:,2),new_points_w(:,1)) - interp2(img,old_points_w(:,2),old_points_w(:,1));
measurements = interp2(img, new_points_w(:,2), new_points_w(:,1)) - old_intensity; %interp2(intensities,old_points_w(:,2),old_points_w(:,1));

% TODO: handle isnan(measurement)
assert(sum(isnan(measurements)) == 0);

% store particle likelihood in particle array
particles(:, 1) = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD]);

[max_val, max_pos] = max(particles(:,1));

imagesc(range, range, reshape(particles(:,1), numel(range), numel(range)));
hold on;
plot(theta_new(1), theta_new(2), 'or');

max_y = range(mod(max_pos-1,numel(range))+1);
max_x = range(ceil(max_pos/numel(range)));
plot(max_x, max_y, 'og');

test_particles = initParticles(500);
particles(:, 2:end) = particles(:, 2:end) + 0.0004 * randn(size(particles)-[0,1]);
plot(test_particles(:,2), test_particles(:,3), '.b');

title({'likelihood of movement in alpha (X) or beta (Y) direction', ...
    'red circle: actual movement', ...
    ['green circle: max. likelihood (' num2str(max_val) ')'], ...
    ['intensity event threshold: ' num2str(INTENSITY_THRESHOLD)], ...
    ['actual intensity change at threshold: ' num2str(diff)]
});
xlabel('alpha'); ylabel('beta');

% set to true to plot global intensity map and current image patch
if false
    figure('Name', 'circle: the pixel we''re currently looking at');
    subplot(1,2,1);
    imagesc(img);
    hold on;
    plot(p1(2), p1(1), 'or');
    plot(p2(2), p2(1), 'ob');
    hold off;
    title('global intensity map');
    subplot(1,2,2);
    imagesc(old_patch);
    hold on;
    plot(u,v,'or');
    hold off;
    title('image patch');
end